import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'wizard_player_widget.dart';
import '../player/wizard_player.dart';

/// 全屏播放器 Route
///
/// 1. 独立的 Route 承载全屏播放器
/// 2. **复用外部传入的 WizardPlayer**（即同一个 VideoPlayerController 实例）
/// 3. Route 内部是全新的 WizardPlayerWidget，但 controller 不变
/// 4. Route 进入/退出时管理系统方向和 UI 模式
///
/// 为什么用独立 Route 而不是本地布局变化？
/// - 本地布局变化（SizedBox 变全屏）会让同一个 VideoPlayer Widget 经历
///   约束剧烈变化，可能触发 native texture 重建
/// - 独立 Route 中，VideoPlayer 是全新实例，但绑定同一个 controller，
///   Flutter 框架会正确处理 texture 的 attach/detach
/// - Route 的动画是 Flutter 框架层的，和 native 播放器生命周期解耦
class FullscreenPlayerRoute extends StatefulWidget {
  final WizardPlayer player;
  final FullscreenMode mode;

  const FullscreenPlayerRoute({
    super.key,
    required this.player,
    this.mode = FullscreenMode.window,
  });

  @override
  State<FullscreenPlayerRoute> createState() => _FullscreenPlayerRouteState();
}

class _FullscreenPlayerRouteState extends State<FullscreenPlayerRoute> {
  final FocusNode _focusNode = FocusNode();
  // 保存原始窗口全屏状态，用于退出时恢复
  bool _wasFullScreen = false;

  @override
  void initState() {
    super.initState();
    // 进入全屏：横屏 + 沉浸式（不显示状态栏/导航栏）
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // 延迟请求焦点以确保键盘事件能被捕获
    Timer(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });

    // 执行桌面端全屏操作
    _enterFullscreen();
  }

  /// 进入全屏模式
  /// - 屏幕全屏：使用系统级全屏 API，真正占据整个屏幕
  /// - 窗口全屏：仅使用应用内全屏 Route，保留窗口边框
  Future<void> _enterFullscreen() async {
    try {
      // 保存原始窗口状态
      _wasFullScreen = await windowManager.isFullScreen();

      if (widget.mode == FullscreenMode.screen) {
        // 屏幕全屏：真正的系统级全屏，无窗口边框
        await windowManager.setFullScreen(true);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      } else {
        // 窗口全屏：应用内全屏 Route（保留窗口边框）
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    } catch (_) {
      // 忽略窗口管理操作的错误（在不支持的平台上）
    }
  }

  /// 退出全屏模式，恢复原始窗口状态
  Future<void> _exitFullscreen() async {
    try {
      if (widget.mode == FullscreenMode.screen) {
        // 恢复屏幕全屏前的状态
        await windowManager.setFullScreen(_wasFullScreen);
      }
    } catch (_) {
      // 忽略窗口管理操作的错误（在不支持的平台上）
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    // 退出全屏：恢复竖屏 + 正常系统 UI
    // controller 不 dispose，调用方负责（回到非全屏继续播放）
    _exitFullscreen();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// 处理键盘事件
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // ESC键：退出全屏
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    // ═══════════════════════════════════════════════════════════
    // 核心：WizardPlayerWidget 是全新实例，但传入同一个 player
    // 这意味着 VideoPlayer(controller) 是新 Widget，却绑定同一个 controller
    // Flutter 会正确处理 texture attach — 这是 chewie/better_player 的做法
    // ═══════════════════════════════════════════════════════════
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: SizedBox.expand(
          child: WizardPlayerWidget(
            key: const ValueKey('fullscreen_player'),
            player: widget.player,
            showControls: true,
            showAlwaysControls: false, // 允许控制栏自动隐藏
            onFullscreen: () {
              // 点击全屏按钮 = 退出 Route
              Navigator.of(context).maybePop();
            },
            isFullscreen: () => true,
          ),
        ),
      ),
    );
  }
}

/// 全屏模式枚举
enum FullscreenMode {
  /// 窗口全屏：应用内全屏 Route，保留窗口边框和标题栏
  window,

  /// 屏幕全屏：真正的系统级全屏，无窗口边框，独占整个屏幕
  screen,
}

/// 启动全屏播放器的工具方法
Future<void> showFullScreenPlayer(
  BuildContext context,
  WizardPlayer player, {
  FullscreenMode mode = FullscreenMode.window,
}) async {
  await Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          FullscreenPlayerRoute(player: player, mode: mode),
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      opaque: true,
      fullscreenDialog: false,
      barrierColor: Colors.black,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    ),
  );
}
