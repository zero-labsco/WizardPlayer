import 'dart:io';

import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'wizard_player.dart';
import 'playback_state.dart';

/// 基于 video_player 的实现
class VideoPlayerWizard extends WizardPlayer {
  VideoPlayerController? _controller;
  bool _disposed = false;
  bool _controllerActive = false;

  @override
  Future<void> playUri(String uri) async {
    try {
      updatePlaybackState(PlaybackState.loading);
      currentUri.value = uri;

      // 先将 controller 标记为无效，让 Widget 树显示黑色背景
      _controllerActive = false;

      // 释放旧的控制器
      if (_controller != null) {
        _controller!.removeListener(_onPlayerStateChanged);
        await _controller!.dispose();
        _controller = null;
      }

      // 如果已销毁，直接返回
      if (_disposed) return;

      // 创建新的控制器
      if (uri.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(uri));
      } else {
        _controller = VideoPlayerController.file(
          Uri.parse(uri).toFilePath() as File,
        );
      }

      // 如果已销毁，直接返回
      if (_disposed) {
        await _controller?.dispose();
        _controller = null;
        return;
      }

      // 初始化控制器
      await _controller!.initialize();

      // 如果已销毁，直接返回
      if (_disposed) {
        await _controller?.dispose();
        _controller = null;
        return;
      }

      // 添加监听器
      _controller!.addListener(_onPlayerStateChanged);

      // 设置音量和速度
      await _controller!.setVolume(volume.value);
      await _controller!.setPlaybackSpeed(playbackSpeed.value);

      // 更新总时长
      duration.value = _controller!.value.duration;

      // 标记为有效
      _controllerActive = true;

      // 开始播放
      await _controller!.play();
      updatePlaybackState(PlaybackState.playing);
    } catch (e) {
      updatePlaybackState(PlaybackState.error);
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    if (_controller != null && _controller!.value.isPlaying) {
      await _controller!.pause();
      updatePlaybackState(PlaybackState.paused);
    }
  }

  @override
  Future<void> resume() async {
    if (_controller != null && !_controller!.value.isPlaying) {
      await _controller!.play();
      updatePlaybackState(PlaybackState.playing);
    }
  }

  @override
  Future<void> stop() async {
    if (_controller != null) {
      await _controller!.pause();
      await _controller!.seekTo(Duration.zero);
      updatePlaybackState(PlaybackState.stopped);
    }
  }

  @override
  Future<void> seekTo(Duration position) async {
    if (_controller != null) {
      await _controller!.seekTo(position);
      currentPosition.value = position;
    }
  }

  @override
  Future<void> setVolume(double value) async {
    volume.value = value.clamp(0.0, 1.0);
    if (_controller != null) {
      await _controller!.setVolume(volume.value);
    }
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    playbackSpeed.value = speed.clamp(0.5, 3.0);
    if (_controller != null) {
      await _controller!.setPlaybackSpeed(playbackSpeed.value);
    }
  }

  @override
  Future<void> enterFullscreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Future<void> exitFullscreen() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Future<void> release() async {
    // 先将 controller 标记为无效，避免 Widget 树在 dispose 过程中访问
    _controllerActive = false;
    if (_controller != null) {
      _controller!.removeListener(_onPlayerStateChanged);
      await _controller!.dispose();
      _controller = null;
    }
    updatePlaybackState(PlaybackState.idle);
  }

  /// 获取底层播放器控制器（仅在 controller 有效时返回）
  @override
  T? getPlatformPlayer<T>() {
    if (_controllerActive &&
        !_disposed &&
        _controller != null &&
        _controller is T) {
      return _controller as T;
    }
    return null;
  }

  @override
  void updatePosition() {
    if (_controller != null && _controller!.value.isInitialized) {
      currentPosition.value = _controller!.value.position;
    }
  }

  /// 播放器状态变化监听
  void _onPlayerStateChanged() {
    if (_controller == null) return;

    final value = _controller!.value;

    // 更新缓冲进度
    if (value.buffered.isNotEmpty) {
      final buffered = value.buffered.last.end;
      if (value.duration.inMilliseconds > 0) {
        bufferProgress.value =
            buffered.inMilliseconds / value.duration.inMilliseconds;
      }
    }

    // 更新缓冲状态
    isBuffering.value = value.isBuffering;

    // 检查播放完成
    if (value.position >= value.duration && value.isInitialized) {
      updatePlaybackState(PlaybackState.completed);
    }
  }

  @override
  void onClose() {
    _disposed = true;
    release();
    super.onClose();
  }
}
