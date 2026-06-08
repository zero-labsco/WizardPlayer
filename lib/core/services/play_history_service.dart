import 'dart:convert';

import 'package:get/get.dart';
import 'package:amis_flutter_utils/utils.dart';

/// 播放历史记录
class PlayHistory {
  /// 番剧 ID
  final int subjectId;

  /// 番剧名称
  final String subjectName;

  /// 番剧封面
  final String? coverUrl;

  /// 当前集数
  final int currentEpisode;

  /// 总集数
  final int totalEpisodes;

  /// 上次播放位置（秒）
  final int lastPosition;

  /// 总时长（秒）
  final int totalDuration;

  /// 最后播放时间
  final DateTime lastPlayedAt;

  /// 播放进度百分比
  double get progress {
    if (totalDuration == 0) return 0;
    return (lastPosition / totalDuration).clamp(0.0, 1.0);
  }

  /// 是否已看完
  bool get isCompleted => currentEpisode >= totalEpisodes && progress >= 0.95;

  const PlayHistory({
    required this.subjectId,
    required this.subjectName,
    this.coverUrl,
    required this.currentEpisode,
    required this.totalEpisodes,
    required this.lastPosition,
    required this.totalDuration,
    required this.lastPlayedAt,
  });

  factory PlayHistory.fromJson(Map<String, dynamic> json) {
    return PlayHistory(
      subjectId: json['subjectId'] as int,
      subjectName: json['subjectName'] as String,
      coverUrl: json['coverUrl'] as String?,
      currentEpisode: json['currentEpisode'] as int,
      totalEpisodes: json['totalEpisodes'] as int,
      lastPosition: json['lastPosition'] as int,
      totalDuration: json['totalDuration'] as int,
      lastPlayedAt: DateTime.parse(json['lastPlayedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'coverUrl': coverUrl,
      'currentEpisode': currentEpisode,
      'totalEpisodes': totalEpisodes,
      'lastPosition': lastPosition,
      'totalDuration': totalDuration,
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
    };
  }

  PlayHistory copyWith({
    int? subjectId,
    String? subjectName,
    String? coverUrl,
    int? currentEpisode,
    int? totalEpisodes,
    int? lastPosition,
    int? totalDuration,
    DateTime? lastPlayedAt,
  }) {
    return PlayHistory(
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      coverUrl: coverUrl ?? this.coverUrl,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      lastPosition: lastPosition ?? this.lastPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }
}

/// 播放历史管理器
class PlayHistoryManager extends GetxController {
  /// 历史记录列表
  final RxList<PlayHistory> histories = <PlayHistory>[].obs;

  /// 最大保存记录数
  static const int _maxHistories = 100;

  /// 存储键名
  static const String _storageKey = 'play_histories';

  @override
  void onInit() {
    super.onInit();
    _loadHistories();
  }

  /// 加载历史记录
  Future<void> _loadHistories() async {
    try {
      final jsonString = SpUtil.get<String>(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> data = json.decode(jsonString);
        final list = data
            .map((e) => PlayHistory.fromJson(e as Map<String, dynamic>))
            .toList();
        histories.assignAll(list);
        AppLogger().d('加载播放历史: ${list.length} 条');
      }
    } catch (e, stackTrace) {
      AppLogger().e('加载历史记录失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 保存历史记录
  Future<void> _saveHistories() async {
    try {
      final jsonString = json.encode(histories.map((e) => e.toJson()).toList());
      await SpUtil.put(_storageKey, jsonString);
    } catch (e, stackTrace) {
      AppLogger().e('保存历史记录失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 添加或更新历史记录
  Future<void> updateHistory({
    required int subjectId,
    required String subjectName,
    String? coverUrl,
    required int currentEpisode,
    required int totalEpisodes,
    required int lastPosition,
    required int totalDuration,
  }) async {
    final now = DateTime.now();
    final existingIndex = histories.indexWhere((h) => h.subjectId == subjectId);

    final newHistory = PlayHistory(
      subjectId: subjectId,
      subjectName: subjectName,
      coverUrl: coverUrl,
      currentEpisode: currentEpisode,
      totalEpisodes: totalEpisodes,
      lastPosition: lastPosition,
      totalDuration: totalDuration,
      lastPlayedAt: now,
    );

    if (existingIndex != -1) {
      // 更新现有记录
      histories[existingIndex] = newHistory;
      // 移动到最前面
      histories.removeAt(existingIndex);
      histories.insert(0, newHistory);
    } else {
      // 添加新记录
      histories.insert(0, newHistory);
      // 超出最大数量时删除最旧的
      if (histories.length > _maxHistories) {
        histories.removeLast();
      }
    }

    await _saveHistories();
    AppLogger().d('更新播放历史: $subjectName - 第 $currentEpisode 集');
  }

  /// 获取指定番剧的历史记录
  PlayHistory? getHistory(int subjectId) {
    return histories.firstWhereOrNull((h) => h.subjectId == subjectId);
  }

  /// 删除历史记录
  Future<void> removeHistory(int subjectId) async {
    histories.removeWhere((h) => h.subjectId == subjectId);
    await _saveHistories();
    AppLogger().d('删除播放历史: $subjectId');
  }

  /// 清空所有历史
  Future<void> clearAll() async {
    histories.clear();
    await _saveHistories();
    AppLogger().d('清空所有播放历史');
  }

  /// 获取最近观看的 N 条记录
  List<PlayHistory> getRecent({int limit = 10}) {
    return histories.take(limit).toList();
  }

  /// 获取正在观看的记录
  List<PlayHistory> getWatching() {
    return histories
        .where((h) => !h.isCompleted && h.currentEpisode > 0)
        .toList();
  }
}
