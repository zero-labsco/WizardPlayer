import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amis_flutter_utils/utils.dart';
import 'package:wizardplayer/core/l10n/app_localizations.dart';
import 'package:wizardplayer/core/widgets/video_grid.dart';
import 'package:wizardplayer/core/services/play_history_service.dart';
import 'package:wizardplayer/core/theme/app_colors.dart';
import 'package:wizardplayer/data/repositories/video_repository.dart';
import 'package:wizardplayer/presentation/screens/player_screen.dart';
import 'package:wizardplayer/presentation/widgets/common_widgets.dart';

/// 首页内容组件
class HomeContentWidget extends StatelessWidget {
  /// 最新番剧列表
  final List<VideoGridItem> latestList;

  /// 排行榜列表
  final List<VideoGridItem> rankingList;

  /// 每日放送数据
  final Map<String, List<VideoGridItem>> calendarData;

  /// 最新番剧加载状态
  final bool latestLoading;

  /// 排行榜加载状态
  final bool rankingLoading;

  /// 每日放送加载状态
  final bool calendarLoading;

  /// 加载最新番剧
  final VoidCallback? onRefreshLatest;

  /// 加载排行榜
  final VoidCallback? onRefreshRanking;

  const HomeContentWidget({
    super.key,
    required this.latestList,
    required this.rankingList,
    required this.calendarData,
    this.latestLoading = false,
    this.rankingLoading = false,
    this.calendarLoading = false,
    this.onRefreshLatest,
    this.onRefreshRanking,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 正在观看
          SectionTitle(title: '📺 ${l10n.continueWatching}'),
          const SizedBox(height: 12),
          const _WatchingSection(),
          const SizedBox(height: 32),

          // 最新番剧
          SectionTitle(title: '✨ ${l10n.latestUpdate}'),
          const SizedBox(height: 12),
          LoadingSection(
            isLoading: latestLoading,
            height: 280,
            child: latestList.isEmpty
                ? EmptyState(message: l10n.noResults, height: 280)
                : SizedBox(height: 280, child: VideoGrid(items: latestList)),
          ),
          const SizedBox(height: 32),

          // 每日放送
          SectionTitle(title: '📅 ${l10n.todayUpdate}'),
          const SizedBox(height: 12),
          _CalendarSection(
            calendarData: calendarData,
            isLoading: calendarLoading,
          ),
          const SizedBox(height: 32),

          // 周排行榜
          SectionTitle(title: '🏆 ${l10n.weeklyRanking}'),
          const SizedBox(height: 12),
          LoadingSection(
            isLoading: rankingLoading,
            height: 280,
            child: rankingList.isEmpty
                ? EmptyState(message: l10n.noResults, height: 280)
                : SizedBox(height: 280, child: VideoGrid(items: rankingList)),
          ),
        ],
      ),
    );
  }
}

/// 正在观看区域
class _WatchingSection extends StatefulWidget {
  const _WatchingSection();

  @override
  State<_WatchingSection> createState() => _WatchingSectionState();
}

class _WatchingSectionState extends State<_WatchingSection> {
  Future<void> _playHistory(PlayHistory history) async {
    try {
      final videoRepository = Get.find<VideoRepository>();
      final video = await videoRepository.getVideoDetail(
        history.subjectId.toString(),
      );

      if (video != null) {
        Get.to(
          () =>
              PlayerScreen(video: video, startEpisode: history.currentEpisode),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('无法获取视频信息')));
        }
      }
    } catch (e) {
      AppLogger().e('播放历史记录失败', error: e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('播放失败')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyManager = Get.find<PlayHistoryManager>();

    return Obx(() {
      final watching = historyManager.histories
          .where((h) => !h.isCompleted && h.currentEpisode > 0)
          .toList();

      if (watching.isEmpty) {
        return Container(
          height: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Text(l10n.noResults)),
        );
      }

      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: watching.length,
          itemBuilder: (context, index) {
            final history = watching[index];
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => _playHistory(history),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        NetImg(
                          imageUrl: history.coverUrl,
                          width: 120,
                          height: 140,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [AppColors.black80, Colors.transparent],
                              ),
                            ),
                            child: Text(
                              l10n.episodeNumber(history.currentEpisode),
                              style: const TextStyle(
                                color: AppColors.darkTextPrimary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      history.subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

/// 每日放送区域
class _CalendarSection extends StatelessWidget {
  final Map<String, List<VideoGridItem>> calendarData;
  final bool isLoading;

  const _CalendarSection({required this.calendarData, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now().weekday;
    final weekdays = [
      l10n.sunday,
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
    ];
    final todayName = weekdays[today == 7 ? 0 : today];

    final todayAnimes = calendarData[todayName] ?? [];

    if (isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (todayAnimes.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Text(l10n.noUpdateToday)),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: todayAnimes.length,
        itemBuilder: (context, index) {
          final anime = todayAnimes[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: anime.onTap,
              child: Column(
                children: [
                  NetImg(
                    imageUrl: anime.coverUrl,
                    width: 80,
                    height: 70,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    anime.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
