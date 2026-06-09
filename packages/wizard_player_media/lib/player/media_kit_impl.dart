import 'dart:async';

import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';

import 'wizard_player.dart';
import 'playback_state.dart';

/// 基于 media_kit 的实现（libmpv 后端，全平台支持）
///
/// 设计要点：
/// 1. media_kit 基于 libmpv，播放与渲染分离 —— Player 与 Video Widget 各管一块
/// 2. Player 实例可跨 Widget 复用（全屏/非全屏切换共用同一个 Player）
/// 3. 位置/时长通过 media_kit 的流（player.streams.position / player.streams.duration）获取
/// 4. 显式 release() 时调用 player.dispose() 释放底层资源
class MediaKitWizard extends WizardPlayer {
  late final Player _player;
  bool _disposed = false;

  // media_kit 事件订阅（用于清理）
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _bufferSub;
  StreamSubscription<bool>? _bufferingSub;
  StreamSubscription<bool>? _playingSub;
  bool _completedFired = false;

  MediaKitWizard() {
    _player = Player();
    _subscribeToStreams();
  }

  void _subscribeToStreams() {
    // 当前播放位置
    _positionSub = _player.stream.position.listen((pos) {
      currentPosition.value = pos;
      print('[MediaKitWizard] Position updated: $pos');
    });

    // 总时长
    _durationSub = _player.stream.duration.listen((d) {
      duration.value = d;
      print('[MediaKitWizard] Duration updated: $d');
    });

    // 缓冲进度（1.2.x: streams.buffer 返回 Duration，计算百分比）
    _bufferSub = _player.stream.buffer.listen((buffered) {
      final total = duration.value;
      if (total.inMilliseconds > 0) {
        bufferProgress.value = buffered.inMilliseconds / total.inMilliseconds;
      }
    });

    // 是否缓冲中（1.2.x: streams.buffering 返回 bool）
    _bufferingSub = _player.stream.buffering.listen((v) {
      isBuffering.value = v;
    });

    // 播放状态变化（1.2.x: streams.playing 返回 bool）
    _playingSub = _player.stream.playing.listen((playing) {
      if (playing) {
        _completedFired = false;
        playbackState.value = PlaybackState.playing;
      } else {
        // 只有当前是 playing 状态时才改为 paused，loading 状态保持不变
        if (playbackState.value == PlaybackState.playing) {
          playbackState.value = PlaybackState.paused;
        }
      }
    });

    // 播放完成（1.2.x: streams.completed 返回 bool）
    _player.stream.completed.listen((_) {
      if (!_completedFired) {
        playbackState.value = PlaybackState.completed;
        _completedFired = true;
      }
    });
  }

  @override
  Future<void> playUri(String uri) async {
    try {
      updatePlaybackState(PlaybackState.loading);
      currentUri.value = uri;

      if (_disposed) return;

      // media_kit: Media 支持 http(s)://、file://、magnet:? 等
      print('[MediaKitWizard] Opening media: $uri');
      await _player.open(Media(uri), play: true);
      print('[MediaKitWizard] Media opened successfully');

      // 应用当前音量和速度
      await _player.setVolume(volume.value * 100.0);
      await _player.setRate(playbackSpeed.value);

      // 延迟一小段时间等待流事件触发
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      print('[MediaKitWizard] Error playing uri: $e');
      updatePlaybackState(PlaybackState.error);
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    if (!_disposed) {
      await _player.pause();
      playbackState.value = PlaybackState.paused;
    }
  }

  @override
  Future<void> resume() async {
    if (!_disposed) {
      await _player.play();
      playbackState.value = PlaybackState.playing;
    }
  }

  @override
  Future<void> stop() async {
    if (!_disposed) {
      await _player.stop();
      playbackState.value = PlaybackState.stopped;
    }
  }

  @override
  Future<void> seekTo(Duration position) async {
    if (!_disposed) {
      await _player.seek(position);
      currentPosition.value = position;
    }
  }

  @override
  Future<void> setVolume(double value) async {
    final v = value.clamp(0.0, 1.0);
    volume.value = v;
    if (!_disposed) {
      await _player.setVolume(v * 100.0);
    }
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    final s = speed.clamp(0.5, 3.0);
    playbackSpeed.value = s;
    if (!_disposed) {
      await _player.setRate(s);
    }
  }

  @override
  Future<void> enterFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Future<void> exitFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Future<void> release() async {
    if (_disposed) return;
    _disposed = true;

    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _bufferSub?.cancel();
    await _bufferingSub?.cancel();
    await _playingSub?.cancel();

    try {
      await _player.dispose();
    } catch (_) {
      // ignore duplicate dispose
    }

    playbackState.value = PlaybackState.idle;
    currentPosition.value = Duration.zero;
    duration.value = Duration.zero;
  }

  /// 获取底层 Player（供 Video Widget 使用）
  @override
  T? getPlatformPlayer<T>() {
    if (!_disposed && _player is T) {
      return _player as T;
    }
    return null;
  }

  @override
  void onClose() {
    release();
    super.onClose();
  }
}
