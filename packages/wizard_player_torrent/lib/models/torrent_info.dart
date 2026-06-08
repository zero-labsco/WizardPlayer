/// 种子信息模型
///
/// 表示一个 BT 种子的基本信息
class TorrentInfo {
  /// 种子 ID（来自 libtorrent_flutter）
  final int infoHash;

  /// 种子名称
  final String name;

  /// 总大小（字节）
  final int totalSize;

  /// 包含的文件列表
  final List<TorrentFileInfo> files;

  /// 创建时间
  final DateTime? createdAt;

  /// 构造函数
  const TorrentInfo({
    required this.infoHash,
    required this.name,
    required this.totalSize,
    this.files = const [],
    this.createdAt,
  });

  /// 从 JSON 创建
  factory TorrentInfo.fromJson(Map<String, dynamic> json) {
    return TorrentInfo(
      infoHash: json['info_hash'] as int,
      name: json['name'] as String,
      totalSize: json['total_size'] as int,
      files: (json['files'] as List<dynamic>?)
              ?.map((e) => TorrentFileInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'info_hash': infoHash,
      'name': name,
      'total_size': totalSize,
      'files': files.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// 创建副本
  TorrentInfo copyWith({
    int? infoHash,
    String? name,
    int? totalSize,
    List<TorrentFileInfo>? files,
    DateTime? createdAt,
  }) {
    return TorrentInfo(
      infoHash: infoHash ?? this.infoHash,
      name: name ?? this.name,
      totalSize: totalSize ?? this.totalSize,
      files: files ?? this.files,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 种子文件信息
///
/// 表示种子中的单个文件
class TorrentFileInfo {
  /// 文件路径
  final String path;

  /// 文件大小（字节）
  final int size;

  /// 文件索引
  final int index;

  /// 是否被选择下载
  final bool selected;

  /// 构造函数
  const TorrentFileInfo({
    required this.path,
    required this.size,
    required this.index,
    this.selected = true,
  });

  /// 从 JSON 创建
  factory TorrentFileInfo.fromJson(Map<String, dynamic> json) {
    return TorrentFileInfo(
      path: json['path'] as String,
      size: json['size'] as int,
      index: json['index'] as int,
      selected: json['selected'] as bool? ?? true,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'size': size,
      'index': index,
      'selected': selected,
    };
  }

  /// 创建副本
  TorrentFileInfo copyWith({
    String? path,
    int? size,
    int? index,
    bool? selected,
  }) {
    return TorrentFileInfo(
      path: path ?? this.path,
      size: size ?? this.size,
      index: index ?? this.index,
      selected: selected ?? this.selected,
    );
  }
}
