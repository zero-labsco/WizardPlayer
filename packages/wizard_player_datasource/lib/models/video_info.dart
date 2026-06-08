/// 视频类型枚举
enum VideoType {
  /// 动漫
  anime,

  /// 韩剧
  koreanDrama,

  /// 美剧
  americanDrama,

  /// 日剧
  japaneseDrama,
}

/// 视频信息模型
///
/// 统一使用此模型作为数据层模型
class VideoInfo {
  final String id;

  /// 标题
  final String title;

  /// 副标题/描述
  final String? subtitle;

  /// 封面图片 URL
  final String? coverUrl;

  /// 评分
  final double? rating;

  /// 播放量
  final int? viewCount;

  /// 发布时间
  final DateTime? publishTime;

  /// 标签列表
  final List<String> tags;

  /// 来源类型
  final String sourceType;

  /// 剧集列表
  final List<EpisodeInfo> episodes;

  const VideoInfo({
    required this.id,
    required this.title,
    this.subtitle,
    this.coverUrl,
    this.rating,
    this.viewCount,
    this.publishTime,
    this.tags = const [],
    required this.sourceType,
    this.episodes = const [],
  });

  VideoInfo copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? coverUrl,
    double? rating,
    int? viewCount,
    DateTime? publishTime,
    List<String>? tags,
    String? sourceType,
    List<EpisodeInfo>? episodes,
  }) {
    return VideoInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      coverUrl: coverUrl ?? this.coverUrl,
      rating: rating ?? this.rating,
      viewCount: viewCount ?? this.viewCount,
      publishTime: publishTime ?? this.publishTime,
      tags: tags ?? this.tags,
      sourceType: sourceType ?? this.sourceType,
      episodes: episodes ?? this.episodes,
    );
  }
}

/// 剧集信息
class EpisodeInfo {
  /// 剧集 ID
  final String id;

  /// 剧集标题（如 "第1集"）
  final String title;

  /// 剧集编号
  final int episodeNumber;

  /// 缩略图
  final String? thumbnailUrl;

  /// 播放时长（秒）
  final int? duration;

  /// 描述
  final String? description;

  /// 是否有字幕
  final bool hasSubtitle;

  /// 来源类型
  final String sourceType;

  /// 额外数据（用于存储 BT 磁链等）
  final Map<String, dynamic>? extra;

  const EpisodeInfo({
    required this.id,
    required this.title,
    required this.episodeNumber,
    this.thumbnailUrl,
    this.duration,
    this.description,
    this.hasSubtitle = false,
    required this.sourceType,
    this.extra,
  });

  EpisodeInfo copyWith({
    String? id,
    String? title,
    int? episodeNumber,
    String? thumbnailUrl,
    int? duration,
    String? description,
    bool? hasSubtitle,
    String? sourceType,
    Map<String, dynamic>? extra,
  }) {
    return EpisodeInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      hasSubtitle: hasSubtitle ?? this.hasSubtitle,
      sourceType: sourceType ?? this.sourceType,
      extra: extra ?? this.extra,
    );
  }
}
