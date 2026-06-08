import 'package:html/parser.dart' as parser;
import 'package:amis_flutter_utils/utils.dart';

import '../models/video_info.dart';
import '../models/media_info.dart';
import 'data_source.dart';
import 'http_client.dart';

/// Mikan 数据源
///
/// 用于从 Mikan 网站获取番剧的 BT 种子信息
class MikanSource extends VideoDataSource {
  /// HTTP 客户端
  final HttpClient _httpClient;

  /// Mikan 基础 URL
  static const String _baseUrl = 'https://mikanani.me';

  /// Mikan 备用 URL
  static const String _backupUrl = 'https://mikanime.tv';

  /// 构造函数
  MikanSource()
    : _httpClient = HttpClient(
        baseUrl: _baseUrl,
        backupBaseUrls: [_backupUrl],
        timeout: 45000,
      ),
      super(
        config: const DataSourceConfig(
          id: 'mikan',
          name: 'Mikan',
          type: SourceType.torrent,
          enabled: true,
          priority: 5,
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
      AppLogger().d('MikanSource.search: $query, page: $page');
      final response = await _httpClient.get(
        '/Home/Search',
        queryParameters: {'searchstr': query},
      );

      if (response.statusCode == 200) {
        final html = response.data as String;
        return _parseVideoListFromHtml(html);
      }
      return [];
    } catch (e) {
      AppLogger().d('MikanSource.search error: $e');
      return [];
    }
  }

  @override
  Future<VideoInfo> getDetail(String videoId) async {
    try {
      AppLogger().d('MikanSource.getDetail: $videoId');
      final response = await _httpClient.get('/Home/Bangumi/$videoId');

      if (response.statusCode == 200) {
        final html = response.data as String;
        return _parseVideoDetailFromHtml(html, videoId);
      }
      throw Exception('Failed to get video detail');
    } catch (e) {
      AppLogger().d('MikanSource.getDetail error: $e');
      rethrow;
    }
  }

  @override
  Future<List<EpisodeInfo>> getEpisodes(String videoId) async {
    try {
      final detail = await getDetail(videoId);
      return detail.episodes;
    } catch (e) {
      AppLogger().d('MikanSource.getEpisodes error: $e');
      return [];
    }
  }

