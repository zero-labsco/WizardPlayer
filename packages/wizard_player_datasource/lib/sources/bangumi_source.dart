/// Bangumi 数据源
///
/// 用于获取番剧的元信息（名称、简介、评分、角色等）
///
/// API 文档: https://api.bgm.tv
///
/// @author AmisKwok
library;

import 'package:amis_flutter_utils/utils.dart';
import 'package:wizard_player_datasource/wizard_player_datasource.dart';

/// Bangumi 数据源实现
class BangumiSource extends VideoDataSource {
  /// HTTP 客户端
  final HttpClient _httpClient;

  /// Bangumi API Base URL
  static const String _baseUrl = 'https://api.bgm.tv';

  /// Bangumi Next API Base URL（备用）
  static const String _nextUrl = 'https://next.bgm.tv';

  /// User-Agent (Bangumi API 要求)
  static const String _userAgent =
      'WizardPlayer/1.0 (https://github.com/wizardplayer)';

  /// 构造函数
  BangumiSource()
    : _httpClient = HttpClient(
        baseUrl: _baseUrl,
        backupBaseUrls: [_nextUrl],
        headers: {'User-Agent': _userAgent},
        timeout: 45000,
      ),
      super(
        config: const DataSourceConfig(
          id: 'bangumi',
          name: 'Bangumi 番剧信息',
          type: SourceType.online,
          enabled: true,
          priority: 1,
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
      // 使用 v0 API 的 POST 搜索
      final response = await _httpClient.post(
        '/v0/search/subjects',
        data: {
          'keyword': query,
          'limit': pageSize,
          'offset': (page - 1) * pageSize,
          'filter': {
            'type': [2], // 只搜索动漫
          },
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => _parseVideoFromSearch(item)).toList();
      }
      return [];
    } catch (e) {
      AppLogger().d('BangumiSource.search error: $e');
      // 如果 POST 失败，尝试用 Legacy API
      try {
        return await _searchLegacy(query, page: page, pageSize: pageSize);
      } catch (e2) {
        AppLogger().d('BangumiSource.search legacy error: $e2');
        return [];
      }
    }
  }

  /// Legacy API 搜索（备用）
  Future<List<VideoInfo>> _searchLegacy(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _httpClient.get(
      '/search/subject/$query',
      queryParameters: {
        'max_results': pageSize,
        'start': (page - 1) * pageSize,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = response.data['list'] ?? [];
      return list
          .where((item) => item['type'] == 2) // 只取动漫
          .map((item) => _parseVideoFromLegacySearch(item))
          .toList();
    }
    return [];
  }

  @override
  Future<VideoInfo> getDetail(String videoId) async {
    try {
      final response = await _httpClient.get('/v0/subjects/$videoId');

      if (response.statusCode == 200) {
        return _parseVideoFromDetail(response.data);
      }
      throw Exception('Failed to get video detail');
    } catch (e) {
      AppLogger().d('BangumiSource.getDetail error: $e');
      rethrow;
    }
  }

  @override
  Future<List<EpisodeInfo>> getEpisodes(String videoId) async {
    try {
      final response = await _httpClient.get(
        '/v0/episodes',
        queryParameters: {'subject_id': videoId, 'limit': 100},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => _parseEpisode(item)).toList();
      }
      return [];
    } catch (e) {
      AppLogger().d('BangumiSource.getEpisodes error: $e');
      return [];
    }
  }

  @override
  Future<PlayableMedia> getPlayableMedia(String episodeId) async {
    // Bangumi 不提供播放链接，需要配合其他源使用
    // 这里返回空的播放信息，实际播放链接由其他数据源提供
    throw UnimplementedError(
      'BangumiSource does not provide playable media. '
      'Use AniSpaceSource or other video sources.',
    );
  }

