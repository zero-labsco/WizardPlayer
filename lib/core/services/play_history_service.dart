import 'package:get/get.dart';
import 'package:amis_flutter_utils/utils.dart';
import 'package:wizardplayer/core/abstractions/di.dart';
import 'package:wizardplayer/data/models/play_history_model.dart';
import 'package:wizardplayer/data/repositories/play_history_repository.dart';

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

  /// 播放历史仓库
  late final PlayHistoryRepository _repository;

  @override
  void onInit() {
    super.onInit();
    _repository = DI.get<PlayHistoryRepository>();
    _loadHistories();
  }

  /// 从仓库加载历史记录并转换为 PlayHistory
  Future<void> _loadHistories() async {
    try {
      final models = await _repository.getAllHistory();
      final invalidIds = <String>[];

      // 已知测试视频的 hashCode（用于检测脏数据）
      // const testVideoHashCode = 'test_video_001'.hashCode.toString();

      final list = <PlayHistory>[];
      for (final model in models) {
        final videoId = model.videoId;

        // 检测脏数据：videoId 等于测试视频的 hashCode
        if (videoId == _testVideoHashCode) {
          AppLogger().w('🗑️ 检测到脏数据（测试视频 hashCode），videoId: $videoId');
          invalidIds.add(videoId);
          continue;
        }

        final history = _modelToPlayHistory(model);
        if (history != null) {
          list.add(history);
        } else {
          invalidIds.add(videoId);
        }
      }

      // 删除无效的历史记录
      for (final id in invalidIds) {
        await _repository.deleteHistory(id);
        AppLogger().d('🗑️ 删除无效历史记录: $id');
      }

      histories.assignAll(list);
      AppLogger().d('加载播放历史: ${list.length} 条');
    } catch (e, stackTrace) {
      AppLogger().e('加载历史记录失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 测试视频的 subjectId（使用负数避免与真实番剧 id 冲突）
  static const int _testVideoSubjectId = -999999;

  /// 测试视频的 hashCode（用于检测脏数据）
  static const String _testVideoHashCode = '609785636';

  /// 将 PlayHistoryModel 转换为 PlayHistory
  /// 如果 videoId 是修复前错误存储的 hashCode 值，返回 null 表示需要删除
  PlayHistory? _modelToPlayHistory(PlayHistoryModel model) {
    final videoId = model.videoId;

    // 如果 videoId 是 "test_video_001" 这样的测试视频 ID
    if (videoId == 'test_video_001') {
      return PlayHistory(
        subjectId: _testVideoSubjectId, // 测试视频用固定负数作为 subjectId
        subjectName: model.videoTitle,
        coverUrl: model.coverUrl.isNotEmpty ? model.coverUrl : null,
        currentEpisode: model.episodeNumber,
        totalEpisodes: (model.duration > 0) ? model.episodeNumber : 0,
        lastPosition: model.position ~/ 1000,
        totalDuration: model.duration ~/ 1000,
        lastPlayedAt: model.lastWatchTime,
      );
    }

    // 正常情况：尝试解析 videoId 为整数
    final subjectId = int.tryParse(videoId);
    if (subjectId != null) {
      return PlayHistory(
        subjectId: subjectId,
        subjectName: model.videoTitle,
        coverUrl: model.coverUrl.isNotEmpty ? model.coverUrl : null,
        currentEpisode: model.episodeNumber,
        totalEpisodes: (model.duration > 0) ? model.episodeNumber : 0,
        lastPosition: model.position ~/ 1000,
        totalDuration: model.duration ~/ 1000,
        lastPlayedAt: model.lastWatchTime,
      );
    }

    // videoId 是修复前错误存储的 hashCode（无法解析为 int，且不是测试视频）
    // 返回 null 表示这条记录无效
    AppLogger().w('⚠️ 无效的历史记录，videoId: $videoId，将被删除');
    return null;
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

    // 转换为 PlayHistoryModel 并保存到仓库
    final model = PlayHistoryModel(
      id: subjectId.toString(),
      videoId: subjectId.toString(),
      videoTitle: subjectName,
      coverUrl: coverUrl ?? '',
      episodeNumber: currentEpisode,
      position: lastPosition * 1000, // 秒转毫秒
      duration: totalDuration * 1000,
      lastWatchTime: now,
    );

    await _repository.saveHistory(model);

    // 更新本地列表
    // updateHistory 中 videoId 是 subjectId.toString()，必定能正确解析
    final existingIndex = histories.indexWhere((h) => h.subjectId == subjectId);
    final newHistory = _modelToPlayHistory(model)!; // updateHistory 中必定不为 null

    if (existingIndex != -1) {
      histories[existingIndex] = newHistory;
    } else {
      histories.insert(0, newHistory);
      if (histories.length > _maxHistories) {
        histories.removeLast();
      }
    }

    AppLogger().d('更新播放历史: $subjectName - 第 $currentEpisode 集');
  }

  /// 获取指定番剧的历史记录
  PlayHistory? getHistory(int subjectId) {
    return histories.firstWhereOrNull((h) => h.subjectId == subjectId);
  }

  /// 删除历史记录
  Future<void> removeHistory(int subjectId) async {
    histories.removeWhere((h) => h.subjectId == subjectId);
    await _repository.deleteHistory(subjectId.toString());
    AppLogger().d('删除播放历史: $subjectId');
  }

  /// 清空所有历史
  Future<void> clearAll() async {
    histories.clear();
    await _repository.clearAllHistory();
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
