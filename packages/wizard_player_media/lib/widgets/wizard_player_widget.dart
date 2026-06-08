import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../player/wizard_player.dart';
import '../player/video_player_impl.dart';
import '../player/playback_state.dart';

/// 视频播放器 Widget
class WizardPlayerWidget extends StatefulWidget {
  final WizardPlayer? player;
  final String? initialUri;
  final bool showControls;
  final bool autoPlay;

  const WizardPlayerWidget({
    super.key,
    this.player,
    this.initialUri,
    this.showControls = true,
    this.autoPlay = false,
  });

  @override
  State<WizardPlayerWidget> createState() => _WizardPlayerWidgetState();
}

class _WizardPlayerWidgetState extends State<WizardPlayerWidget> {
  late final WizardPlayer _player;
  VideoPlayerController? _videoController;
  bool _controlsVisible = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _player = widget.player ?? Get.put(VideoPlayerWizard());
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (widget.initialUri != null && widget.initialUri!.isNotEmpty) {
      await _player.playUri(widget.initialUri!);
      if (!widget.autoPlay) {
        await _player.pause();
      }
    }
    _updateVideoController();
    _player.playbackState.listen((state) {
      _updateVideoController();
      setState(() {});
    });
  }

  void _updateVideoController() {
    if (_player is VideoPlayerWizard) {
      _videoController = (_player).getPlatformPlayer<VideoPlayerController>();
    }
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });

    if (_controlsVisible) {
      _startHideControlsTimer();
    } else {
      _cancelHideControlsTimer();
    }
  }

  void _startHideControlsTimer() {
    _cancelHideControlsTimer();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _cancelHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }

  @override
  void dispose() {
    _cancelHideControlsTimer();
    if (widget.player == null) {
      _player.release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.showControls ? _toggleControls : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频画面
          _buildVideoPlayer(),

          // 加载指示器
          _buildLoadingIndicator(),

          // 控制栏
          if (widget.showControls) _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return VideoPlayer(_videoController!);
    }
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white30),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Obx(() {
      if (_player.isBuffering.value ||
          _player.playbackState.value == PlaybackState.loading) {
        return Container(
          color: Colors.black26,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildControlsOverlay() {
    return AnimatedOpacity(
      opacity: _controlsVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 底部控制区域
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 控制按钮
                    _buildBottomControls(),
                    // 进度条（最底部）
                    _buildProgressBar(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Obx(() {
      final position = _player.currentPosition.value;
      final total = _player.duration.value;
      final buffered = _player.bufferProgress.value;

      if (!total.isNegative && total.inMilliseconds > 0) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 缓冲进度条
              SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  value: buffered,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation(Colors.white54),
                ),
              ),
              const SizedBox(height: 4),
              // 播放进度条
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  inactiveTrackColor: Colors.white30,
                  thumbColor: Theme.of(context).colorScheme.primary,
                ),
                child: Slider(
                  value: position.inMilliseconds.toDouble(),
                  max: total.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    _player.seekTo(Duration(milliseconds: value.round()));
                  },
                ),
              ),
              // 时间显示
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      _formatDuration(total),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // 播放/暂停按钮
          _buildPlayPauseButton(),

          const SizedBox(width: 8),

          // 快退 10 秒
          IconButton(
            icon: const Icon(Icons.replay_10, color: Colors.white),
            iconSize: 28,
            onPressed: () {
              final newPosition =
                  _player.currentPosition.value - const Duration(seconds: 10);
              _player.seekTo(
                newPosition < Duration.zero ? Duration.zero : newPosition,
              );
            },
          ),

          // 快进 10 秒
          IconButton(
            icon: const Icon(Icons.forward_10, color: Colors.white),
            iconSize: 28,
            onPressed: () {
              final newPosition =
                  _player.currentPosition.value + const Duration(seconds: 10);
              _player.seekTo(
                newPosition > _player.duration.value
                    ? _player.duration.value
                    : newPosition,
              );
            },
          ),

          const Spacer(),

          // 音量控制
          _buildVolumeControl(),

          const SizedBox(width: 8),

          // 倍速控制
          _buildSpeedControl(),

          const SizedBox(width: 8),

          // 全屏按钮
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            iconSize: 28,
            onPressed: () {
              _player.enterFullscreen();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Obx(
      () => IconButton(
        icon: Icon(
          _player.playbackState.value == PlaybackState.playing
              ? Icons.pause_circle_filled
              : Icons.play_circle_filled,
          color: Colors.white,
        ),
        iconSize: 48,
        onPressed: () {
          if (_player.playbackState.value == PlaybackState.playing) {
            _player.pause();
          } else {
            _player.resume();
          }
        },
      ),
    );
  }

  Widget _buildVolumeControl() {
    return Obx(
      () => IconButton(
        icon: Icon(
          _player.volume > 0.5
              ? Icons.volume_up
              : _player.volume > 0
              ? Icons.volume_down
              : Icons.volume_off,
          color: Colors.white,
        ),
        onPressed: () {
          // 简单的音量切换
          _player.setVolume(_player.volume > 0 ? 0 : 1);
        },
      ),
    );
  }

  Widget _buildSpeedControl() {
    return PopupMenuButton<double>(
      icon: const Icon(Icons.speed, color: Colors.white),
      onSelected: (speed) {
        _player.setPlaybackSpeed(speed);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 0.5, child: Text('0.5x')),
        const PopupMenuItem(value: 0.75, child: Text('0.75x')),
        const PopupMenuItem(value: 1.0, child: Text('1.0x')),
        const PopupMenuItem(value: 1.25, child: Text('1.25x')),
        const PopupMenuItem(value: 1.5, child: Text('1.5x')),
        const PopupMenuItem(value: 2.0, child: Text('2.0x')),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
