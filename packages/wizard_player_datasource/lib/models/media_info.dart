import 'video_info.dart';

/// 媒体类型
enum MediaType {
  /// MP4
  mp4,

  /// MKV
  mkv,

  /// WebM
  webm,

  /// HLS 流
  hls,

  /// DASH 流
  dash,

  /// BT 种子/磁链
  bt,

  /// 未知
  unknown,
}

/// 字幕信息
class SubtitleTrack {
  /// 字幕 ID
  final String id;

  /// 语言代码（如 zh、en、ja）
  final String language;

  /// 语言名称（如 中文、English、日语）
  final String languageName;

  /// 字幕 URL
  final String url;

  /// 是否是默认字幕
  final bool isDefault;

  const SubtitleTrack({
    required this.id,
    required this.language,
    required this.languageName,
    required this.url,
    this.isDefault = false,
  });

  SubtitleTrack copyWith({
    String? id,
    String? language,
    String? languageName,
    String? url,
    bool? isDefault,
  }) {
    return SubtitleTrack(
      id: id ?? this.id,
      language: language ?? this.language,
      languageName: languageName ?? this.languageName,
      url: url ?? this.url,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

/// 可播放媒体
class PlayableMedia {
  /// 播放 URL
  final String url;

  /// 媒体类型
  final MediaType type;

  /// HTTP 头信息（Referer、User-Agent 等）
  final Map<String, String>? headers;

  /// 字幕列表
  final List<SubtitleTrack>? subtitles;

  /// 清晰度（如 1080p、720p）
  final String? quality;

  /// 文件大小（字节）
  final int? fileSize;

  /// 来源名称
  final String sourceName;

  /// 关联的剧集信息
  final EpisodeInfo? episode;

  const PlayableMedia({
    required this.url,
    required this.type,
    this.headers,
    this.subtitles,
    this.quality,
    this.fileSize,
    required this.sourceName,
    this.episode,
  });

  PlayableMedia copyWith({
    String? url,
    MediaType? type,
    Map<String, String>? headers,
    List<SubtitleTrack>? subtitles,
    String? quality,
    int? fileSize,
    String? sourceName,
    EpisodeInfo? episode,
  }) {
    return PlayableMedia(
      url: url ?? this.url,
      type: type ?? this.type,
      headers: headers ?? this.headers,
      subtitles: subtitles ?? this.subtitles,
      quality: quality ?? this.quality,
      fileSize: fileSize ?? this.fileSize,
      sourceName: sourceName ?? this.sourceName,
      episode: episode ?? this.episode,
    );
  }

  /// 从 URL 推断媒体类型
  static MediaType inferType(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('.mp4')) return MediaType.mp4;
    if (lowerUrl.contains('.mkv')) return MediaType.mkv;
    if (lowerUrl.contains('.webm')) return MediaType.webm;
    if (lowerUrl.contains('.m3u8')) return MediaType.hls;
    if (lowerUrl.contains('.mpd')) return MediaType.dash;
    return MediaType.unknown;
  }
}
