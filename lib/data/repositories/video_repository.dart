/// 视频数据仓库
///
/// 统一使用 datasource 层的模型
/// 集成多个数据源：Bangumi（元信息）+ AniSpace（播放链接）
///
/// @author AmisKwok
library;

import 'package:amis_flutter_utils/utils.dart';
import 'package:wizard_player_datasource/wizard_player_datasource.dart';

/// 视频仓库接口
///
/// 使用 datasource 层的 VideoInfo 模型
abstract class IVideoRepository {
  /// 获取视频列表
  Future<List<VideoInfo>> getVideoList(VideoType type, {int page = 1});

  /// 获取视频详情
  Future<VideoInfo?> getVideoDetail(String videoId);

  /// 从指定源获取视频详情
  Future<VideoInfo?> getVideoDetailFromSource(
    String videoId,
    String? sourceType,
  );

  /// 搜索视频
  Future<List<VideoInfo>> searchVideo(String keyword);

  /// 获取可播放的媒体
  Future<PlayableMedia> getPlayableMedia(String episodeId);

  /// 获取排行榜
  Future<List<VideoInfo>> getRanking({int page = 1});

  /// 获取最新更新
  Future<List<VideoInfo>> getLatest({int page = 1});

  /// 获取每日放送
  Future<Map<int, List<VideoInfo>>> getCalendar();
}

/// 视频仓库实现
class VideoRepository implements IVideoRepository {
  /// 元数据源（Bangumi - 用于获取番剧信息）
  final VideoDataSource _metaSource;

  /// 在线播放源（AniSpace - 用于获取在线播放链接）
  final VideoDataSource _onlineSource;

  /// BT 播放源（Mikan - 用于获取 BT 种子）
  final VideoDataSource _btSource;

  /// BT 备用播放源（DMHY - 用于获取 BT 种子）
  final VideoDataSource _btBackupSource;

  /// 所有数据源列表
  final List<VideoDataSource> _allSources;

  /// 源选择器
  final SourceSelector _sourceSelector;

  /// 构造函数
  VideoRepository({
    VideoDataSource? metaSource,
    VideoDataSource? onlineSource,
    VideoDataSource? btSource,
    VideoDataSource? btBackupSource,
  }) : _metaSource = metaSource ?? BangumiSource(),
       _onlineSource = onlineSource ?? AniSpaceSource(),
       _btSource = btSource ?? MikanSource(),
       _btBackupSource = btBackupSource ?? DmhySource(),
       _allSources = [
         metaSource ?? BangumiSource(),
         onlineSource ?? AniSpaceSource(),
         btSource ?? MikanSource(),
         btBackupSource ?? DmhySource(),
       ],
       _sourceSelector = SourceSelector(
         sources: [
           metaSource ?? BangumiSource(),
           onlineSource ?? AniSpaceSource(),
           btSource ?? MikanSource(),
           btBackupSource ?? DmhySource(),
         ],
       ) {
    AppLogger().d(
      'VideoRepository initialized with ${_allSources.length} sources',
    );
  }

