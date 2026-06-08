import '../models/video_info.dart';
import '../models/media_info.dart';

/// 数据源类型
enum SourceType {
  /// 在线视频源
  online,

  /// BT 种子源
  torrent,

  /// 本地文件源
  local,

  /// Jellyfin 媒体服务器
  jellyfin,

  /// Emby 媒体服务器
  emby,
}

/// 数据源配置
class DataSourceConfig {
  /// 数据源 ID
  final String id;

  /// 数据源名称
  final String name;

  /// 数据源类型
  final SourceType type;

  /// 基础 URL
  final String? baseUrl;

  /// 是否启用
  final bool enabled;

  /// 优先级（数字越大优先级越高）
  final int priority;

  /// 超时时间（毫秒）
  final int timeout;

  /// HTTP 头信息
  final Map<String, String>? headers;

  const DataSourceConfig({
    required this.id,
    required this.name,
    required this.type,
    this.baseUrl,
    this.enabled = true,
    this.priority = 0,
    this.timeout = 30000,
    this.headers,
  });

  DataSourceConfig copyWith({
    String? id,
    String? name,
    SourceType? type,
    String? baseUrl,
    bool? enabled,
    int? priority,
    int? timeout,
    Map<String, String>? headers,
  }) {
    return DataSourceConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      baseUrl: baseUrl ?? this.baseUrl,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      timeout: timeout ?? this.timeout,
      headers: headers ?? this.headers,
    );
  }
}

/// 视频数据源抽象接口
abstract class VideoDataSource {
  /// 数据源配置
  final DataSourceConfig config;

  VideoDataSource({required this.config});

  /// 搜索视频
  /// [query] 搜索关键词
  /// [page] 页码
  /// [pageSize] 每页数量
  /// 返回搜索结果
  Future<List<VideoInfo>> search(String query, {int page = 1, int pageSize = 20});

  /// 获取视频详情
  /// [videoId] 视频 ID
  /// 返回视频详情
  Future<VideoInfo> getDetail(String videoId);

  /// 获取剧集列表
  /// [videoId] 视频 ID
  /// 返回剧集列表
  Future<List<EpisodeInfo>> getEpisodes(String videoId);

  /// 获取可播放媒体
  /// [episodeId] 剧集 ID
  /// 返回可播放媒体信息
  Future<PlayableMedia> getPlayableMedia(String episodeId);

  /// 测试数据源可用性
  /// 返回是否可用
  Future<bool> testAvailability();

  /// 获取视频分类列表
  Future<List<String>> getCategories();

  /// 获取指定分类下的视频
  Future<List<VideoInfo>> getVideosByCategory(String category, {int page = 1, int pageSize = 20});

  /// 获取排行榜
  Future<List<VideoInfo>> getRanking({String? category, int page = 1, int pageSize = 20});

  /// 获取最新更新
  Future<List<VideoInfo>> getLatest({int page = 1, int pageSize = 20});
}
