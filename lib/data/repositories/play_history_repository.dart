/// 播放历史记录仓库
///
/// @author AmisKwok
library;

import 'dart:convert';
import 'package:amis_flutter_utils/utils.dart';
import 'package:wizardplayer/data/models/play_history_model.dart';

/// SpUtil 存储接口（用于依赖注入）
abstract class ISpUtil {
  T? get<T>(String key);
  Future<bool> put(String key, dynamic value);
  Future<bool> remove(String key);
}

/// SpUtil 默认实现
class SpUtilImpl implements ISpUtil {
  @override
  T? get<T>(String key) => SpUtil.get<T>(key);

  @override
  Future<bool> put(String key, dynamic value) => SpUtil.put(key, value);

  @override
  Future<bool> remove(String key) => SpUtil.remove(key);
}

/// 播放历史记录仓库接口
abstract class IPlayHistoryRepository {
  /// 获取所有播放历史
  Future<List<PlayHistoryModel>> getAllHistory();

  /// 根据视频ID获取历史记录
  Future<PlayHistoryModel?> getHistoryByVideoId(String videoId);

  /// 保存播放历史
  Future<void> saveHistory(PlayHistoryModel history);

  /// 删除播放历史
  Future<void> deleteHistory(String historyId);

  /// 清除所有历史
  Future<void> clearAllHistory();
}

/// 播放历史记录仓库实现
class PlayHistoryRepository implements IPlayHistoryRepository {
  /// Shared Preferences 存储键
  static const String _keyHistory = 'play_history';

  /// 存储接口实例
  final ISpUtil _sp;

  /// 构造函数，支持依赖注入
  /// [sp] 存储接口实例，默认为 SpUtilImpl
  PlayHistoryRepository({ISpUtil? sp}) : _sp = sp ?? SpUtilImpl();

  @override
  Future<List<PlayHistoryModel>> getAllHistory() async {
    try {
      final jsonString = _sp.get<String>(_keyHistory);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map(
            (json) => PlayHistoryModel.fromJson(json as Map<String, dynamic>),
          )
          .toList()
        ..sort((a, b) => b.lastWatchTime.compareTo(a.lastWatchTime));
    } catch (e, stackTrace) {
      AppLogger().e('获取播放历史失败', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<PlayHistoryModel?> getHistoryByVideoId(String videoId) async {
    try {
      final histories = await getAllHistory();
      for (final history in histories) {
        if (history.videoId == videoId) {
          return history;
        }
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger().e('获取视频历史记录失败', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<void> saveHistory(PlayHistoryModel history) async {
    try {
      final histories = await getAllHistory();
      // 查找是否已存在相同视频的记录
      final index = histories.indexWhere((h) => h.videoId == history.videoId);
      if (index != -1) {
        // 更新现有记录
        histories[index] = history;
      } else {
        // 添加新记录
        histories.add(history);
      }
      // 保存
      final jsonString = json.encode(histories.map((h) => h.toJson()).toList());
      await _sp.put(_keyHistory, jsonString);
      AppLogger().d('保存播放历史成功，视频ID: ${history.videoId}');
    } catch (e, stackTrace) {
      AppLogger().e('保存播放历史失败', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> deleteHistory(String historyId) async {
    try {
      final histories = await getAllHistory();
      histories.removeWhere((h) => h.id == historyId);
      final jsonString = json.encode(histories.map((h) => h.toJson()).toList());
      await _sp.put(_keyHistory, jsonString);
      AppLogger().d('删除播放历史成功，历史ID: $historyId');
    } catch (e, stackTrace) {
      AppLogger().e('删除播放历史失败', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> clearAllHistory() async {
    try {
      await _sp.remove(_keyHistory);
      AppLogger().d('清除所有播放历史成功');
    } catch (e, stackTrace) {
      AppLogger().e('清除播放历史失败', error: e, stackTrace: stackTrace);
    }
  }
}