  @override
  Future<List<VideoInfo>> getVideoList(VideoType type, {int page = 1}) async {
    AppLogger().d('VideoRepository.getVideoList: type=$type, page=$page');
    try {
      final videos = await _metaSource.getLatest(page: page);
      return videos;
    } catch (e, stackTrace) {
      AppLogger().e(
        'Failed to get video list',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<VideoInfo?> getVideoDetail(String videoId) async {
    AppLogger().d('VideoRepository.getVideoDetail: videoId=$videoId');
    return getVideoDetailFromSource(videoId, null);
  }

  /// 从指定源获取视频详情
  @override
  Future<VideoInfo?> getVideoDetailFromSource(
    String videoId,
    String? sourceType,
  ) async {
    AppLogger().d(
      'VideoRepository.getVideoDetailFromSource: videoId=$videoId, sourceType=$sourceType',
    );
    try {
      VideoInfo? info;

      // 如果指定了源类型，优先从该源获取
      if (sourceType == 'mikan') {
        try {
          info = await _btSource.getDetail(videoId);
          AppLogger().d('✅ 从 Mikan 获取详情成功，剧集数: ${info.episodes.length}');
          return info;
        } catch (e) {
          AppLogger().w('从 Mikan 获取详情失败: $e');
        }
      } else if (sourceType == 'dmhy') {
        try {
          info = await _btBackupSource.getDetail(videoId);
          AppLogger().d('✅ 从 DMHY 获取详情成功，剧集数: ${info.episodes.length}');
          return info;
        } catch (e) {
          AppLogger().w('从 DMHY 获取详情失败: $e');
        }
      } else if (sourceType == 'anispace') {
        try {
          info = await _onlineSource.getDetail(videoId);
          AppLogger().d('✅ 从 AniSpace 获取详情成功，剧集数: ${info.episodes.length}');
          return info;
        } catch (e) {
          AppLogger().w('从 AniSpace 获取详情失败: $e');
        }
      }

      // 如果没有指定源，或者指定源失败，依次尝试所有源
      // 1. 先尝试 Mikan
      try {
        info = await _btSource.getDetail(videoId);
        AppLogger().d('✅ 从 Mikan 获取详情成功，剧集数: ${info.episodes.length}');
        if (info.episodes.isNotEmpty) {
          return info;
        }
      } catch (e) {
        AppLogger().w('从 Mikan 获取详情失败: $e');
      }

      // 2. 再尝试 DMHY
      try {
        info = await _btBackupSource.getDetail(videoId);
        AppLogger().d('✅ 从 DMHY 获取详情成功，剧集数: ${info.episodes.length}');
        if (info.episodes.isNotEmpty) {
          return info;
        }
      } catch (e) {
        AppLogger().w('从 DMHY 获取详情失败: $e');
      }

      // 3. 最后尝试在线源
      try {
        info = await _onlineSource.getDetail(videoId);
        AppLogger().d('✅ 从 AniSpace 获取详情成功，剧集数: ${info.episodes.length}');
        return info;
      } catch (e) {
        AppLogger().w('从 AniSpace 获取详情失败: $e');
      }

      return info;
    } catch (e, stackTrace) {
      AppLogger().e(
        'Failed to get video detail',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<List<VideoInfo>> searchVideo(String keyword) async {
    AppLogger().d('VideoRepository.searchVideo: keyword=$keyword');
    final allResults = <VideoInfo>[];

    try {
      // 1. 优先搜索 Mikan BT 源
      try {
        final btVideos = await _btSource.search(keyword);
        if (btVideos.isNotEmpty) {
          AppLogger().d('✅ 从 Mikan 找到 ${btVideos.length} 个结果');
          allResults.addAll(btVideos);
        }
      } catch (e) {
        AppLogger().w('Mikan 搜索失败: $e');
      }

      // 2. 再搜索 DMHY BT 源
      try {
        final dmhyVideos = await _btBackupSource.search(keyword);
        if (dmhyVideos.isNotEmpty) {
          AppLogger().d('✅ 从 DMHY 找到 ${dmhyVideos.length} 个结果');
          allResults.addAll(dmhyVideos);
        }
      } catch (e) {
        AppLogger().w('DMHY 搜索失败: $e');
      }

      // 3. 最后搜索在线源（备用）
      try {
        final onlineVideos = await _onlineSource.search(keyword);
        if (onlineVideos.isNotEmpty) {
          AppLogger().d('✅ 从 AniSpace 找到 ${onlineVideos.length} 个结果');
          allResults.addAll(onlineVideos);
        }
      } catch (e) {
        AppLogger().w('AniSpace 搜索失败: $e');
      }

      if (allResults.isEmpty) {
        AppLogger().w('所有源都没有搜索结果');
      }

      return allResults;
    } catch (e, stackTrace) {
      AppLogger().e('Failed to search video', error: e, stackTrace: stackTrace);
      return allResults;
    }
  }

  @override
  Future<PlayableMedia> getPlayableMedia(String episodeId) async {
    AppLogger().d('VideoRepository.getPlayableMedia: episodeId=$episodeId');
    try {
      // 使用源选择器选择最佳源
      final evaluation = await _sourceSelector.selectBest(episodeId);
      if (evaluation.available) {
        return await evaluation.source.getPlayableMedia(episodeId);
      }
      // 如果选择器失败，尝试在线源
      return await _onlineSource.getPlayableMedia(episodeId);
    } catch (e, stackTrace) {
      AppLogger().e(
        'Failed to get playable media',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<VideoInfo>> getRanking({int page = 1}) async {
    AppLogger().d('VideoRepository.getRanking: page=$page');
    try {
      final videos = await _metaSource.getRanking(page: page);
      return videos;
    } catch (e, stackTrace) {
      AppLogger().e('Failed to get ranking', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<List<VideoInfo>> getLatest({int page = 1}) async {
    AppLogger().d('VideoRepository.getLatest: page=$page');
    try {
      final videos = await _metaSource.getLatest(page: page);
      return videos;
    } catch (e, stackTrace) {
      AppLogger().e('Failed to get latest', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<Map<int, List<VideoInfo>>> getCalendar() async {
    AppLogger().d('VideoRepository.getCalendar');
    try {
      // Bangumi 有每日放送 API，这里简化为获取最新番剧
      // 实际实现需要调用 Bangumi 的 /p1/calendar 接口
      final videos = await _metaSource.getLatest(page: 1);
      return {DateTime.now().weekday: videos};
    } catch (e, stackTrace) {
      AppLogger().e('Failed to get calendar', error: e, stackTrace: stackTrace);
      return {};
    }
  }
}
