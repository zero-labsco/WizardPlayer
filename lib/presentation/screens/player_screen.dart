import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wizard_player_datasource/wizard_player_datasource.dart';
import 'package:wizard_player_media/wizard_player_media.dart';
import 'package:wizard_player_torrent/wizard_player_torrent.dart';
import 'package:wizardplayer/presentation/viewmodels/player_viewmodel.dart';
import 'package:wizardplayer/core/abstractions/di.dart';
import 'package:wizardplayer/data/repositories/video_repository.dart';
import 'package:wizardplayer/data/repositories/play_history_repository.dart';
import 'package:wizardplayer/core/l10n/app_localizations.dart';
import 'package:wizardplayer/core/theme/app_colors.dart';

/// 播放器页面
///
/// 1. 非全屏模式：本地布局 + WizardPlayerWidget
/// 2. 全屏模式：push 独立的 FullscreenPlayerRoute，传入同一个 player
/// 3. Player（controller）实例在整个生命周期中保持不变
/// 4. VideoPlayer Widget 在不同 Route 中是不同实例，但绑定同一个 controller
/// 5. 桌面端：支持键盘快捷键、桌面控制栏、右侧选集面板
class PlayerScreen extends StatefulWidget {
  final VideoInfo video;
  final int? startEpisode;
  final int? startPosition;

  const PlayerScreen({
    super.key,
    required this.video,
    this.startEpisode,
    this.startPosition,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlayerViewModel _viewModel;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _viewModel = PlayerViewModel(
      DI.get<PlayHistoryRepository>(),
      DI.get<VideoRepository>(),
      DI.get<WizardPlayerTorrent>(),
    );
    _viewModel.initPlayer(
      widget.video,
      widget.startEpisode,
      startPosition: widget.startPosition,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _viewModel.onClose();
    super.dispose();
  }

  /// 处理键盘事件
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final player = _viewModel.player;
    final isPlaying = player.playbackState.value == PlaybackState.playing;

    // 空格键：播放/暂停
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (isPlaying) {
        player.pause();
      } else {
        player.resume();
      }
      return KeyEventResult.handled;
    }

    // 左方向键：快退 10 秒
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final newPosition =
          player.currentPosition.value - const Duration(seconds: 10);
      player.seekTo(newPosition.isNegative ? Duration.zero : newPosition);
      return KeyEventResult.handled;
    }

