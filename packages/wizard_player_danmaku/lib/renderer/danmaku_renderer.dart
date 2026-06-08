import 'dart:async';
import 'package:flutter/material.dart';
import '../models/danmaku.dart';

/// 弹幕渲染器
class DanmakuRenderer extends StatefulWidget {
  /// 弹幕列表
  final List<Danmaku> danmakuList;

  /// 当前播放时间
  final double currentTime;

  /// 配置
  final DanmakuConfig config;

  /// 控制器
  final DanmakuController? controller;

  /// 播放器尺寸
  final Size playerSize;

  /// 字幕点击回调
  final void Function(Danmaku danmaku)? onDanmakuTap;

  const DanmakuRenderer({
    super.key,
    required this.danmakuList,
    required this.currentTime,
    required this.config,
    required this.playerSize,
    this.controller,
    this.onDanmakuTap,
  });

  @override
  State<DanmakuRenderer> createState() => DanmakuRendererState();
}

class DanmakuRendererState extends State<DanmakuRenderer> {
  // 显示中的弹幕
  final List<DanmakuWidget> _visibleDanmaku = [];

  // 滚动弹幕轨道
  final List<DanmakuTrack> _tracks = [];

  // 上次更新的时间
  double _lastTime = 0;

  // 弹幕计时器
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initTracks();
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _timer?.cancel();
    super.dispose();
  }

  void _initTracks() {
    // 根据播放器高度计算轨道数
    final trackCount = (widget.playerSize.height / 30).floor();
    for (var i = 0; i < trackCount; i++) {
      _tracks.add(DanmakuTrack(index: i));
    }
  }

  @override
  void didUpdateWidget(DanmakuRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 检测时间是否倒退
    if (widget.currentTime < _lastTime) {
      _clearAllDanmaku();
    }

    _lastTime = widget.currentTime;
    _updateVisibleDanmaku();
  }

  void _clearAllDanmaku() {
    setState(() {
      _visibleDanmaku.clear();
      for (final track in _tracks) {
        track.isOccupied = false;
        track.occupiedUntil = 0;
      }
    });
  }

  void _updateVisibleDanmaku() {
    if (!widget.config.enabled) return;

    // 找出当前时间应该显示的弹幕
    final showTime = widget.currentTime;
    const tolerance = 0.5; // 前后 0.5 秒的容差

    final newDanmaku = widget.danmakuList.where((d) {
      return (d.time >= showTime - tolerance) &&
          (d.time <= showTime + tolerance) &&
          !_visibleDanmaku.any((v) => v.danmaku.id == d.id);
    }).toList();

    // 添加新弹幕
    for (final danmaku in newDanmaku) {
      if (_visibleDanmaku.length >= widget.config.maxCount) break;

      final trackIndex = _findAvailableTrack(danmaku);
      if (trackIndex == -1) continue;

      _tracks[trackIndex].isOccupied = true;
      _tracks[trackIndex].occupiedUntil =
          showTime + _calculateDisplayTime(danmaku);

      setState(() {
        _visibleDanmaku.add(
          DanmakuWidget(
            danmaku: danmaku,
            trackIndex: trackIndex,
            config: widget.config,
            playerSize: widget.playerSize,
            onComplete: () => _removeDanmaku(danmaku.id),
            onTap: () => widget.onDanmakuTap?.call(danmaku),
          ),
        );
      });
    }

    // 移除已过期的弹幕
    _cleanupExpiredDanmaku(showTime);
  }

  int _findAvailableTrack(Danmaku danmaku) {
    if (danmaku.mode == DanmakuMode.top || danmaku.mode == DanmakuMode.bottom) {
      // 固定位置弹幕只需要一个轨道
      return 0;
    }

    // 滚动弹幕寻找空闲轨道
    final areaHeight = widget.playerSize.height * widget.config.area;
    final trackHeight = 30 * widget.config.fontSizeScale;

    for (var i = 0; i < (areaHeight / trackHeight).floor(); i++) {
      if (!_tracks[i].isOccupied ||
          _tracks[i].occupiedUntil <= widget.currentTime) {
        return i;
      }
    }

    return -1;
  }

  double _calculateDisplayTime(Danmaku danmaku) {
    // 根据弹幕长度和速度计算显示时间
    final textWidth = danmaku.text.length * danmaku.fontSize;
    final duration = textWidth / (150 * widget.config.scrollSpeed);
    return duration.clamp(3.0, 10.0);
  }

  void _removeDanmaku(String id) {
    setState(() {
      final index = _visibleDanmaku.indexWhere((d) => d.danmaku.id == id);
      if (index != -1) {
        final danmaku = _visibleDanmaku[index].danmaku;
        _visibleDanmaku.removeAt(index);

        // 释放轨道
        if (danmaku.mode == DanmakuMode.rolling) {
          for (final track in _tracks) {
            if (track.index == _visibleDanmaku[index].trackIndex) {
              track.isOccupied = false;
              break;
            }
          }
        }
      }
    });
  }

  /// 添加弹幕（供控制器调用）
  void _addDanmaku(Danmaku danmaku) {
    setState(() {
      if (_visibleDanmaku.length >= widget.config.maxCount) return;

      final trackIndex = _findAvailableTrack(danmaku);
      if (trackIndex == -1) return;

      _tracks[trackIndex].isOccupied = true;
      _tracks[trackIndex].occupiedUntil =
          widget.currentTime + _calculateDisplayTime(danmaku);

      _visibleDanmaku.add(
        DanmakuWidget(
          danmaku: danmaku,
          trackIndex: trackIndex,
          config: widget.config,
          playerSize: widget.playerSize,
          onComplete: () => _removeDanmaku(danmaku.id),
        ),
      );
    });
  }

  void _cleanupExpiredDanmaku(double currentTime) {
    setState(() {
      _visibleDanmaku.removeWhere((d) {
        if (d.startTime + d.displayDuration <= currentTime) {
          return true;
        }
        return false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: Stack(children: _visibleDanmaku));
  }
}

/// 单条弹幕 Widget
class DanmakuWidget extends StatefulWidget {
  final Danmaku danmaku;
  final int trackIndex;
  final DanmakuConfig config;
  final Size playerSize;
  final VoidCallback onComplete;
  final VoidCallback? onTap;

  late final double startTime;
  late final double displayDuration;

  DanmakuWidget({
    super.key,
    required this.danmaku,
    required this.trackIndex,
    required this.config,
    required this.playerSize,
    required this.onComplete,
    this.onTap,
  }) {
    final textWidth =
        danmaku.text.length * danmaku.fontSize * config.fontSizeScale;
    displayDuration = (textWidth / (150 * config.scrollSpeed)).clamp(3.0, 10.0);
    startTime = danmaku.time;
  }

  @override
  State<DanmakuWidget> createState() => _DanmakuWidgetState();
}

class _DanmakuWidgetState extends State<DanmakuWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _offsetX = 0;

  @override
  void initState() {
    super.initState();

    if (widget.danmaku.mode == DanmakuMode.rolling) {
      // 滚动弹幕
      _offsetX = widget.playerSize.width;
      final targetX = -widget.playerSize.width;

      _controller = AnimationController(
        duration: Duration(
          milliseconds: (widget.displayDuration * 1000).round(),
        ),
        vsync: this,
      );

      _animation =
          Tween<double>(begin: _offsetX, end: targetX).animate(
            CurvedAnimation(parent: _controller, curve: Curves.linear),
          )..addListener(() {
            setState(() {
              _offsetX = _animation.value;
            });
          });

      _controller.forward().then((_) => widget.onComplete());
    } else {
      // 固定位置弹幕
      _controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );

      _animation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

      _controller.forward().then((_) {
        // 显示一段时间后消失
        Future.delayed(
          Duration(
            milliseconds: ((widget.displayDuration - 0.5) * 1000).round(),
          ),
          () {
            if (mounted) {
              _controller.reverse().then((_) => widget.onComplete());
            }
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textWidget = GestureDetector(
      onTap: widget.onTap,
      child: Text(
        widget.danmaku.text,
        style: TextStyle(
          color: widget.danmaku.color.withValues(alpha: widget.config.opacity),
          fontSize: widget.danmaku.fontSize * widget.config.fontSizeScale,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black),
          ],
        ),
      ),
    );

    double left = 0;
    double top = 0;

    switch (widget.danmaku.mode) {
      case DanmakuMode.rolling:
        left = _offsetX;
        top =
            widget.trackIndex * 30 * widget.config.fontSizeScale +
            (widget.playerSize.height * (1 - widget.config.area)) / 2;
        break;
      case DanmakuMode.top:
        left =
            (widget.playerSize.width -
                _measureText(widget.danmaku.text, widget.danmaku.fontSize)) /
            2;
        top = widget.trackIndex * 30 * widget.config.fontSizeScale;
        break;
      case DanmakuMode.bottom:
        left =
            (widget.playerSize.width -
                _measureText(widget.danmaku.text, widget.danmaku.fontSize)) /
            2;
        top =
            widget.playerSize.height -
            (widget.trackIndex + 1) * 30 * widget.config.fontSizeScale;
        break;
      case DanmakuMode.special:
        left = _offsetX;
        top = widget.trackIndex * 30 * widget.config.fontSizeScale;
        break;
    }

    return Positioned(left: left, top: top, child: textWidget);
  }

  double _measureText(String text, double fontSize) {
    return text.length * fontSize * widget.config.fontSizeScale * 0.6;
  }
}

/// 弹幕控制器
class DanmakuController {
  DanmakuRendererState? _state;

  void _attach(DanmakuRendererState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  /// 发送弹幕
  void sendDanmaku(Danmaku danmaku) {
    _state?._addDanmaku(danmaku);
  }

  /// 清空所有弹幕
  void clearAll() {
    _state?._clearAllDanmaku();
  }

  /// 隐藏/显示弹幕
  void setVisible(bool visible) {
    // 可以通过配置控制
  }
}
