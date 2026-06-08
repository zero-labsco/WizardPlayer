/// 番剧基本信息
class BangumiSubject {
  /// 番剧 ID
  final int id;

  /// 中文名
  final String name;

  /// 日文名
  final String? nameCn;

  /// 简介
  final String? summary;

  /// 封面图片
  final String? image;

  /// 评分
  final double? rating;

  /// 评分人数
  final int? ratingCount;

  /// 观看人数
  final int? collectionCount;

  /// 收藏人数
  final int? wishCount;

  /// 类型
  final List<String> tags;

  /// 动画类型
  final String? type;

  /// 集数
  final int? eps;

  /// 开始日期
  final DateTime? airDate;

  /// 播放状态
  final String? airWeekday;

  /// 官方站点
  final String? site;

  const BangumiSubject({
    required this.id,
    required this.name,
    this.nameCn,
    this.summary,
    this.image,
    this.rating,
    this.ratingCount,
    this.collectionCount,
    this.wishCount,
    this.tags = const [],
    this.type,
    this.eps,
    this.airDate,
    this.airWeekday,
    this.site,
  });

  factory BangumiSubject.fromJson(Map<String, dynamic> json) {
    return BangumiSubject(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      nameCn: json['name_cn'] as String?,
      summary: json['summary'] as String?,
      image:
          json['images']?['large'] as String? ??
          json['images']?['medium'] as String?,
      rating: (json['rating']?['score'] as num?)?.toDouble(),
      ratingCount: json['rating']?['total'] as int?,
      collectionCount: json['collection_count'] as int?,
      wishCount: json['wish_count'] as int?,
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => e['name'] as String)
              .toList() ??
          [],
      type: json['type']?.toString(), // 类型是 int，转换为 String
      eps: json['eps'] as int?,
      airDate: json['air_date'] != null
          ? DateTime.tryParse(json['air_date'] as String)
          : null,
      airWeekday: json['air_weekday']?.toString(), // 可能是 int，转换为 String
      site: json['site'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_cn': nameCn,
      'summary': summary,
      'image': image,
      'rating': {'score': rating, 'total': ratingCount},
      'collection_count': collectionCount,
      'wish_count': wishCount,
      'tags': tags.map((e) => {'name': e}).toList(),
      'type': type,
      'eps': eps,
      'air_date': airDate?.toIso8601String(),
      'air_weekday': airWeekday,
      'site': site,
    };
  }

  /// 获取显示名称（优先中文名）
  String get displayName => nameCn?.isNotEmpty == true ? nameCn! : name;
}

/// 搜索结果
class BangumiSearchResult {
  final List<BangumiSubject> list;
  final int total;
  final int page;
  final int pageSize;

  const BangumiSearchResult({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory BangumiSearchResult.fromJson(Map<String, dynamic> json) {
    final list =
        (json['list'] as List<dynamic>?) ??
        (json['data'] as List<dynamic>?) ??
        [];
    return BangumiSearchResult(
      list: list
          .map((e) => BangumiSubject.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? json['results'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
    );
  }

  bool get hasMore => page * pageSize < total;
}

/// 用户收藏信息
class BangumiCollection {
  /// 番剧 ID
  final int subjectId;

  /// 收藏状态
  final String status;

  /// 用户评分
  final int? rating;

  /// 收藏时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 观看进度
  final int? watchedEps;

  /// 总集数
  final int? totalEps;

  /// 是否在看
  bool get isWatching => status == 'doing';

  /// 是否看过
  bool get isWatched => status == 'done';

  /// 是否想看
  bool get isWish => status == 'wish';

  /// 观看进度百分比
  double get progress {
    if (totalEps == null || totalEps == 0) return 0;
    return (watchedEps ?? 0) / totalEps!;
  }

  const BangumiCollection({
    required this.subjectId,
    required this.status,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.watchedEps,
    this.totalEps,
  });

  factory BangumiCollection.fromJson(Map<String, dynamic> json) {
    return BangumiCollection(
      subjectId: json['subject_id'] as int,
      status: json['status'] as String? ?? 'unknown',
      rating: json['rating'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      watchedEps: json['watched_eps'] as int?,
      totalEps: json['volumes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_id': subjectId,
      'status': status,
      'rating': rating,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'watched_eps': watchedEps,
      'volumes': totalEps,
    };
  }
}
