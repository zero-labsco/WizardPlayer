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
  final VoidCallback? onFullscreen;
  final bool Function()? isFullscreen;

  const WizardPlayerWidget({
    super.key,
    this.player,
    this.initialUri,
    this.showControls = true,
    this.autoPlay = false,
    this.onFullscreen,
    this.isFullscreen,
  });

  @override
  State<WizardPlayerWidget> createState() => _WizardPlayerWidgetState();
}

class _WizardPlayerWidgetState extends State<WizardPlayerWidget> {
  late WizardPlayer _player;
  bool _controlsVisible = true;
  Timer? _hideControlsTimer;
  double _horizontalDragDelta = 0;
  bool _isHorizontalDragging = false;
  Duration? _dragStartPosition;
  String _dragSeekText = '';
  Timer? _hideSeekTextTimer;
  StreamSubscription<PlaybackState>? _playbackStateSubscription;

  @override
  void initState() {
    super.initState();
    _player = widget.player ?? VideoPlayerWizard();
    _initPlayer();
  }

  /// 当外部 widget.player 变化时，更新内部 _player 引用
  @override
  void didUpdateWidget(WizardPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.player != null && widget.player != _player) {
      // 如果是 widget 自己创建的 player，释放它
      if (oldWidget.player == null) {
        _player.release();
      }
      _player = widget.player!;
      // 重新订阅新 player 的状态变化
      _playbackStateSubscription?.cancel();
      _playbackStateSubscription = _player.playbackState.listen((state) {
        if (mounted) setState(() {});
      });
    }
  }

  void _initPlayer() {
    if (widget.initialUri != null && widget.initialUri!.isNotEmpty) {
      _player.playUri(widget.initialUri!).then((_) {
        if (!widget.autoPlay && mounted) {
          _player.pause();
        }
      });
    }
    // 订阅播放状态变化，强制 widget rebuild 以更新视频显示
    _playbackStateSubscription ??= _player.playbackState.listen((state) {
      if (mounted) setState(() {});
    });
  }

  /// 动态获取 VideoPlayerController（不缓存，避免引用失效问题）
  VideoPlayerController? _getController() {
    if (_player is VideoPlayerWizard) {
      return (_player).getPlatformPlayer<VideoPlayerController>();
    }
    return null;
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
    _cancelHideSeekTextTimer();
    // 取消订阅（如果存在），避免内存泄漏
    _playbackStateSubscription?.cancel();
    _playbackStateSubscription = null;
    // 只有 widget 自己创建的播放器才释放
    if (widget.player == null) {
      _player.release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.showControls ? _toggleControls : null,
      onDoubleTap: () {
        if (!widget.showControls) return;
        if (_player.playbackState.value == PlaybackState.playing) {
          _player.pause();
        } else {
          _player.resume();
        }
      },
      onHorizontalDragStart: (details) {
        if (!widget.showControls) return;
        _isHorizontalDragging = true;
        _horizontalDragDelta = 0;
        _dragStartPosition = _player.currentPosition.value;
        _cancelHideSeekTextTimer();
        setState(() {});
      },
      onHorizontalDragUpdate: (details) {
        if (!widget.showControls || !_isHorizontalDragging) return;
        _horizontalDragDelta += details.delta.dx;
        final screenWidth = context.size?.width ?? 1.0;
        final secondsDelta = (_horizontalDragDelta / screenWidth) * 60;
        final newPosition =
            _dragStartPosition! + Duration(seconds: secondsDelta.toInt());
        final total = _player.duration.value;
        final clampedPosition = Duration(
          milliseconds: newPosition.inMilliseconds.clamp(
            0,
            total.inMilliseconds,
          ),
        );
        final diff = clampedPosition - _dragStartPosition!;
        final sign = diff.isNegative ? '-' : '+';
        _dragSeekText =
            '$sign${_formatDuration(diff.abs())} / ${_formatDuration(clampedPosition)}';
        setState(() {});
      },
      onHorizontalDragEnd: (details) {
        if (!widget.showControls || !_isHorizontalDragging) return;
        _isHorizontalDragging = false;
        final screenWidth = context.size?.width ?? 1.0;
        final secondsDelta = (_horizontalDragDelta / screenWidth) * 60;
        final newPosition =
            _dragStartPosition! + Duration(seconds: secondsDelta.toInt());
        final total = _player.duration.value;
        final clampedPosition = Duration(
          milliseconds: newPosition.inMilliseconds.clamp(
            0,
            total.inMilliseconds,
          ),
        );
        _player.seekTo(clampedPosition);
        _startHideSeekTextTimer();
        setState(() {});
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频画面（动态获取 controller，不缓存）
          _buildVideoPlayer(),

          // 加载指示器
          _buildLoadingIndicator(),

          // 滑动快进/快退提示
          if (_isHorizontalDragging) _buildSeekIndicator(),

          // 控制栏
          if (widget.showControls) _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildSeekIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _dragSeekText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _startHideSeekTextTimer() {
    _hideSeekTextTimer?.cancel();
    _hideSeekTextTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _dragSeekText = '';
        });
      }
    });
  }

  void _cancelHideSeekTextTimer() {
    _hideSeekTextTimer?.cancel();
    _hideSeekTextTimer = null;
  }

  Widget _buildVideoPlayer() {
    final controller = _getController();
    if (controller != null && controller.value.isInitialized) {
      // ValueKey(controller.hashCode) 确保当 controller 是新对象时，
      // VideoPlayer Widget 能正确重建，避免引用已销毁的 native player ID
      return SizedBox.expand(
        child: Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio > 0
                ? controller.value.aspectRatio
                : 16 / 9,
            child: VideoPlayer(controller, key: ValueKey(controller.hashCode)),
          ),
        ),
      );
    }
    // 未初始化或无 controller，显示黑色背景和加载状态
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
          // 顶部控制栏（返回/退出全屏按钮）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      // 返回按钮（全屏时退出全屏，非全屏时返回上一页）
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        iconSize: 28,
                        onPressed: () {
                          if (widget.isFullscreen?.call() ?? false) {
                            widget.onFullscreen?.call();
                          } else {
                            Navigator.of(context).maybePop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 中央播放控制（快退、播放/暂停、快进）
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 快退 10 秒
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white),
                    iconSize: 48,
                    onPressed: () {
                      final newPosition =
                          _player.currentPosition.value -
                          const Duration(seconds: 10);
                      _player.seekTo(
                        newPosition < Duration.zero
                            ? Duration.zero
                            : newPosition,
                      );
                    },
                  ),
                  const SizedBox(width: 32),
                  // 播放/暂停（中央大按钮）
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        _player.playbackState.value == PlaybackState.playing
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Colors.white,
                      ),
                      iconSize: 72,
                      onPressed: () {
                        if (_player.playbackState.value ==
                            PlaybackState.playing) {
                          _player.pause();
                        } else {
                          _player.resume();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 32),
                  // 快进 10 秒
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                    iconSize: 48,
                    onPressed: () {
                      final newPosition =
                          _player.currentPosition.value +
                          const Duration(seconds: 10);
                      _player.seekTo(
                        newPosition > _player.duration.value
                            ? _player.duration.value
                            : newPosition,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // 底部控制区域（进度条、音量、倍速、全屏）
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
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 底部按钮栏
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          // 音量控制
                          _buildVolumeControl(),
                          const SizedBox(width: 8),
                          // 倍速控制
                          _buildSpeedControl(),
                          const SizedBox(width: 8),
                          // 时间显示
                          Obx(() {
                            final position = _player.currentPosition.value;
                            final total = _player.duration.value;
                            return Text(
                              '${_formatDuration(position)} / ${_formatDuration(total)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            );
                          }),
                          const Spacer(),
                          // 全屏按钮
                          IconButton(
                            icon: Icon(
                              widget.isFullscreen?.call() ?? false
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                            ),
                            iconSize: 28,
                            onPressed: () {
                              widget.onFullscreen?.call();
                            },
                          ),
                        ],
                      ),
                    ),
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
        final positionRatio = total.inMilliseconds > 0
            ? (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;
        final bufferRatio = buffered.clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _CustomSeekBar(
            progress: positionRatio,
            buffered: bufferRatio,
            onSeek: (ratio) {
              final targetMs = (ratio * total.inMilliseconds).round();
              _player.seekTo(Duration(milliseconds: targetMs));
            },
          ),
        );
      }
      return const SizedBox.shrink();
    });
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

