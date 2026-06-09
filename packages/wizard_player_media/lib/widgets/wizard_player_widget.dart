import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../player/wizard_player.dart';
import '../player/media_kit_impl.dart';
import '../player/playback_state.dart';

/// 视频播放器 Widget（基于 media_kit + libmpv 后端）
///
/// 两套布局：
/// 1. 全屏模式 (isFullscreen == true)
///    overlay 布局：控件覆盖在视频上
/// 2. 非全屏模式 (isFullscreen == false)
///    视频在外边框内，返回按钮在外边框左上角，进度条/时间/全屏按钮在外边框下方
class WizardPlayerWidget extends StatefulWidget {
  final WizardPlayer? player;
  final String? initialUri;
  final bool showControls;
  final bool autoPlay;
  final VoidCallback? onFullscreen;
  final bool Function()? isFullscreen;
  final bool showProgressBar;

  const WizardPlayerWidget({
    super.key,
    this.player,
    this.initialUri,
    this.showControls = true,
    this.autoPlay = false,
    this.onFullscreen,
    this.isFullscreen,
    this.showProgressBar = true,
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

  @override
  void initState() {
    super.initState();
    _player = widget.player ?? MediaKitWizard();
    _initPlayer();
  }

  @override
  void didUpdateWidget(WizardPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.player != null && widget.player != _player) {
      if (oldWidget.player == null) {
        _player.release();
      }
      _player = widget.player!;
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
  }

  /// 获取 media_kit 的底层 Player（供 Video 渲染用）
  Player? _getPlatformPlayer() {
    return _player.getPlatformPlayer<Player>();
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
    if (widget.player == null) {
      _player.release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFullscreenMode = widget.isFullscreen?.call() ?? false;

    // 用 Obx 监听播放状态：controller 从 null 变为就绪时会触发重建
    return Obx(() {
      // 每次状态变化时重新获取底层 player
      final platformPlayer = _getPlatformPlayer();
      _player.playbackState.value; // 监听，触发重建

      if (isFullscreenMode) {
        return _buildFullscreenLayout(platformPlayer);
      }

      return _buildCompactLayout(platformPlayer);
    });
  }

  // ───────────────────────────────────────────────────
  // 全屏模式：SizedBox.expand → Stack → overlay
  // ───────────────────────────────────────────────────
  Widget _buildFullscreenLayout(Player? platformPlayer) {
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
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildVideoSurface(platformPlayer),
            if (platformPlayer == null)
              Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: Colors.white30,
                  ),
                ),
              ),
            // Loading
            Obx(() {
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
            }),
            // 快进提示
            if (_isHorizontalDragging) _buildSeekIndicator(),
            // 控制栏 overlay
            if (widget.showControls) _buildFullscreenControlsOverlay(),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────
  // 非全屏模式：视频(带留白) + 控件区两行（进度条在上，按钮在下）
  // ───────────────────────────────────────────────────
  Widget _buildCompactLayout(Player? platformPlayer) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── 视频区域：水平留白 + 16:9比例 + 圆角裁剪 + 手势 ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
              clipBehavior: Clip.antiAlias,
              child: GestureDetector(
                onTap: _toggleControls,
                onDoubleTap: () {
                  if (_player.playbackState.value == PlaybackState.playing) {
                    _player.pause();
                  } else {
                    _player.resume();
                  }
                },
                onHorizontalDragStart: _onHorizontalDragStart,
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 视频画面：按原始比例居中显示
                    _buildVideoSurface(platformPlayer),
                    // Loading
                    Obx(() {
                      if (_player.isBuffering.value ||
                          _player.playbackState.value ==
                              PlaybackState.loading) {
                        return Container(
                          color: Colors.black26,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    // 快进提示
                    if (_isHorizontalDragging) _buildSeekIndicator(),
                    // 返回按钮：视频区域左上角
                    if (_controlsVisible)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          iconSize: 24,
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // ─── 控件行1：进度条（占满整行宽度） ───
        if (widget.showProgressBar)
          SizedBox(
            height: 28,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildProgressBar(),
            ),
          ),
        // ─── 控件行2：播放/暂停、音量、倍速、时间、全屏按钮 ───
        if (_controlsVisible)
          SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 播放/暂停
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        _player.playbackState.value == PlaybackState.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      iconSize: 28,
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
                  const SizedBox(width: 8),
                  _buildVolumeControl(),
                  const SizedBox(width: 4),
                  _buildSpeedControl(),
                  const Spacer(),
                  Obx(() {
                    final position = _player.currentPosition.value;
                    final total = _player.duration.value;
                    return Text(
                      '${_formatDuration(position)} / ${_formatDuration(total)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    );
                  }),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    iconSize: 24,
                    onPressed: widget.onFullscreen,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ───────────────────────────────────────────────────
  // 视频画面：用 media_kit 的 Video widget 渲染底层 Player
  // ───────────────────────────────────────────────────
  Widget _buildVideoSurface(Player? platformPlayer) {
    if (platformPlayer != null) {
      // media_kit 的 Video 会根据视频原始比例自适应
      return Video(
        controller: VideoController(platformPlayer),
        fill: Colors.black,
      );
    }
    return Container(color: Colors.black);
  }

  // ───────────────────────────────────────────────────
  // 全屏模式的控制栏 overlay（保持原有 overlay 样式）
  // ───────────────────────────────────────────────────
  Widget _buildFullscreenControlsOverlay() {
    return AnimatedOpacity(
      opacity: _controlsVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 顶部控制栏
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        iconSize: 28,
                        onPressed: () {
                          widget.onFullscreen?.call();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 中央播放控制
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          _buildVolumeControl(),
                          const SizedBox(width: 8),
                          _buildSpeedControl(),
                          const SizedBox(width: 8),
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
                          IconButton(
                            icon: const Icon(
                              Icons.fullscreen_exit,
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
                    if (widget.showProgressBar) _buildProgressBar(),
                  ],
                ),
              ),
            ),
          ),
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

  // ───────────────────────────────────────────────────
  // 滑动快进手势处理
  // ───────────────────────────────────────────────────
  void _onHorizontalDragStart(DragStartDetails details) {
    if (!widget.showControls) return;
    _isHorizontalDragging = true;
    _horizontalDragDelta = 0;
    _dragStartPosition = _player.currentPosition.value;
    _cancelHideSeekTextTimer();
    setState(() {});
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.showControls || !_isHorizontalDragging) return;
    _horizontalDragDelta += details.delta.dx;
    final screenWidth = context.size?.width ?? 1.0;
    final secondsDelta = (_horizontalDragDelta / screenWidth) * 60;
    final newPosition =
        _dragStartPosition! + Duration(seconds: secondsDelta.toInt());
    final total = _player.duration.value;
    final clampedPosition = Duration(
      milliseconds: newPosition.inMilliseconds.clamp(0, total.inMilliseconds),
    );
    final diff = clampedPosition - _dragStartPosition!;
    final sign = diff.isNegative ? '-' : '+';
    _dragSeekText =
        '$sign${_formatDuration(diff.abs())} / ${_formatDuration(clampedPosition)}';
    setState(() {});
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!widget.showControls || !_isHorizontalDragging) return;
    _isHorizontalDragging = false;
    final screenWidth = context.size?.width ?? 1.0;
    final secondsDelta = (_horizontalDragDelta / screenWidth) * 60;
    final newPosition =
        _dragStartPosition! + Duration(seconds: secondsDelta.toInt());
    final total = _player.duration.value;
    final clampedPosition = Duration(
      milliseconds: newPosition.inMilliseconds.clamp(0, total.inMilliseconds),
    );
    _player.seekTo(clampedPosition);
    _startHideSeekTextTimer();
    setState(() {});
  }
}

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
        _updateDragPosition(details.localPosition, box.size.width);
        setState(() {});
      },
      onHorizontalDragUpdate: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        _updateDragPosition(details.localPosition, box.size.width);
        setState(() {});
      },
      onHorizontalDragEnd: (details) {
        _isDragging = false;
        setState(() {});
      },
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        _updateDragPosition(details.localPosition, box.size.width);
        setState(() {});
      },
      onTapUp: (details) {
        _isDragging = false;
        setState(() {});
      },
      child: SizedBox(
        height: _thumbRadius * 2 + 4,
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

    final bgPaint = Paint()
      ..color = const Color(0x4DFFFFFF)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = trackHeight;
    canvas.drawLine(
      Offset(trackLeft, centerY),
      Offset(trackRight, centerY),
      bgPaint,
    );

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