  @override
  Future<PlayableMedia> getPlayableMedia(String episodeId) async {
    try {
      // 如果 episodeId 本身就是 magnet 链接，直接使用
      if (episodeId.startsWith('magnet:')) {
        final episode = EpisodeInfo(
          id: episodeId,
          title: 'Episode',
          episodeNumber: 1,
          sourceType: config.id,
          extra: {'magnet': episodeId},
        );
        return PlayableMedia(
          url: episodeId,
          type: MediaType.bt,
          quality: 'default',
          sourceName: config.name,
          episode: episode,
        );
      }

      // 否则尝试从剧集详情获取
      // 这里需要 videoId，但 episodeId 可能不包含足够信息
      // 为了简化，如果 episodeId 不是 magnet，我们尝试用它去获取详情
      // 注意：这里逻辑可能需要根据实际情况调整
      final episode = EpisodeInfo(
        id: episodeId,
        title: 'Episode',
        episodeNumber: 1,
        sourceType: config.id,
        extra: {'magnet': episodeId},
      );
      return PlayableMedia(
        url: episodeId,
        type: MediaType.bt,
        quality: 'default',
        sourceName: config.name,
        episode: episode,
      );
    } catch (e) {
      AppLogger().d('MikanSource.getPlayableMedia error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> testAvailability() async {
    try {
      final response = await _httpClient.get('/Home');
      return response.statusCode == 200;
    } catch (e) {
      AppLogger().d('MikanSource.testAvailability error: $e');
      return false;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    return ['全部', '新番', '完结', '动画电影', 'OVA'];
  }

  @override
  Future<List<VideoInfo>> getVideosByCategory(
    String category, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return search(category, page: page, pageSize: pageSize);
  }

  @override
  Future<List<VideoInfo>> getRanking({
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    return getLatest(page: page, pageSize: pageSize);
  }

  @override
  Future<List<VideoInfo>> getLatest({int page = 1, int pageSize = 20}) async {
    try {
      AppLogger().d('MikanSource.getLatest: $page');
      final response = await _httpClient.get('/Home/BangumiCalendar');

      if (response.statusCode == 200) {
        final html = response.data as String;
        final list = _parseVideoListFromHtml(html);
        final start = (page - 1) * pageSize;
        final end = start + pageSize;
        return list.sublist(start, end > list.length ? list.length : end);
      }
      return [];
    } catch (e) {
      AppLogger().d('MikanSource.getLatest error: $e');
      return [];
    }
  }

  /// 从 HTML 解析视频列表
  List<VideoInfo> _parseVideoListFromHtml(String html) {
    final List<VideoInfo> results = [];

    try {
      final document = parser.parse(html);

      // 查找番剧卡片
      final items = document.querySelectorAll(
        '.an-item, .bangumi-item, a[href*="/Home/Bangumi/"]',
      );

      if (items.isEmpty) {
        // 尝试其他选择器
        final links = document.querySelectorAll('a');
        for (final link in links) {
          final href = link.attributes['href'] ?? '';
          if (href.startsWith('/Home/Bangumi/')) {
            final title = link.text.trim();
            if (title.isNotEmpty && !results.any((r) => r.title == title)) {
              final id = href.replaceFirst('/Home/Bangumi/', '');
              results.add(
                VideoInfo(
                  id: id,
                  title: title,
                  subtitle: '',
                  coverUrl: '',
                  rating: 0,
                  viewCount: 0,
                  publishTime: null,
                  tags: [],
                  sourceType: config.id,
                  episodes: [],
                ),
              );
            }
          }
        }
      } else {
        for (final item in items) {
          final link = item.attributes['href'] ?? '';
          if (link.startsWith('/Home/Bangumi/')) {
            final id = link.replaceFirst('/Home/Bangumi/', '');
            final title = item.text.trim();

            // 查找封面图
            String coverUrl = '';
            final img = item.querySelector('img');
            if (img != null) {
              coverUrl = img.attributes['src'] ?? '';
              if (coverUrl.startsWith('//')) {
                coverUrl = 'https:$coverUrl';
              }
            }

            if (title.isNotEmpty) {
              results.add(
                VideoInfo(
                  id: id,
                  title: title,
                  subtitle: '',
                  coverUrl: coverUrl,
                  rating: 0,
                  viewCount: 0,
                  publishTime: null,
                  tags: [],
                  sourceType: config.id,
                  episodes: [],
                ),
              );
            }
          }
        }
      }

      AppLogger().d(
        'MikanSource.parseVideoList: ${results.length} items found',
      );
    } catch (e) {
      AppLogger().d('MikanSource.parseVideoList error: $e');
    }

    return results;
  }

  /// 从 HTML 解析视频详情
  VideoInfo _parseVideoDetailFromHtml(String html, String videoId) {
    final List<EpisodeInfo> episodes = [];

    try {
      final document = parser.parse(html);

      // 解析番剧标题
      final titleElement = document.querySelector('.bangumi-title, h1');
      final title = titleElement?.text.trim() ?? 'Unknown';

      // 解析封面
      String coverUrl = '';
      final coverImg = document.querySelector('.bangumi-poster img, img');
      if (coverImg != null) {
        coverUrl = coverImg.attributes['src'] ?? '';
        if (coverUrl.startsWith('//')) {
          coverUrl = 'https:$coverUrl';
        }
      }

      // 首先查找所有 magnet 链接
      final allMagnets = <String>[];
      final magnetLinks = document.querySelectorAll('a[href^="magnet:"]');
      for (final link in magnetLinks) {
        final href = link.attributes['href'] ?? '';
        if (href.isNotEmpty) {
          allMagnets.add(href);
        }
      }

      AppLogger().d('MikanSource: Found ${allMagnets.length} magnet links');

      // 尝试查找包含 magnet 的表格或列表
      // 常见的 Mikan 页面结构是表格形式
      final torrentRows = document.querySelectorAll('tr, .item, .list-item');

      int episodeNum = 1;
      for (final row in torrentRows) {
        // 在这个元素中找 magnet 链接
        final magnetEl = row.querySelector('a[href^="magnet:"]');
        if (magnetEl != null) {
          final magnet = magnetEl.attributes['href'] ?? '';
          if (magnet.isNotEmpty) {
            // 获取标题
            String epTitle = '第 $episodeNum 集';
            final textEl = row.querySelector('.title, td, span');
            if (textEl != null) {
              epTitle = textEl.text.trim();
            }
            if (epTitle.isEmpty) {
              epTitle = magnetEl.text.trim();
            }

            episodes.add(
              EpisodeInfo(
                id: 'ep_$episodeNum',
                title: epTitle.isNotEmpty ? epTitle : '第 $episodeNum 集',
                episodeNumber: episodeNum,
                sourceType: config.id,
                extra: {'magnet': magnet},
              ),
            );
            episodeNum++;
          }
        }
      }

      // 如果上面没找到，尝试直接用找到的所有 magnet 链接
      if (episodes.isEmpty && allMagnets.isNotEmpty) {
        for (int i = 0; i < allMagnets.length; i++) {
          episodes.add(
            EpisodeInfo(
              id: 'ep_${i + 1}',
              title: '第 ${i + 1} 集',
              episodeNumber: i + 1,
              sourceType: config.id,
              extra: {'magnet': allMagnets[i]},
            ),
          );
        }
      }

      AppLogger().d(
        'MikanSource.parseDetail: title=$title, episodes=${episodes.length}',
      );
      for (int i = 0; i < episodes.length; i++) {
        final ep = episodes[i];
        final magnet = ep.extra?['magnet'] ?? '';
        AppLogger().d('  Ep ${ep.episodeNumber}: magnet=$magnet');
      }

      return VideoInfo(
        id: videoId,
        title: title,
        subtitle: '',
        coverUrl: coverUrl,
        rating: 0,
        viewCount: 0,
        publishTime: null,
        tags: [],
        sourceType: config.id,
        episodes: episodes,
      );
    } catch (e) {
      AppLogger().d('MikanSource.parseDetail error: $e');
      return VideoInfo(
        id: videoId,
        title: 'Mikan Video',
        subtitle: '',
        coverUrl: '',
        rating: 0,
        viewCount: 0,
        publishTime: null,
        tags: [],
        sourceType: config.id,
        episodes: episodes,
      );
    }
  }
}
