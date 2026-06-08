import 'dart:ui';

/// 弹幕模式
enum DanmakuMode {
  /// 滚动弹幕
  rolling,

  /// 顶部固定弹幕
  top,

  /// 底部固定弹幕
  bottom,

  /// 特殊弹幕（反向滚动等）
  special,
}

/// 弹幕颜色预设
class DanmakuColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFFF0000);
  static const Color pink = Color(0xFFFF69B4);
  static const Color orange = Color(0xFFFF6600);
  static const Color yellow = Color(0xFFFFFF00);
  static const Color green = Color(0xFF00FF00);
  static const Color cyan = Color(0xFF00FFFF);
  static const Color blue = Color(0xFF0000FF);
  static const Color purple = Color(0xFF9900FF);
  static const Color black = Color(0xFF000000);

  /// 从十六进制字符串解析颜色
  static Color fromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}

/// 单条弹幕
class Danmaku {
  /// 弹幕 ID
  final String id;

  /// 弹幕内容
  final String text;

  /// 出现时间（秒）
  final double time;

  /// 弹幕模式
  final DanmakuMode mode;

  /// 字体大小
  final double fontSize;

  /// 颜色
  final Color color;

  /// 发送者 ID
  final String? senderId;

  /// 发送时间
  final DateTime? sendTime;

  /// 是否是池弹幕（可复用）
  final bool isPool;

  /// 弹幕权重（用于智能过滤）
  final int weight;

  /// 弹幕属性（高级属性）
  final Map<String, dynamic>? attributes;

  const Danmaku({
    required this.id,
    required this.text,
    required this.time,
    this.mode = DanmakuMode.rolling,
    this.fontSize = 25,
    this.color = DanmakuColors.white,
    this.senderId,
    this.sendTime,
    this.isPool = false,
    this.weight = 0,
    this.attributes,
  });

  Danmaku copyWith({
    String? id,
    String? text,
    double? time,
    DanmakuMode? mode,
    double? fontSize,
    Color? color,
    String? senderId,
    DateTime? sendTime,
    bool? isPool,
    int? weight,
    Map<String, dynamic>? attributes,
  }) {
    return Danmaku(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      mode: mode ?? this.mode,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      senderId: senderId ?? this.senderId,
      sendTime: sendTime ?? this.sendTime,
      isPool: isPool ?? this.isPool,
      weight: weight ?? this.weight,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Danmaku && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 弹幕字幕轨道
class DanmakuTrack {
  /// 轨道索引
  final int index;

  /// 是否被占用
  bool isOccupied;

  /// 占用结束时间
  double occupiedUntil;

  DanmakuTrack({
    required this.index,
    this.isOccupied = false,
    this.occupiedUntil = 0,
  });
}

/// 弹幕配置
class DanmakuConfig {
  /// 是否启用弹幕
  final bool enabled;

  /// 透明度（0.0 - 1.0）
  final double opacity;

  /// 字体大小缩放
  final double fontSizeScale;

  /// 滚动速度
  final double scrollSpeed;

  /// 区域（0.0 - 1.0，控制弹幕密度）
  final double area;

  /// 最大同时显示弹幕数
  final int maxCount;

  /// 是否显示顶部弹幕
  final bool showTop;

  /// 是否显示底部弹幕
  final bool showBottom;

  /// 是否显示滚动弹幕
  final bool showRolling;

  /// 是否智能过滤
  final bool smartFilter;

  /// 过滤阈值
  final int filterThreshold;

  const DanmakuConfig({
    this.enabled = true,
    this.opacity = 0.8,
    this.fontSizeScale = 1.0,
    this.scrollSpeed = 1.0,
    this.area = 1.0,
    this.maxCount = 100,
    this.showTop = true,
    this.showBottom = true,
    this.showRolling = true,
    this.smartFilter = false,
    this.filterThreshold = 5,
  });

  DanmakuConfig copyWith({
    bool? enabled,
    double? opacity,
    double? fontSizeScale,
    double? scrollSpeed,
    double? area,
    int? maxCount,
    bool? showTop,
    bool? showBottom,
    bool? showRolling,
    bool? smartFilter,
    int? filterThreshold,
  }) {
    return DanmakuConfig(
      enabled: enabled ?? this.enabled,
      opacity: opacity ?? this.opacity,
      fontSizeScale: fontSizeScale ?? this.fontSizeScale,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      area: area ?? this.area,
      maxCount: maxCount ?? this.maxCount,
      showTop: showTop ?? this.showTop,
      showBottom: showBottom ?? this.showBottom,
      showRolling: showRolling ?? this.showRolling,
      smartFilter: smartFilter ?? this.smartFilter,
      filterThreshold: filterThreshold ?? this.filterThreshold,
    );
  }
}