/// 自定义进度条组件，确保缓冲条与进度条形状完全一致
class _CustomSeekBar extends StatefulWidget {
  final double progress;
  final double buffered;
  final ValueChanged<double> onSeek;

  const _CustomSeekBar({
    required this.progress,
    required this.buffered,
    required this.onSeek,
  });

  @override
  State<_CustomSeekBar> createState() => _CustomSeekBarState();
}

class _CustomSeekBarState extends State<_CustomSeekBar> {
  static const double _trackHeight = 3.0;
  static const double _thumbRadius = 5.0;
  static const double _overlayRadius = 10.0;

  double _localProgress = 0.0;
  bool _isDragging = false;

  @override
  void didUpdateWidget(_CustomSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging) {
      _localProgress = widget.progress;
    }
  }

  @override
  void initState() {
    super.initState();
    _localProgress = widget.progress;
  }

  void _updateDragPosition(Offset localPosition, double width) {
    const trackLeft = _thumbRadius;
    final trackRight = width - _thumbRadius;
    final trackWidth = trackRight - trackLeft;

    if (trackWidth <= 0) return;

    double ratio = (localPosition.dx - trackLeft) / trackWidth;
    ratio = ratio.clamp(0.0, 1.0);
    _localProgress = ratio;
    widget.onSeek(ratio);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onHorizontalDragStart: (details) {
        _isDragging = true;
        final RenderBox box = context.findRenderObject() as RenderBox;
        final width = box.size.width;
        _updateDragPosition(details.localPosition, width);
        setState(() {});
      },
      onHorizontalDragUpdate: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final width = box.size.width;
        _updateDragPosition(details.localPosition, width);
        setState(() {});
      },
      onHorizontalDragEnd: (details) {
        _isDragging = false;
        setState(() {});
      },
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final width = box.size.width;
        _updateDragPosition(details.localPosition, width);
        setState(() {});
      },
      onTapUp: (details) {
        _isDragging = false;
        setState(() {});
      },
      child: SizedBox(
        height: _overlayRadius * 2,
        width: double.infinity,
        child: CustomPaint(
          painter: _SeekBarPainter(
            progress: _isDragging ? _localProgress : widget.progress,
            buffered: widget.buffered,
            trackHeight: _trackHeight,
            thumbRadius: _thumbRadius,
            primaryColor: primaryColor,
          ),
        ),
      ),
    );
  }
}