    // 右方向键：快进 10 秒
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final newPosition =
          player.currentPosition.value + const Duration(seconds: 10);
      final maxPosition = player.duration.value;
      player.seekTo(newPosition > maxPosition ? maxPosition : newPosition);
      return KeyEventResult.handled;
    }

    // 上方向键：增加音量
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      final newVolume = (player.volume.value + 0.1).clamp(0.0, 1.0);
      player.setVolume(newVolume);
      return KeyEventResult.handled;
    }

    // 下方向键：减少音量
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      final newVolume = (player.volume.value - 0.1).clamp(0.0, 1.0);
      player.setVolume(newVolume);
      return KeyEventResult.handled;
    }

    // F 键：切换全屏
    if (event.logicalKey == LogicalKeyboardKey.keyF) {
      _toggleFullScreen();
      return KeyEventResult.handled;
    }

    // Esc 键：退出全屏（由全屏路由处理）
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final statusBarHeight = mediaQuery.padding.top;

    // 播放器背景色：使用 AppColors 统一管理
    final playerBackgroundColor = AppColors.getPlayerBackground(
      Theme.of(context).brightness,
    );

    // 判断是否为桌面端（宽度 >= 800 视为桌面端）
    final isDesktop = screenWidth >= 800;

    if (isDesktop) {
      return _buildDesktopLayout(
        context,
        screenWidth,
        statusBarHeight,
        playerBackgroundColor,
      );
    } else {
      return _buildMobileLayout(
        context,
        screenWidth,
        statusBarHeight,
        playerBackgroundColor,
      );
    }
  }

  /// 构建桌面端布局：左侧视频+控制栏，右侧选集面板
  Widget _buildDesktopLayout(
    BuildContext context,
    double screenWidth,
    double statusBarHeight,
    Color playerBackgroundColor,
  ) {
    // 右侧选集面板宽度：响应式计算（最小200，最大320，占屏幕25%）
    final sidePanelWidth = (screenWidth * 0.25).clamp(200.0, 320.0);

    // 控制栏高度
    const controlsHeight = 48.0;

    return Scaffold(
      backgroundColor: playerBackgroundColor,
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Column(
          children: [
            // 顶部栏：返回按钮（桌面端固定高度 48px，确保可见）
            Container(
              height: 48,
              color: playerBackgroundColor,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '返回',
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // 主内容区：视频 + 控制栏 + 选集面板
            Expanded(
              child: Row(
                children: [
                  // 左侧：视频区域 + 控制栏
                  Expanded(
                    child: Column(
                      children: [
                        // 视频播放器（禁用内置控件）
                        Expanded(
                          child: Container(
                            color: Colors.black,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                WizardPlayerWidget(
                                  player: _viewModel.player,
                                  onFullscreen: _toggleFullScreen,
                                  isFullscreen: () => false,
                                  showControls: false,
                                  showProgressBar: false,
                                ),
                                // 暂停时显示半透明播放按钮
                                Obx(() {
                                  final isPlaying =
                                      _viewModel.player.playbackState.value ==
                                          PlaybackState.playing;
                                  if (!isPlaying) {
                                    return Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(60),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                          iconSize: 60,
                                          onPressed: () =>
                                              _viewModel.player.resume(),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
                            ),
                          ),
                        ),
                        // 桌面端控制栏
                        Container(
                          height: controlsHeight,
                          color: playerBackgroundColor,
                          child: _buildDesktopControls(
                            context,
                            playerBackgroundColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 右侧：选集面板
                  SizedBox(
                    width: sidePanelWidth,
                    child: _buildEpisodeSelector(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建桌面端控制栏
  Widget _buildDesktopControls(BuildContext context, Color backgroundColor) {
    final player = _viewModel.player;

    return Container(
      color: backgroundColor.withValues(alpha: 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 播放/暂停按钮
          Obx(() {
            final isPlaying =
                player.playbackState.value == PlaybackState.playing;
            return IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                if (isPlaying) {
                  player.pause();
                } else {
                  player.resume();
                }
              },
              tooltip: isPlaying ? '暂停' : '播放',
            );
          }),

          // 上一集
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.skip_previous,
                color: _viewModel.hasPreviousEpisode
                    ? Colors.white
                    : Colors.white38,
                size: 24,
              ),
              onPressed: _viewModel.hasPreviousEpisode
                  ? _viewModel.previousEpisode
                  : null,
              tooltip: '上一集',
            ),
          ),

          // 下一集
          Obx(
            () => IconButton(
              icon: Icon(
                Icons.skip_next,
                color: _viewModel.hasNextEpisode
                    ? Colors.white
                    : Colors.white38,
                size: 24,
              ),
              onPressed: _viewModel.hasNextEpisode
                  ? _viewModel.nextEpisode
                  : null,
              tooltip: '下一集',
            ),
          ),

          const SizedBox(width: 8),

          // 当前时间
          Obx(() {
            final position = player.currentPosition.value;
            return Text(
              _formatDuration(position),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            );
          }),

          const SizedBox(width: 8),

          // 进度条
          Expanded(
            child: Obx(() {
              final position = player.currentPosition.value;
              final duration = player.duration.value;
              final progress = duration.inMilliseconds > 0
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0;

              return SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
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
                  value: progress.clamp(0.0, 1.0),
                  onChanged: (value) {
                    final newPosition = Duration(
                      milliseconds: (value * duration.inMilliseconds).round(),
                    );
                    player.seekTo(newPosition);
                  },
                ),
              );
            }),
          ),

          const SizedBox(width: 8),

          // 总时长
          Obx(() {
            final duration = player.duration.value;
            return Text(
              _formatDuration(duration),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            );
          }),

          const SizedBox(width: 16),

          // 音量控制
          Obx(() {
            final volume = player.volume.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  volume == 0
                      ? Icons.volume_off
                      : (volume < 0.5 ? Icons.volume_down : Icons.volume_up),
                  color: Colors.white70,
                  size: 20,
                ),
                SizedBox(
                  width: 80,
                  child: SliderTheme(
                    data: const SliderThemeData(
                      trackHeight: 3,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
                      activeTrackColor: Colors.white70,
                      inactiveTrackColor: Colors.white30,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: volume,
                      onChanged: (value) => player.setVolume(value),
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(width: 8),

          // 播放速度控制
          Obx(() {
            final speed = player.playbackSpeed.value;
            return PopupMenuButton<double>(
              initialValue: speed,
              onSelected: (value) => player.setPlaybackSpeed(value),
              tooltip: '播放速度',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${speed}x',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                const PopupMenuItem(value: 2.0, child: Text('2.0x')),
              ],
            );
          }),

          const SizedBox(width: 8),

          // 全屏按钮
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white, size: 24),
            onPressed: _toggleFullScreen,
            tooltip: '全屏 (F)',
          ),
        ],
      ),
    );
  }

  /// 构建移动端布局：视频在上，选集在下
  Widget _buildMobileLayout(
    BuildContext context,
    double screenWidth,
    double statusBarHeight,
    Color playerBackgroundColor,
  ) {
    // 视频区域内部宽度（减去左右留白 16*2）
    final videoInnerWidth = screenWidth - 32;
    // 视频高度：16:9
    final videoHeight = videoInnerWidth * 9 / 16;
    // 控件区域高度：进度条行(28) + 按钮行(48)
    const controlsHeight = 76.0;
    // 播放器总高度 = 视频高度 + 控件区域
    final playerHeight = videoHeight + controlsHeight;

    return Scaffold(
      backgroundColor: playerBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ──────────────────────────────────────────────────────
          // 1. 播放器：视频(16:9) + 进度条 + 按钮行，从状态栏下方开始
          // ──────────────────────────────────────────────────────
          Positioned(
            top: statusBarHeight,
            left: 0,
            right: 0,
            height: playerHeight,
            child: WizardPlayerWidget(
              player: _viewModel.player,
              onFullscreen: _toggleFullScreen,
              isFullscreen: () => false,
            ),
          ),

          // ──────────────────────────────────────────────────────
          // 2. 集数选择器：从播放器下方开始，到屏幕底部
          // ──────────────────────────────────────────────────────
          Positioned(
            top: statusBarHeight + playerHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildEpisodeSelector(),
          ),

          // ──────────────────────────────────────────────────────
          // 3. Loading overlay：仅在视频源加载时显示
          // ──────────────────────────────────────────────────────
          Obx(() {
            if (_viewModel.isLoading) {
              return Container(
                color: playerBackgroundColor.withValues(alpha: 0.54),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildEpisodeSelector() {
    final brightness = Theme.of(context).brightness;
    final playerBackgroundColor = AppColors.getPlayerBackground(brightness);
    final l10n = AppLocalizations.of(context)!;

    return GetBuilder<PlayerViewModel>(
      id: 'player',
      init: _viewModel,
      builder: (_) {
        final episodes = _viewModel.currentVideo?.episodes ?? [];
        final currentEpisode = _viewModel.currentEpisode;

        return Container(
          color: playerBackgroundColor,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_viewModel.currentVideo?.title ?? ''} - ${l10n.episodeNumber(currentEpisode?.episodeNumber ?? 1)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: brightness == Brightness.dark
                      ? null
                      : AppColors.white70,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    final episode = episodes[index];
                    final isCurrent =
                        episode.episodeNumber == currentEpisode?.episodeNumber;

                    return InkWell(
                      onTap: () =>
                          _viewModel.playEpisode(episode.episodeNumber),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : (brightness == Brightness.dark
                                    ? AppColors.grey800
                                    : AppColors.grey700),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${episode.episodeNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCurrent
                                  ? AppColors.white54
                                  : (brightness == Brightness.dark
                                        ? AppColors.white70
                                        : AppColors.white60),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 格式化时长
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 切换全屏
  ///
  /// push 一个独立的全屏 Route，传入同一个 player 实例
  /// Route 内部会：
  /// - 创建全新的 WizardPlayerWidget（绑定同一个 controller）
  /// - 设置横屏 + 沉浸式 UI
  /// pop Route 后，回到这里，原有的 WizardPlayerWidget 继续渲染
  void _toggleFullScreen() {
    showFullScreenPlayer(context, _viewModel.player);
  }
}
