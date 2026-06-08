/// AniSpace 数据源
///
/// 用于获取在线视频播放链接
///
/// API 文档: https://api-v2.anispace.workers.dev/
///
/// @author AmisKwok
library;

import 'package:amis_flutter_utils/utils.dart';
import 'package:wizard_player_datasource/wizard_player_datasource.dart';

/// AniSpace 数据源实现
///
/// 提供在线视频的搜索、详情和播放链接
class AniSpaceSource extends VideoDataSource {
  /// HTTP 客户端
  final HttpClient _httpClient;

  /// AniSpace API Base URL
  static const String _baseUrl = 'https://api-v2.anispace.workers.dev';

  /// 构造函数
  AniSpaceSource()
    : _httpClient = HttpClient(baseUrl: _baseUrl, timeout: 45000),
      super(
        config: const DataSourceConfig(
          id: 'anispace',
          name: 'AniSpace 在线视频',
          type: SourceType.online,
          enabled: true,
          priority: 2,
          timeout: 45000,
        ),
      );

  @override
  Future<List<VideoInfo>> search(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _httpClient.get('/search/$query');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        // 分页处理
        final start = (page - 1) * pageSize;
        final end = start + pageSize;
        final pageData = data.sublist(
          start,
          end > data.length ? data.length : end,
        );

        return pageData.map((item) => _parseVideo(item)).toList();
      }
      return [];
    } catch (e) {
      AppLogger().d('AniSpaceSource.search error: $e');
      return [];
    }
  }

  @override
  Future<VideoInfo> getDetail(String videoId) async {
    try {
      // AniSpace 使用 ID 格式: anime-{id}
      final response = await _httpClient.get('/info/$videoId');

      if (response.statusCode == 200) {
        return _parseVideoDetail(response.data);
      }
      throw Exception('Failed to get video detail');
    } catch (e) {
      AppLogger().d('AniSpaceSource.getDetail error: $e');
      rethrow;
    }
  }

  @override
  Future<List<EpisodeInfo>> getEpisodes(String videoId) async {
    try {
      // 获取剧集列表
      final response = await _httpClient.get('/info/$videoId');

      if (response.statusCode == 200) {
        final List<dynamic> episodes = response.data['episodes'] ?? [];
        return episodes
            .asMap()
            .entries
            .map((entry) => _parseEpisode(entry.value, entry.key + 1))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger().d('AniSpaceSource.getEpisodes error: $e');
      return [];
    }
  }

  @override
  Future<PlayableMedia> getPlayableMedia(String episodeId) async {
    try {
      // episodeId 格式: {animeId}/ep-{episodeNumber}
      // 例如: "jujutsu-kaisen-2nd-season/ep-1"
      final response = await _httpClient.get('/watch/$episodeId');

      if (response.statusCode == 200) {
        final data = response.data;

        // 提取最佳质量的播放链接
        final sources = data['sources'] as List<dynamic>? ?? [];
        if (sources.isEmpty) {
          throw Exception('No playable sources found');
        }

        // 选择第一个源（通常是最佳质量）
        final source = sources.first;
        final String url = source['url'] ?? '';
        final String quality = source['quality'] ?? 'auto';

        // 提取字幕信息
        final subtitles = _parseSubtitles(data['subtitles']);

        return PlayableMedia(
          url: url,
          type: _parseMediaType(url),
          quality: quality,
          sourceName: 'AniSpace',
          headers: {'Referer': _baseUrl},
          subtitles: subtitles,
        );
      }
      throw Exception('Failed to get playable media');
    } catch (e) {
      AppLogger().d('AniSpaceSource.getPlayableMedia error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> testAvailability() async {
    try {
      final response = await _httpClient.get('/home');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    // AniSpace 的分类列表
    return [
      'Action',
      'Adventure',
      'Cars',
      'Comedy',
      'Dementia',
      'Drama',
      'Ecchi',
      'Fantasy',
      'Harem',
      'Horror',
      'Josei',
      'Kids',
      'Magic',
      'Martial Arts',
      'Mecha',
      'Military',
      'Music',
      'Mystery',
      'Parody',
      'Police',
      'Psychological',
      'Romance',
      'Samurai',
      'School',
      'Sci-Fi',
      'Seinen',
      'Shoujo',
      'Shoujo Ai',
      'Shounen',
      'Shounen Ai',
      'Slice of Life',
      'Space',
      'Sports',
      'Super Power',
      'Supernatural',
      'Thriller',
      'Vampire',
      'Yaoi',
      'Yuri',
    ];
  }

  @override
  Future<List<VideoInfo>> getVideosByCategory(
    String category, {
    int page = 1,
    int pageSize = 20,
  }) async {
    // AniSpace 不直接支持分类搜索，返回热门列表
    try {
      final response = await _httpClient.get('/home');
      if (response.statusCode == 200) {
        final trending = response.data['trending'] as List<dynamic>? ?? [];
        final start = (page - 1) * pageSize;
        final end = start + pageSize;
        final pageData = trending.sublist(
          start,
          end > trending.length ? trending.length : end,
        );
        return pageData.map((item) => _parseVideo(item)).toList();
      }
      return [];
    } catch (e) {
      AppLogger().d('AniSpaceSource.getVideosByCategory error: $e');
      return [];
    }
  }

  @override
  Future<List<VideoInfo>> getRanking({
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    // 获取热门番剧作为排行榜
    try {
      final response = await _httpClient.get('/home');
      if (response.statusCode == 200) {
        final trending = response.data['trending'] as List<dynamic>? ?? [];
        final start = (page - 1) * pageSize;
        final end = start + pageSize;
        final pageData = trending.sublist(
          start,
          end > trending.length ? trending.length : end,
        );
        return pageData.map((item) => _parseVideo(item)).toList();
      }
      return [];
    } catch (e) {
      AppLogger().d('AniSpaceSource.getRanking error: $e');
      return [];
    }
  }

  @override
  Future<List<VideoInfo>> getLatest({int page = 1, int pageSize = 20}) async {
    // 获取最新番剧
    try {
      final response = await _httpClient.get('/home');
      if (response.statusCode == 200) {
        // 尝试从 recent 字段获取，否则使用 trending
        final recent =
            response.data['recent'] as List<dynamic>? ??
            response.data['trending'] as List<dynamic>? ??
            [];
        final start = (page - 1) * pageSize;
        final end = start + pageSize;
        final pageData = recent.sublist(
          start,
          end > recent.length ? recent.length : end,
        );
        return pageData.map((item) => _parseVideo(item)).toList();
      }
      return [];
    } catch (e) {
      AppLogger().d('AniSpaceSource.getLatest error: $e');
      return [];
    }
  }

  /// 解析视频信息（从列表）
  VideoInfo _parseVideo(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id']?.toString() ?? json['animeId']?.toString() ?? '',
      title: json['title'] ?? json['animeTitle'] ?? 'Unknown',
      subtitle: json['title'] ?? json['animeTitle'],
      coverUrl: json['image'] ?? json['animeImg'],
      rating: (json['rating'] ?? 0).toDouble(),
      viewCount: 0,
      publishTime: null,
      tags: _parseGenres(json['genres']),
      sourceType: 'anispace',
      episodes: [], // 剧集需要调用 getEpisodes 获取
    );
  }

  /// 解析视频详情
  VideoInfo _parseVideoDetail(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown',
      subtitle: json['description'] ?? json['synopsis'] ?? '',
      coverUrl: json['image'] ?? json['cover'] ?? json['animeImg'],
      rating: (json['rating'] ?? json['score'] ?? 0).toDouble(),
      viewCount: 0,
      publishTime: _parseDate(json['releaseDate'] ?? json['aired']),
      tags: _parseGenres(json['genres'] ?? json['type']),
      sourceType: 'anispace',
      episodes: [], // 剧集需要单独获取
    );
  }

  /// 解析剧集信息
  EpisodeInfo _parseEpisode(Map<String, dynamic> json, int number) {
    return EpisodeInfo(
      id: json['episodeId']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '第 $number 集',
      episodeNumber: json['number'] ?? number,
      thumbnailUrl: json['image'] ?? json['thumbnail'],
      duration: _parseDuration(json['duration']),
      description: json['description'] ?? json['summary'],
      hasSubtitle: true,
      sourceType: config.id,
    );
  }

  /// 解析类型
  MediaType _parseMediaType(String url) {
    if (url.contains('.mp4')) return MediaType.mp4;
    if (url.contains('.m3u8')) return MediaType.hls;
    if (url.contains('.webm')) return MediaType.webm;
    return MediaType.unknown;
  }

  /// 解析字幕
  List<SubtitleTrack> _parseSubtitles(List<dynamic>? subtitles) {
    if (subtitles == null) return [];

    return subtitles.asMap().entries.map((entry) {
      final index = entry.key;
      final sub = entry.value;
      final lang = sub['language'] ?? sub['lang'] ?? 'Unknown';
      return SubtitleTrack(
        id: '$index',
        language: lang,
        languageName: sub['label'] ?? sub['language'] ?? lang,
        url: sub['url'] ?? '',
        isDefault: index == 0,
      );
    }).toList();
  }

  /// 解析标签
  List<String> _parseGenres(dynamic genres) {
    if (genres == null) return [];
    if (genres is String) return [genres];
    if (genres is List) {
      return genres.map((g) => g.toString()).toList();
    }
    return [];
  }

  /// 解析日期
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// 解析时长（秒）
  int? _parseDuration(String? durationStr) {
    if (durationStr == null || durationStr.isEmpty) return null;
    try {
      // 支持 "24:30" 格式
      if (durationStr.contains(':')) {
        final parts = durationStr.split(':');
        if (parts.length >= 2) {
          return int.parse(parts[0]) * 60 + int.parse(parts[1]);
        }
      }
      // 直接是数字
      return int.tryParse(durationStr);
    } catch (e) {
      return null;
    }
  }
}
