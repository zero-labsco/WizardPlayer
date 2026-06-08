import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wizard_player_datasource/wizard_player_datasource.dart';
import 'package:wizard_player_media/wizard_player_media.dart';
import 'package:wizard_player_torrent/wizard_player_torrent.dart';
import 'package:wizardplayer/presentation/viewmodels/player_viewmodel.dart';
import 'package:wizardplayer/data/repositories/video_repository.dart';
import 'package:wizardplayer/data/repositories/play_history_repository.dart';

/// 播放器页面
class PlayerScreen extends StatefulWidget {
  final VideoInfo video;
  final int? startEpisode;

  const PlayerScreen({super.key, required this.video, this.startEpisode});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlayerViewModel _viewModel;
  bool _isFullScreen = false;
  // GlobalKey 用于保持 WizardPlayerWidget 的 State 不被重建
  final GlobalKey _playerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _viewModel = PlayerViewModel(
      Get.find<PlayHistoryRepository>(),
      Get.find<VideoRepository>(),
      Get.find<WizardPlayerTorrent>(),
    );

    // 初始化播放器
    _viewModel.initPlayer(widget.video, widget.startEpisode);
  }

  @override
  void dispose() {
    _viewModel.onClose();

    // 恢复屏幕设置
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // 非全屏模式下：播放器从状态栏下方开始，严格 16:9 比例
    final topPadding = _isFullScreen ? 0.0 : mediaQuery.padding.top;
    // 16:9 比例计算高度
    final basePlayerHeight = screenWidth * 9 / 16;
    // 最大不超过可用高度的 50%（非全屏模式）
    final maxPlayerHeight =
        (screenHeight - topPadding - mediaQuery.padding.bottom) * 0.5;
    final finalPlayerHeight = basePlayerHeight < maxPlayerHeight
        ? basePlayerHeight
        : maxPlayerHeight;

    // 全屏模式：播放器占满整个屏幕
    final playerHeight = _isFullScreen ? screenHeight : finalPlayerHeight;
    final playerTop = _isFullScreen ? 0.0 : topPadding;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (_viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        // 核心：播放器用 GlobalKey 保持 State 不被重建
        // height 只影响 layout，不影响播放器控制器本身
        return Stack(
          fit: StackFit.expand,
          children: [
            // 播放器：高度随全屏状态变化，GlobalKey 保证 WizardPlayerWidget 的 State 保持不变
            // （同一个 key + 同一个位置 = State 复用，VideoPlayerController 不被销毁）
            Positioned(
              top: playerTop,
              left: 0,
              right: 0,
              child: SizedBox(
                height: playerHeight,
                child: WizardPlayerWidget(
                  key: _playerKey,
                  player: _viewModel.player,
                  onFullscreen: _toggleFullScreen,
                  isFullscreen: () => _isFullScreen,
                ),
              ),
            ),
            // 非全屏模式：集数选择器（从播放器下方开始，背景为黑色遮挡）
            if (!_isFullScreen)
              Positioned(
                top: topPadding + finalPlayerHeight,
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildEpisodeSelector(),
              ),
          ],
        );
      }),
    );
  }

  /// 集数选择器
  Widget _buildEpisodeSelector() {
    return GetBuilder<PlayerViewModel>(
      id: 'player',
      init: _viewModel,
      builder: (_) {
        final episodes = _viewModel.currentVideo?.episodes ?? [];
        final currentEpisode = _viewModel.currentEpisode;

        return Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_viewModel.currentVideo?.title ?? ''} - 第 ${currentEpisode?.episodeNumber ?? 1} 集',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white),
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
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${episode.episodeNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : Colors.white70,
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

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      // 进入全屏：切换到横屏，隐藏系统 UI
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // 退出全屏：恢复竖屏方向和系统 UI
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
}