class _SeekBarPainter extends CustomPainter {
  final double progress;
  final double buffered;
  final double trackHeight;
  final double thumbRadius;
  final Color primaryColor;

  _SeekBarPainter({
    required this.progress,
    required this.buffered,
    required this.trackHeight,
    required this.thumbRadius,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final trackLeft = thumbRadius;
    final trackRight = size.width - thumbRadius;
    final trackWidth = trackRight - trackLeft;

    // 1. 背景轨道（未播放 + 未缓冲部分）
    final bgPaint = Paint()
      ..color = const Color(0x4DFFFFFF)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = trackHeight;
    canvas.drawLine(
      Offset(trackLeft, centerY),
      Offset(trackRight, centerY),
      bgPaint,
    );

    // 2. 缓冲条（与轨道完全一致的形状：相同高度、相同圆角）
    if (buffered > 0) {
      final bufferedRight = trackLeft + trackWidth * buffered;
      final bufferedPaint = Paint()
        ..color = const Color(0x88FFFFFF)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = trackHeight;
      canvas.drawLine(
        Offset(trackLeft, centerY),
        Offset(bufferedRight, centerY),
        bufferedPaint,
      );
    }

    // 3. 已播放部分（覆盖在缓冲条之上）
    if (progress > 0) {
      final progressRight = trackLeft + trackWidth * progress;
      final progressPaint = Paint()
        ..color = primaryColor
        ..strokeCap = StrokeCap.round
        ..strokeWidth = trackHeight;
      canvas.drawLine(
        Offset(trackLeft, centerY),
        Offset(progressRight, centerY),
        progressPaint,
      );
    }

    // 4. 圆形滑块
    final thumbX = trackLeft + trackWidth * progress;
    final thumbPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(thumbX, centerY), thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _SeekBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.buffered != buffered ||
        oldDelegate.primaryColor != primaryColor;
  }
}
