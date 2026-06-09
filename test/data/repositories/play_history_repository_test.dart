import 'package:amis_flutter_utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizardplayer/data/models/play_history_model.dart';
import 'package:wizardplayer/data/repositories/play_history_repository.dart';

/// MockSpUtil - 用于单元测试的内存存储模拟
class MockSpUtil implements ISpUtil {
  final Map<String, dynamic> _storage = {};

  @override
  T? get<T>(String key) {
    return _storage[key] as T?;
  }

  @override
  Future<bool> put(String key, dynamic value) async {
    _storage[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }

  /// 清除所有存储（测试辅助方法）
  void clear() {
    _storage.clear();
  }
}

void main() {
  late PlayHistoryRepository repository;
  late MockSpUtil mockSpUtil;

  setUp(() {
    AppLogger().initialize();
    mockSpUtil = MockSpUtil();
    repository = PlayHistoryRepository(sp: mockSpUtil);
  });

  /// PlayHistoryRepository 测试组
  /// 测试播放历史记录的增删改查功能
  group('PlayHistoryRepository', () {
    final testHistory1 = PlayHistoryModel(
      id: '1',
      videoId: 'video1',
      videoTitle: 'Test Video 1',
      coverUrl: 'https://example.com/cover1.jpg',
      episodeNumber: 1,
      position: 30000, // 30秒（毫秒）
      duration: 1200000, // 20分钟（毫秒）
      lastWatchTime: DateTime(2024, 1, 1, 10, 0),
    );

    final testHistory2 = PlayHistoryModel(
      id: '2',
      videoId: 'video2',
      videoTitle: 'Test Video 2',
      coverUrl: 'https://example.com/cover2.jpg',
      episodeNumber: 2,
      position: 50000, // 50秒（毫秒）
      duration: 1800000, // 30分钟（毫秒）
      lastWatchTime: DateTime(2024, 1, 2, 15, 30),
    );

    /// 测试场景：没有任何历史记录
    /// 验证点：返回空列表
    test('无历史记录时返回空列表', () async {
      final result = await repository.getAllHistory();
      expect(result, isEmpty);
    });

    /// 测试场景：保存一条新的历史记录
    /// 验证点：记录被正确保存
    test('保存新历史记录成功', () async {
      await repository.saveHistory(testHistory1);
      final result = await repository.getAllHistory();
      expect(result.length, 1);
      expect(result[0].videoId, 'video1');
    });

    /// 测试场景：保存相同 videoId 的记录（更新进度）
    /// 验证点：原有记录被更新，而不是新增重复记录
    test('更新相同视频记录时不产生重复', () async {
      await repository.saveHistory(testHistory1);

      final updatedHistory = testHistory1.copyWith(
        episodeNumber: 2,
        position: 60000, // 60秒
      );
      await repository.saveHistory(updatedHistory);

      final result = await repository.getAllHistory();
      expect(result.length, 1); // 应该只有一条记录
      expect(result[0].episodeNumber, 2);
      expect(result[0].position, 60000);
    });

    /// 测试场景：保存多条记录后，按 videoId 查询
    /// 验证点：返回正确的历史记录
    test('根据videoId查询返回正确记录', () async {
      await repository.saveHistory(testHistory1);
      await repository.saveHistory(testHistory2);

      final result = await repository.getHistoryByVideoId('video1');
      expect(result?.videoId, 'video1');
      expect(result?.videoTitle, 'Test Video 1');
    });

    /// 测试场景：根据不存在的 videoId 查询
    /// 验证点：返回 null
    test('查询不存在的videoId返回null', () async {
      await repository.saveHistory(testHistory1);

      final result = await repository.getHistoryByVideoId('nonexistent');
      expect(result, isNull);
    });

    /// 测试场景：删除指定的历史记录
    /// 验证点：删除后列表中不再包含该记录
    test('删除历史记录成功', () async {
      await repository.saveHistory(testHistory1);
      await repository.saveHistory(testHistory2);

      await repository.deleteHistory('1');

      final result = await repository.getAllHistory();
      expect(result.length, 1);
      expect(result[0].id, '2'); // 应该只剩下 testHistory2
    });

    /// 测试场景：清空所有历史记录
    /// 验证点：列表为空
    test('清空所有历史记录成功', () async {
      await repository.saveHistory(testHistory1);
      await repository.saveHistory(testHistory2);

      await repository.clearAllHistory();

      final result = await repository.getAllHistory();
      expect(result, isEmpty);
    });

    /// 测试场景：多条记录按时间排序
    /// 验证点：返回的列表按 lastWatchTime 降序排列（最新的在前）
    test('历史记录按最后观看时间降序排列', () async {
      await repository.saveHistory(testHistory1); // 2024-01-01 10:00
      await repository.saveHistory(testHistory2); // 2024-01-02 15:30

      final result = await repository.getAllHistory();

      expect(result.length, 2);
      expect(result[0].id, '2'); // testHistory2 时间更新，应该在前面
      expect(result[1].id, '1');
    });
  });
}
