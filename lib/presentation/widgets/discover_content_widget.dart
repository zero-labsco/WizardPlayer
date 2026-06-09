import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wizardplayer/core/l10n/app_localizations.dart';
import 'package:wizardplayer/core/theme/app_colors.dart';
import 'package:wizardplayer/data/repositories/play_history_repository.dart';
import 'package:wizardplayer/presentation/screens/search_screen.dart';
import 'package:wizardplayer/presentation/screens/player_screen.dart';
import 'package:wizard_player_datasource/wizard_player_datasource.dart';

/// 发现页面内容组件
class DiscoverContentWidget extends StatelessWidget {
  const DiscoverContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索框
          GestureDetector(
            onTap: () {
              Get.to(() => const SearchScreen());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Theme.of(context).hintColor),
                  const SizedBox(width: 8),
                  Text(
                    l10n.searchPlaceholder,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 测试视频
          _TestVideoSection(),
          const SizedBox(height: 32),

          // 分类
          _CategorySection(),
        ],
      ),
    );
  }
}

/// 测试视频区域
class _TestVideoSection extends StatefulWidget {
  const _TestVideoSection();

  @override
  State<_TestVideoSection> createState() => _TestVideoSectionState();
}

class _TestVideoSectionState extends State<_TestVideoSection> {
  Future<void> _playTestVideo(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    // 获取上次播放的集数
    int startEpisode = 1;
    try {
      final historyRepo = Get.find<PlayHistoryRepository>();
      final history = await historyRepo.getHistoryByVideoId('test_video_001');
      if (history != null) {
        startEpisode = history.episodeNumber;
      }
    } catch (e) {
      // 使用默认的第1集
    }

    final testVideo = VideoInfo(
      id: 'test_video_001',
      title: l10n.testVideo,
      subtitle: l10n.testVideoDescription,
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/220px-Big_buck_bunny_poster_big.jpg',
      sourceType: 'test',
      episodes: [
        const EpisodeInfo(
          id: 'test_ep_001',
          title: '测试视频',
          episodeNumber: 1,
          sourceType: 'test',
        ),
      ],
      tags: ['测试', '动画'],
      rating: 5.0,
      viewCount: 1000000,
    );

    Get.to(() => PlayerScreen(video: testVideo, startEpisode: startEpisode));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.testVideo, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 60,
                color: AppColors.info.withValues(alpha: 0.3),
                child: const Icon(Icons.play_circle_filled, size: 32),
              ),
            ),
            title: Text(l10n.bigBuckBunny),
            subtitle: Text(l10n.testOnlineVideoPlay),
            trailing: ElevatedButton.icon(
              onPressed: () => _playTestVideo(context),
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.play),
            ),
          ),
        ),
      ],
    );
  }
}

/// 分类区域
class _CategorySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = [
      {'icon': '🎬', 'name': l10n.anime},
      {'icon': '🎭', 'name': l10n.movie},
      {'icon': '📺', 'name': l10n.tvSeries},
      {'icon': '🎮', 'name': l10n.category},
      {'icon': '🎵', 'name': l10n.latest},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((cat) {
        return InkWell(
          onTap: () {
            // TODO: 跳转到分类页
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: (MediaQuery.of(context).size.width - 48) / 2,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(cat['icon']!, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  cat['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
