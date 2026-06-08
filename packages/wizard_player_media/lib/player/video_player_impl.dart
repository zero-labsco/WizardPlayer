import 'dart:io';

import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'wizard_player.dart';
import 'playback_state.dart';

/// 基于 video_player 的实现
///
/// 1. Player 实例与 Video 渲染组件解耦
/// 2. VideoPlayerController 一旦创建，就可以通过 getPlatformPlayer 获取
///    （即使 isInitialized 是 false，VideoPlayer Widget 也能稳定持有它）
/// 3. 位置更新 timer 在构造函数中启动——不依赖 GetxController 生命周期
/// 4. 只有在显式 release 或销毁时才释放 controller
class VideoPlayerWizard extends WizardPlayer {
  VideoPlayerController? _controller;
  bool _disposed = false;

  /// 构造函数——立即启动位置更新 timer
  VideoPlayerWizard() {
    startPositionUpdates();
  }

  @override
  Future<void> playUri(String uri) async {
    try {
      updatePlaybackState(PlaybackState.loading);
      currentUri.value = uri;

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

      // 添加监听器（缓冲进度、缓冲状态等）
      _controller!.addListener(_onPlayerStateChanged);

      // 设置音量和速度
      await _controller!.setVolume(volume.value);
      await _controller!.setPlaybackSpeed(playbackSpeed.value);

      // 更新总时长（从 controller 读取）
      duration.value = _controller!.value.duration;

      // 确保位置更新 timer 在运行（release() 可能把它停了）
      startPositionUpdates();

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
      // seek 后立即更新 currentPosition，让 UI 立即响应
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
    // 只切换系统 UI 模式，不改变方向（方向由外部 Route 管理）
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Future<void> exitFullscreen() async {
    // 只切换系统 UI 模式，不改变方向
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Future<void> release() async {
    // 先停止位置更新 timer
    stopPositionUpdates();
    if (_controller != null) {
      _controller!.removeListener(_onPlayerStateChanged);
      await _controller!.dispose();
      _controller = null;
    }
    updatePlaybackState(PlaybackState.idle);
    // 重置位置和时长显示
    currentPosition.value = Duration.zero;
    duration.value = Duration.zero;
  }

  /// 获取底层播放器控制器
  ///
  /// 即使 isInitialized 是 false，VideoPlayer Widget 也需要持有它
  @override
  T? getPlatformPlayer<T>() {
    if (!_disposed && _controller != null && _controller is T) {
      return _controller as T;
    }
    return null;
  }

  /// 每 200ms 从 controller 读取当前播放位置和总时长
  ///
  /// 这是 UI 实时更新的唯一数据源——必须持续读取
  @override
  void updatePosition() {
    if (_controller != null && _controller!.value.isInitialized) {
      currentPosition.value = _controller!.value.position;
      // 同步总时长（流媒体可能在初始化后才知道真实时长）
      if (_controller!.value.duration > Duration.zero) {
        duration.value = _controller!.value.duration;
      }
    }
  }

  /// 播放器状态变化监听——处理缓冲进度、缓冲状态、播放完成
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