  @override
  Future<bool> testAvailability() async {
    try {
      // 尝试获取一个已知的番剧（例如：进击的巨人）
      final response = await _httpClient.get('/v0/subjects/253');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    // Bangumi 使用标签系统，而不是固定分类
    // 返回常用分类
    return ['热血', '搞笑', '恋爱', '校园', '奇幻', '冒险', '科幻', '悬疑', '百合', '日常'];
  }

  @override
  Future<List<VideoInfo>> getVideosByCategory(
    String category, {
    int page = 1,
    int pageSize = 20,
  }) async {
    // 通过标签搜索
    try {
      final response = await _httpClient.post(
        '/v0/search/subjects',
        data: {
          'keyword': category,
          'limit': pageSize,
          'offset': (page - 1) * pageSize,
          'filter': {
            'type': [2],
          },
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => _parseVideoFromSearch(item)).toList();
      }
      return [];
    } catch (e) {
      AppLogger().d('BangumiSource.getVideosByCategory error: $e');
      // 回退到搜索
      return await search(category, page: page, pageSize: pageSize);
    }
  }

  @override
  Future<List<VideoInfo>> getRanking({
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    // 搜索热门番剧（按评分排序）
    try {
      final response = await _httpClient.post(
        '/v0/search/subjects',
        data: {
          'keyword': category ?? '',
          'limit': pageSize,
          'offset': (page - 1) * pageSize,
          'sort': 'rank',
          'filter': {
            'type': [2],
          },
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => _parseVideoFromSearch(item)).toList();
      }
      return [];
    } catch (e) {
      AppLogger().d('BangumiSource.getRanking error: $e');
      // 回退到用 Next API 的 trending
      try {
        return await _getTrendingFromNext();
      } catch (e2) {
        AppLogger().d('BangumiSource.getRanking next error: $e2');
        return [];
      }
    }
  }

  /// 从 Next API 获取 trending
  Future<List<VideoInfo>> _getTrendingFromNext() async {
    try {
      final response = await _httpClient.get(
        'https://next.bgm.tv/p1/trending/subjects',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        return data
            .where((item) => item['type'] == 2)
            .map((item) => _parseVideoFromSearch(item))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger().d('BangumiSource._getTrendingFromNext error: $e');
      // 最后回退到简单搜索热门动漫
      return await search('2024', page: 1, pageSize: 20);
    }
  }

  @override
  Future<List<VideoInfo>> getLatest({int page = 1, int pageSize = 20}) async {
    // 获取最新番剧（按时间排序）
    try {
      final response = await _httpClient.post(
        '/v0/search/subjects',
        data: {
          'limit': pageSize,
          'offset': (page - 1) * pageSize,
          'sort': 'date',
          'filter': {
            'type': [2],
          },
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => _parseVideoFromSearch(item)).toList();
      }
      return [];
    } catch (e) {
      AppLogger().d('BangumiSource.getLatest error: $e');
      // 回退到用 calendar API
      try {
        return await _getFromCalendar();
      } catch (e2) {
        AppLogger().d('BangumiSource.getLatest calendar error: $e2');
        return [];
      }
    }
  }

  /// 从 Calendar API 获取番剧
  Future<List<VideoInfo>> _getFromCalendar() async {
    final response = await _httpClient.get('/calendar');

    if (response.statusCode == 200) {
      final List<dynamic> calendar = response.data ?? [];
      final List<VideoInfo> results = [];

      for (final day in calendar) {
        final List<dynamic> items = day['items'] ?? [];
        results.addAll(items.map((item) => _parseVideoFromSearch(item)));
      }

      return results;
    }
    return [];
  }

  /// 从搜索结果解析视频信息
  VideoInfo _parseVideoFromSearch(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? json['name_cn'] ?? 'Unknown',
      subtitle: json['name_cn'] ?? json['name'],
      coverUrl: json['images']?['medium'] ?? json['images']?['large'],
      rating: (json['rating']?['score'] ?? 0).toDouble(),
      viewCount: json['collection']?['doing'] ?? 0,
      publishTime: _parseDate(json['date']),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((t) => t['name']?.toString() ?? '')
              .where((t) => t.isNotEmpty)
              .toList() ??
          [],
      sourceType: 'bangumi',
      episodes: [], // 搜索结果不包含剧集，需要调用 getEpisodes 获取
    );
  }

  /// 从 Legacy 搜索结果解析视频信息
  VideoInfo _parseVideoFromLegacySearch(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? json['name_cn'] ?? 'Unknown',
      subtitle: json['name_cn'] ?? json['name'],
      coverUrl: json['images']?['medium'] ?? json['images']?['common'],
      rating: (json['rating']?['score'] ?? 0).toDouble(),
      viewCount: 0,
      publishTime: _parseDate(json['air_date']),
      tags: [],
      sourceType: 'bangumi',
      episodes: [],
    );
  }

  /// 从详情接口解析视频信息
  VideoInfo _parseVideoFromDetail(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? json['name_cn'] ?? 'Unknown',
      subtitle: json['name_cn'] ?? json['summary'] ?? '',
      coverUrl: json['images']?['medium'] ?? json['images']?['large'],
      rating: (json['rating']?['score'] ?? 0).toDouble(),
      viewCount: json['collection']?['doing'] ?? 0,
      publishTime: _parseDate(json['date']),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((t) => t['name']?.toString() ?? '')
              .where((t) => t.isNotEmpty)
              .toList() ??
          [],
      sourceType: 'bangumi',
      episodes: [], // 剧集需要单独获取
    );
  }

  /// 解析 EpisodeInfo
  EpisodeInfo _parseEpisode(Map<String, dynamic> json) {
    return EpisodeInfo(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? '第${json['ep']}集',
      episodeNumber: json['ep'] ?? 0,
      thumbnailUrl: null, // v0 API 不直接提供缩略图
      duration: null,
      description: json['desc'],
      hasSubtitle: json['type'] == 0, // 0 = 普通, 1 = 特别篇
      sourceType: config.id,
    );
  }

  /// 解析日期字符串
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // 尝试解析 YYYY-MM-DD 格式
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
