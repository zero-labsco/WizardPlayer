import 'dart:async';
import '../sources/data_source.dart';

/// 源评估结果
class SourceEvaluation {
  /// 数据源
  final VideoDataSource source;

  /// 评分（0.0 - 1.0）
  final double score;

  /// 是否可用
  final bool available;

  /// 预估加载时间
  final Duration? estimatedLoadTime;

  /// 评分原因
  final String? reason;

  const SourceEvaluation({
    required this.source,
    required this.score,
    required this.available,
    this.estimatedLoadTime,
    this.reason,
  });
}

/// 智能源选择器
class SourceSelector {
  final List<VideoDataSource> _sources;

  /// 最大并发测试数
  final int maxConcurrentTests;

  /// 测试超时时间
  final Duration testTimeout;

  SourceSelector({
    required List<VideoDataSource> sources,
    this.maxConcurrentTests = 3,
    this.testTimeout = const Duration(seconds: 10),
  }) : _sources = sources
         ..sort((a, b) => b.config.priority.compareTo(a.config.priority));

  /// 选择最佳数据源
  Future<SourceEvaluation> selectBest(String episodeId) async {
    // 并行测试所有源的可用性
    final evaluations = await _testAllSources(episodeId);

    // 按分数排序
    evaluations.sort((a, b) => b.score.compareTo(a.score));

    // 返回评分最高的可用源
    final available = evaluations.where((e) => e.available);
    if (available.isEmpty) {
      // 如果没有可用源，返回评分最高的（即使不可用）
      return evaluations.first;
    }

    return available.first;
  }

  /// 获取所有源的评估结果
  Future<List<SourceEvaluation>> _testAllSources(String episodeId) async {
    final results = <SourceEvaluation>[];

    for (var i = 0; i < _sources.length; i += maxConcurrentTests) {
      final batch = _sources.skip(i).take(maxConcurrentTests);
      final batchResults = await Future.wait(
        batch.map((source) => _evaluateSource(source, episodeId)),
      );
      results.addAll(batchResults);
    }

    return results;
  }

  /// 评估单个源
  Future<SourceEvaluation> _evaluateSource(
    VideoDataSource source,
    String episodeId,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 测试数据源可用性
      final available = await Future.any([
        source.testAvailability(),
        Future.delayed(testTimeout, () => false),
      ]);

      stopwatch.stop();

      if (!available) {
        return SourceEvaluation(
          source: source,
          score: 0.0,
          available: false,
          reason: '数据源不可用',
        );
      }

      // 测试获取播放链接
      try {
        await source.getPlayableMedia(episodeId);
        stopwatch.stop();

        // 计算评分
        final loadTime = stopwatch.elapsed;
        final score = _calculateScore(
          source.config.priority,
          loadTime,
          available,
        );

        return SourceEvaluation(
          source: source,
          score: score,
          available: true,
          estimatedLoadTime: loadTime,
          reason: '响应时间: ${loadTime.inMilliseconds}ms',
        );
      } catch (e) {
        stopwatch.stop();
        return SourceEvaluation(
          source: source,
          score: 0.1,
          available: false,
          estimatedLoadTime: stopwatch.elapsed,
          reason: '获取播放链接失败: $e',
        );
      }
    } catch (e) {
      stopwatch.stop();
      return SourceEvaluation(
        source: source,
        score: 0.0,
        available: false,
        estimatedLoadTime: stopwatch.elapsed,
        reason: '测试失败: $e',
      );
    }
  }

  /// 计算评分
  double _calculateScore(int priority, Duration loadTime, bool available) {
    if (!available) return 0.0;

    // 基础分数（基于优先级）
    double score = (priority / 100.0).clamp(0.0, 1.0) * 0.3;

    // 响应时间分数（越快越好）
    if (loadTime.inMilliseconds < 500) {
      score += 0.5;
    } else if (loadTime.inMilliseconds < 1000) {
      score += 0.4;
    } else if (loadTime.inMilliseconds < 2000) {
      score += 0.3;
    } else if (loadTime.inMilliseconds < 5000) {
      score += 0.2;
    } else {
      score += 0.1;
    }

    // 可用性分数
    score += 0.2;

    return score.clamp(0.0, 1.0);
  }

  /// 获取所有可用源
  Future<List<SourceEvaluation>> getAvailableSources(String episodeId) async {
    final evaluations = await _testAllSources(episodeId);
    return evaluations.where((e) => e.available).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }
}
