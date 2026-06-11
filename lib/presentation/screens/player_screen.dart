import 'package:flutter/material.dart';
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
    _viewModel.onClose();
    super.dispose();
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

    // 视频区域内部宽度（减去左右留白 16*2）
    final videoInnerWidth = screenWidth - 32;
    // 视频高度：16:9
    final videoHeight = videoInnerWidth * 9 / 16;
    // 控件区域高度：进度条行(28) + 按钮行(48)
    const controlsHeight = 76.0;
    // 播放器总高度 = 视频高度 + 控件区域
    final playerHeight = videoHeight + controlsHeight;

    // ═════════════════════════════════════════════════════════════
    // 布局：
    // 顶部：视频区域(16:9，有留白) + 进度条行 + 按钮行（从状态栏下方开始）
    // 下方：集数选择器
    // ═════════════════════════════════════════════════════════════
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
