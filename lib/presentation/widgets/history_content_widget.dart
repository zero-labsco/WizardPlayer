import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amis_flutter_utils/utils.dart';
import 'package:wizardplayer/core/l10n/app_localizations.dart';
import 'package:wizardplayer/core/services/play_history_service.dart';
import 'package:wizardplayer/data/repositories/video_repository.dart';
import 'package:wizardplayer/presentation/screens/player_screen.dart';
import 'package:wizardplayer/presentation/widgets/common_widgets.dart';

/// 历史记录页面内容组件
class HistoryContentWidget extends StatelessWidget {
  const HistoryContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyManager = Get.find<PlayHistoryManager>();

    return Obx(() {
      final histories = historyManager.histories;

      if (histories.isEmpty) {
        return EmptyState(message: l10n.noResults, icon: Icons.history);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: histories.length,
        itemBuilder: (context, index) {
          final history = histories[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: NetImg(
                imageUrl: history.coverUrl,
                width: 60,
                height: 80,
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () => _playHistory(context, history),
              title: Text(
                history.subjectName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.episodeNumber(history.currentEpisode)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: history.progress,
                    backgroundColor: Theme.of(context).disabledColor,
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () => _playHistory(context, history),
              ),
            ),
          );
        },
      );
    });
  }

  /// 播放历史记录
  Future<void> _playHistory(BuildContext context, PlayHistory history) async {
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
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('无法获取视频信息')));
        }
      }
    } catch (e) {
      AppLogger().e('播放历史记录失败', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('播放失败')));
      }
    }
  }
}
