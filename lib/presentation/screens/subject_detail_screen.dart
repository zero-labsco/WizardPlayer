import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amis_flutter_utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wizard_player_datasource/wizard_player_datasource.dart';
import 'package:wizardplayer/core/services/bangumi_service.dart';
import 'package:wizardplayer/core/services/play_history_service.dart';
import 'package:wizardplayer/data/repositories/video_repository.dart';
import 'package:wizardplayer/presentation/screens/player_screen.dart';
import 'package:wizardplayer/core/l10n/app_localizations.dart';
import 'package:wizardplayer/core/theme/app_colors.dart';

/// 番剧详情页
class SubjectDetailScreen extends StatefulWidget {
  /// 番剧 ID（支持 int 或 String）
  final dynamic subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isSearchingSource = false;

  dynamic _subject;
  List<dynamic> _similarSubjects = [];
  PlayHistory? _history;

  /// 获取 int 类型的 subjectId（兼容 String 和 int）
  int get _subjectIdInt {
    if (widget.subjectId is int) {
      return widget.subjectId as int;
    }
    return int.tryParse(widget.subjectId.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final bangumiService = Get.find<BangumiService>();

      // 并行加载数据
      final results = await Future.wait([
        bangumiService.getSubjectDetail(_subjectIdInt),
        bangumiService.getSimilarSubject(_subjectIdInt, limit: 6),
      ]);

      final historyManager = Get.find<PlayHistoryManager>();
      final history = historyManager.getHistory(_subjectIdInt);

      setState(() {
        _subject = results[0];
        _similarSubjects = results[1] as List<dynamic>;
        _history = history;
        _isLoading = false;
      });

      AppLogger().d('番剧详情加载完成: ${_subject?.name}');
    } catch (e, stackTrace) {
      AppLogger().e('番剧详情加载失败', error: e, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_subject == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(AppLocalizations.of(context)!.loadError)),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 顶部图片
          _buildSliverAppBar(context),
          // 详情内容
          SliverToBoxAdapter(child: _buildDetailContent(context)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 0.6;
    final l10n = AppLocalizations.of(context)!;

    return SliverAppBar(
      expandedHeight: imageHeight,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图片
            if (_subject.image != null)
              CachedNetworkImage(
                imageUrl: _subject.image!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.grey300),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.grey300),
              )
            else
              Container(color: AppColors.grey300),
            // 渐变遮罩
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.black70],
                ),
              ),
            ),
            // 封面和信息
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 封面
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _subject.image != null
                        ? CachedNetworkImage(
                            imageUrl: _subject.image!,
                            width: 100,
                            height: 140,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 100,
                              height: 140,
                              color: AppColors.grey400,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 100,
                              height: 140,
                              color: AppColors.grey400,
                              child: const Icon(Icons.movie),
                            ),
                          )
                        : Container(
                            width: 100,
                            height: 140,
                            color: AppColors.grey400,
                            child: const Icon(Icons.movie),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // 信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _subject.displayName,
                          style: const TextStyle(
                            color: AppColors.darkTextPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_subject.nameCn != null &&
                            _subject.nameCn != _subject.name) ...[
                          const SizedBox(height: 4),
                          Text(
                            _subject.name,
                            style: const TextStyle(
                              color: AppColors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (_subject.rating != null) ...[
                              const Icon(
                                Icons.star,
                                color: AppColors.warning,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _subject.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColors.darkTextPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (_subject.eps != null) ...[
                              const Icon(
                                Icons.play_circle_outline,
                                color: AppColors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.episodesCount(_subject.eps!),
                                style: const TextStyle(
                                  color: AppColors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // 收藏按钮
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : null,
          ),
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
            AppLogger().d('收藏状态: $_isFavorite');
          },
        ),
        // 分享按钮
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: 分享功能
          },
        ),
      ],
    );
  }

  Widget _buildDetailContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 简介
          if (_subject.summary != null && _subject.summary!.isNotEmpty) ...[
            Text(
              l10n.introduction,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _subject.summary!,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
          ],

          // 标签
          if (_subject.tags.isNotEmpty) ...[
            Text(l10n.tags, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _subject.tags.take(10).map<Widget>((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // 播放按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSearchingSource
                  ? null
                  : () {
                      _playEpisode(_history?.currentEpisode ?? 1);
                    },
              icon: _isSearchingSource
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(
                _isSearchingSource
                    ? l10n.searchingSource
                    : (_history != null
                          ? l10n.continuePlay(_history!.currentEpisode)
                          : l10n.startPlay),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 选集
          if (_subject.eps != null && _subject.eps! > 0) ...[
            Text(
              l10n.selectEpisodes,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildEpisodeSelector(context),
            const SizedBox(height: 32),
          ],

          // 相关推荐
          if (_similarSubjects.isNotEmpty) ...[
            Text(
              l10n.relatedRecommendations,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildSimilarSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildEpisodeSelector(BuildContext context) {
    final eps = _subject.eps ?? 0;
    final crossAxisCount = MediaQuery.of(context).size.width >= 600 ? 10 : 6;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: eps,
      itemBuilder: (context, index) {
        final episodeNumber = index + 1;
        final isWatched =
            _history != null && _history!.currentEpisode > episodeNumber;
        final isCurrent =
            _history != null && _history!.currentEpisode == episodeNumber;

        return InkWell(
          onTap: () => _playEpisode(episodeNumber),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isCurrent
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: isWatched && !isCurrent
                  ? Border.all(color: AppColors.grey300)
                  : null,
            ),
            child: Center(
              child: Text(
                '$episodeNumber',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? AppColors.darkTextPrimary : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimilarSection(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _similarSubjects.length,
        itemBuilder: (context, index) {
          final subject = _similarSubjects[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Get.to(() => SubjectDetailScreen(subjectId: subject.id));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: subject.image != null
                        ? CachedNetworkImage(
                            imageUrl: subject.image!,
                            width: 120,
                            height: 160,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 120,
                              height: 160,
                              color: AppColors.grey300,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 120,
                              height: 160,
                              color: AppColors.grey300,
                              child: const Icon(Icons.movie),
                            ),
                          )
                        : Container(
                            width: 120,
                            height: 160,
                            color: AppColors.grey300,
                            child: const Icon(Icons.movie),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subject.displayName,
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
  }

  Future<void> _playEpisode(int episodeNumber) async {
    setState(() {
      _isSearchingSource = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final videoRepository = Get.find<VideoRepository>();

      // 获取搜索关键词（优先用中文名，没有则用原名）
      final searchKeyword = _subject.nameCn ?? _subject.name ?? '';
      AppLogger().d('搜索番剧资源: $searchKeyword');

      // 搜索视频资源
      final searchResults = await videoRepository.searchVideo(searchKeyword);

      if (searchResults.isEmpty) {
        if (mounted) {
          Get.snackbar(
            l10n.noResults,
            l10n.noResourceFound,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return;
      }

      AppLogger().d('搜索到 ${searchResults.length} 个结果');
      for (int i = 0; i < searchResults.length; i++) {
        final v = searchResults[i];
        AppLogger().d('  [$i] ${v.title}, 源: ${v.sourceType}, id: ${v.id}');
      }

      // 找到最合适的视频（优先选在线源，然后 BT 源）
      VideoInfo bestMatch;
      VideoInfo? found;

      // 定义 BT 源类型
      const btSources = {'mikan', 'dmhy'};

      // 先找在线源（非 BT 源）
      for (final video in searchResults) {
        if (!btSources.contains(video.sourceType)) {
          found = video;
          AppLogger().d('✅ 找到在线源: ${video.title}, 源: ${video.sourceType}');
          break;
        }
      }

      // 如果没找到在线源，再找 BT 源（优先 DMHY，然后 Mikan）
      if (found == null) {
        AppLogger().d('⚠️ 未找到在线源，尝试 BT 源');
        for (final video in searchResults) {
          if (video.sourceType == 'dmhy') {
            found = video;
            AppLogger().d('✅ 找到 DMHY 源: ${video.title}');
            break;
          }
        }
        if (found == null) {
          for (final video in searchResults) {
            if (video.sourceType == 'mikan') {
              found = video;
              AppLogger().d('✅ 找到 Mikan 源: ${video.title}');
              break;
            }
          }
        }
      }

      // 如果都没找到，就用第一个结果
      bestMatch = found ?? searchResults.first;

      AppLogger().d('最终选择: ${bestMatch.title}, 源: ${bestMatch.sourceType}');

      // 获取详细信息（确保有完整的剧集列表）
      VideoInfo videoInfo = bestMatch;
      if (videoInfo.episodes.isEmpty) {
        try {
          AppLogger().d(
            l10n.tryGetVideoDetail(bestMatch.sourceType, bestMatch.id),
          );
          final detail = await videoRepository.getVideoDetailFromSource(
            bestMatch.id,
            bestMatch.sourceType,
          );
          if (detail != null) {
            videoInfo = detail;
            AppLogger().d(l10n.videoDetailSuccess(videoInfo.episodes.length));
            for (int i = 0; i < videoInfo.episodes.length; i++) {
              final ep = videoInfo.episodes[i];
              AppLogger().d(
                '  Ep ${ep.episodeNumber}: id=${ep.id}, extra=${ep.extra}',
              );
            }
          }
        } catch (e) {
          AppLogger().w(l10n.getVideoDetailFailed);
        }
      } else {
        AppLogger().d(
          l10n.searchResultsHaveEpisodes(videoInfo.episodes.length),
        );
      }

      // 确保有剧集列表
      if (videoInfo.episodes.isEmpty) {
        AppLogger().w('⚠️ 剧集列表为空，创建占位符');
        final epsCount = _subject.eps ?? 1;
        videoInfo = videoInfo.copyWith(
          episodes: List.generate(
            epsCount,
            (index) => EpisodeInfo(
              id: '${bestMatch.id}_${index + 1}',
              title: l10n.episodePrefix(index + 1),
              episodeNumber: index + 1,
              sourceType: bestMatch.sourceType,
            ),
          ),
        );
      }

      // 跳转播放页
      if (mounted) {
        AppLogger().d(l10n.jumpToPlayer(episodeNumber));
        Get.to(
          () => PlayerScreen(video: videoInfo, startEpisode: episodeNumber),
        );
      }
    } catch (e, stackTrace) {
      AppLogger().e(
        l10n.searchResourceFailed,
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        Get.snackbar(
          l10n.loadFailed,
          l10n.searchResourceError,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingSource = false;
        });
      }
    }
  }
}
