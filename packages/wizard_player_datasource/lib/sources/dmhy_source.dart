import 'package:html/parser.dart' as parser;
import 'package:amis_flutter_utils/utils.dart';

import '../models/video_info.dart';
import '../models/media_info.dart';
import 'data_source.dart';
import 'http_client.dart';

/// DMHY 数据源
///
/// 用于从动漫花园网站获取番剧的 BT 种子信息
class DmhySource extends VideoDataSource {
  /// HTTP 客户端
  final HttpClient _httpClient;

  /// DMHY 基础 URL
  static const String _baseUrl = 'https://share.dmhy.org';
  /// DMHY 备用 URL
  static const String _backupUrl = 'https://dmhy.org';

  /// 构造函数
  DmhySource()
      : _httpClient = HttpClient(
          baseUrl: _baseUrl,
          backupBaseUrls: [_backupUrl],
          timeout: 45000,
        ),
        super(
          config: const DataSourceConfig(
            id: 'dmhy',
            name: '动漫花园',
            type: SourceType.torrent,
            enabled: true,
            priority: 4,
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
      AppLogger().d('DmhySource.search: $query, page: $page');
      final response = await _httpClient.get(
        '/topics/list/page/$page',
        queryParameters: {'keyword': query},
      );

      if (response.statusCode == 200) {
        final html = response.data as String;
        return _parseVideoListFromHtml(html);
      }
      return [];
    } catch (e) {
      AppLogger().d('DmhySource.search error: $e');
      return [];
    }
  }

  @override
  Future<VideoInfo> getDetail(String videoId) async {
    try {
      AppLogger().d('DmhySource.getDetail: $videoId');
      final response = await _httpClient.get('/topics/view/$videoId');

      if (response.statusCode == 200) {
        final html = response.data as String;
        return _parseVideoDetailFromHtml(html, videoId);
      }
      throw Exception('Failed to get video detail');
    } catch (e) {
      AppLogger().d('DmhySource.getDetail error: $e');
      rethrow;
    }
  }

  @override
  Future<List<EpisodeInfo>> getEpisodes(String videoId) async {
    try {
      final detail = await getDetail(videoId);
      return detail.episodes;
    } catch (e) {
      AppLogger().d('DmhySource.getEpisodes error: $e');
      return [];
    }
  }

  @override
  Future<PlayableMedia> getPlayableMedia(String episodeId) async {
    try {
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
      AppLogger().d('DmhySource.getPlayableMedia error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> testAvailability() async {
    try {
      final response = await _httpClient.get('/');
      return response.statusCode == 200;
    } catch (e) {
      AppLogger().d('DmhySource.testAvailability error: $e');
      return false;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    return ['全部', '新番连载', '完结动画', '剧场版', 'OVA'];
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
      AppLogger().d('DmhySource.getLatest: $page');
      final response = await _httpClient.get('/topics/list/page/$page');

      if (response.statusCode == 200) {
        final html = response.data as String;
        final list = _parseVideoListFromHtml(html);
        final start = (page - 1) * pageSize;
        final end = start + pageSize;
        return list.sublist(start, end > list.length ? list.length : end);
      }
      return [];
    } catch (e) {
      AppLogger().d('DmhySource.getLatest error: $e');
      return [];
    }
  }

  /// 从 HTML 解析视频列表
  List<VideoInfo> _parseVideoListFromHtml(String html) {
    final List<VideoInfo> results = [];

    try {
      final document = parser.parse(html);

      // 查找番剧条目
      final items = document.querySelectorAll('.topic-item, tr, a[href*="/topics/view/"]');

      if (items.isEmpty) {
        // 尝试查找所有链接
        final links = document.querySelectorAll('a');
        for (final link in links) {
          final href = link.attributes['href'] ?? '';
          if (href.startsWith('/topics/view/')) {
            final title = link.text.trim();
            if (title.isNotEmpty && !results.any((r) => r.title == title)) {
              final id = href.replaceFirst('/topics/view/', '').split('/').first;
              results.add(VideoInfo(
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
              ));
            }
          }
        }
      } else {
        for (final item in items) {
          final linkElements = item.querySelectorAll('a[href*="/topics/view/"]');
          for (final link in linkElements) {
            final href = link.attributes['href'] ?? '';
            if (href.startsWith('/topics/view/')) {
              final id = href.replaceFirst('/topics/view/', '').split('/').first;
              final title = link.text.trim();

              // 查找封面图
              String coverUrl = '';
              final img = item.querySelector('img');
              if (img != null) {
                coverUrl = img.attributes['src'] ?? '';
                if (coverUrl.startsWith('//')) {
                  coverUrl = 'https:$coverUrl';
                }
              }

              if (title.isNotEmpty && !results.any((r) => r.id == id)) {
                results.add(VideoInfo(
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
                ));
              }
            }
          }
        }
      }

      AppLogger().d('DmhySource.parseVideoList: ${results.length} items found');
    } catch (e) {
      AppLogger().d('DmhySource.parseVideoList error: $e');
    }

    return results;
  }

  /// 从 HTML 解析视频详情
  VideoInfo _parseVideoDetailFromHtml(String html, String videoId) {
    final List<EpisodeInfo> episodes = [];

    try {
      final document = parser.parse(html);

      // 解析番剧标题
      final titleElement = document.querySelector('h1, .topic-title, .title');
      final title = titleElement?.text.trim() ?? 'Unknown';

      // 解析封面
      String coverUrl = '';
      final coverImg = document.querySelector('.topic-poster img, .poster img, img');
      if (coverImg != null) {
        coverUrl = coverImg.attributes['src'] ?? '';
        if (coverUrl.startsWith('//')) {
          coverUrl = 'https:$coverUrl';
        }
      }

      // 查找磁力链接
      final torrentElements = document.querySelectorAll('a[href^="magnet:"]');
      for (int i = 0; i < torrentElements.length; i++) {
        final link = torrentElements[i];
        final href = link.attributes['href'] ?? '';
        final epTitle = link.text.trim();

        episodes.add(EpisodeInfo(
          id: 'ep_$i',
          title: epTitle.isNotEmpty ? epTitle : '第 ${i + 1} 集',
          episodeNumber: i + 1,
          sourceType: config.id,
          extra: {'magnet': href},
        ));
      }

      // 如果没有找到磁力链接，尝试查找下载按钮
      if (episodes.isEmpty) {
        final downloadLinks = document.querySelectorAll('a[href*="download"]');
        for (int i = 0; i < downloadLinks.length; i++) {
          final link = downloadLinks[i];
          final href = link.attributes['href'] ?? '';
          final epTitle = link.text.trim();

          episodes.add(EpisodeInfo(
            id: 'ep_$i',
            title: epTitle.isNotEmpty ? epTitle : '第 ${i + 1} 集',
            episodeNumber: i + 1,
            sourceType: config.id,
            extra: {'magnet': href},
          ));
        }
      }

      AppLogger().d('DmhySource.parseDetail: title=$title, episodes=${episodes.length}');

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
      AppLogger().d('DmhySource.parseDetail error: $e');
      return VideoInfo(
        id: videoId,
        title: 'DMHY Video',
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
