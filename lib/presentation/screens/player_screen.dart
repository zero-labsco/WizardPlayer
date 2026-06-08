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

  @override
  void initState() {
    super.initState();

    // 初始化 ViewModel
    _viewModel = PlayerViewModel(
      Get.find<PlayHistoryRepository>(),
      Get.find<VideoRepository>(),
      Get.find<WizardPlayerTorrent>(),
    );

    // 监听屏幕方向
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          return _isFullScreen
              ? _buildFullScreenPlayer()
              : _buildNormalPlayer(isDesktop);
        }),
      ),
    );
  }

  /// 普通模式播放器
  Widget _buildNormalPlayer(bool isDesktop) {
    return Column(
      children: [
        // 播放器区域
        AspectRatio(
          aspectRatio: 16 / 9,
          child: WizardPlayerWidget(player: _viewModel.player),
        ),
        // 集数选择
        Expanded(child: _buildEpisodeSelector(isDesktop)),
      ],
    );
  }

  /// 全屏模式播放器
  Widget _buildFullScreenPlayer() {
    return Stack(
      children: [
        // 播放器
        Positioned.fill(child: WizardPlayerWidget(player: _viewModel.player)),
        // 集数选择（底部弹出）
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildFullScreenEpisodeSelector(),
        ),
      ],
    );
  }

  /// 集数选择器（普通模式）
  Widget _buildEpisodeSelector(bool isDesktop) {
    return GetBuilder<PlayerViewModel>(
      id: 'player',
      init: _viewModel,
      builder: (_) {
        final episodes = _viewModel.currentVideo?.episodes ?? [];
        final currentEpisode = _viewModel.currentEpisode;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_viewModel.currentVideo?.title ?? ''} - 第 ${currentEpisode?.episodeNumber ?? 1} 集',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: _toggleFullScreen,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 10 : 6,
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
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${episode.episodeNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : null,
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

  /// 全屏模式集数选择器
  Widget _buildFullScreenEpisodeSelector() {
    return GetBuilder<PlayerViewModel>(
      id: 'player',
      init: _viewModel,
      builder: (_) {
        final episodes = _viewModel.currentVideo?.episodes ?? [];
        final currentEpisode = _viewModel.currentEpisode;

        return Container(
          height: 200,
          color: Colors.black.withValues(alpha: 0.9),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
              final isCurrent =
                  episode.episodeNumber == currentEpisode?.episodeNumber;

              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => _viewModel.playEpisode(episode.episodeNumber),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${episode.episodeNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? Colors.white
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
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
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }
}
