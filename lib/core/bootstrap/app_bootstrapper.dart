/// 应用初始化引导类
///
/// 负责应用启动时的依赖注入和服务初始化
///
/// @author AmisKwok
library;

import 'dart:io';
import 'package:amis_flutter_utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wizard_player_torrent/wizard_player_torrent.dart';
import 'package:wizard_player_media/wizard_player_media.dart';
import 'package:wizardplayer/core/abstractions/di.dart';
import 'package:wizardplayer/core/managers/language_manager.dart';
import 'package:wizardplayer/core/managers/theme_manager.dart';
import 'package:wizardplayer/core/services/bangumi_service.dart';
import 'package:wizardplayer/core/services/play_history_service.dart';
import 'package:wizardplayer/data/repositories/play_history_repository.dart';
import 'package:wizardplayer/data/repositories/video_repository.dart';

/// 应用初始化状态
enum AppInitializationStep {
  spUtil,
  mediaEngine,
  torrentEngine,
  repositories,
  services,
  managers,
  complete,
}

/// 应用初始化结果
class AppInitializationResult {
  final bool success;
  final String? error;
  final List<AppInitializationStep> completedSteps;

  const AppInitializationResult({
    required this.success,
    this.error,
    this.completedSteps = const [],
  });

  factory AppInitializationResult.success(List<AppInitializationStep> steps) {
    return AppInitializationResult(success: true, completedSteps: steps);
  }

  factory AppInitializationResult.failure(
    String error,
    List<AppInitializationStep> steps,
  ) {
    return AppInitializationResult(
      success: false,
      error: error,
      completedSteps: steps,
    );
  }
}

/// 应用引导类
/// 负责启动时的依赖注入和服务初始化
class AppBootstrapper {
  AppBootstrapper._();

  /// 初始化应用
  /// 返回初始化结果
  static Future<AppInitializationResult> bootstrap() async {
    final completedSteps = <AppInitializationStep>[];

    try {
      // 1. 初始化 Shared Preferences
      AppLogger().d('初始化 SpUtil...');
      await SpUtil.init();
      AppLogger().d('SpUtil 初始化完成');
      completedSteps.add(AppInitializationStep.spUtil);

      // 2. 初始化媒体播放引擎
      _ensureMediaEngineInitialized();
      completedSteps.add(AppInitializationStep.mediaEngine);

      // 3. 初始化 BT 播放器
      final torrentEngine = await _initializeTorrentEngine();
      completedSteps.add(AppInitializationStep.torrentEngine);

      // 4. 初始化仓库
      final repositories = _initializeRepositories();
      completedSteps.add(AppInitializationStep.repositories);

      // 5. 初始化服务
      final services = await _initializeServices();
      completedSteps.add(AppInitializationStep.services);

      // 6. 注册全局管理器
      _registerManagers(
        torrentEngine: torrentEngine,
        repositories: repositories,
        services: services,
      );
      completedSteps.add(AppInitializationStep.managers);

      completedSteps.add(AppInitializationStep.complete);
      return AppInitializationResult.success(completedSteps);
    } catch (e, stackTrace) {
      // 记录错误但继续运行
      AppLogger().e('初始化警告: $e\n$stackTrace');
      return AppInitializationResult.failure(e.toString(), completedSteps);
    }
  }

  /// 确保媒体引擎已初始化
  static void _ensureMediaEngineInitialized() {
    ensureWizardPlayerMediaInitialized();
  }

  /// 初始化 BT 播放器引擎
  static Future<WizardPlayerTorrent> _initializeTorrentEngine() async {
    final tempDir = await getTemporaryDirectory();
    final torrentCacheDir = Directory('${tempDir.path}/wizard_torrents');
    if (!await torrentCacheDir.exists()) {
      await torrentCacheDir.create(recursive: true);
    }
    final torrentEngine = WizardPlayerTorrent();
    await torrentEngine.initialize(cacheDir: torrentCacheDir.path);
    return torrentEngine;
  }

  /// 初始化仓库
  static _Repositories _initializeRepositories() {
    final playHistoryRepository = PlayHistoryRepository();
    final videoRepository = VideoRepository();
    return _Repositories(
      playHistoryRepository: playHistoryRepository,
      videoRepository: videoRepository,
    );
  }

  /// 初始化服务
  static Future<_Services> _initializeServices() async {
    final bangumiService = BangumiService();
    await bangumiService.init();
    return _Services(bangumiService: bangumiService);
  }

  /// 注册全局管理器
  static void _registerManagers({
    required WizardPlayerTorrent torrentEngine,
    required _Repositories repositories,
    required _Services services,
  }) {
    // 创建管理器实例
    final themeManager = ThemeManager();
    final languageManager = LanguageManager();

    // 注册到 DI 容器
    DI.put(themeManager);
    DI.put(languageManager);
    DI.put(repositories.playHistoryRepository);
    DI.put(repositories.videoRepository);
    DI.put(services.bangumiService);
    DI.put(torrentEngine);

    // PlayHistoryManager 依赖其他服务，需要特殊处理
    // 由于 PlayHistoryManager 继承自 GetxController，
    // 它会在首次被获取时自动初始化
    // 这里先注册一个工厂函数
    DI.lazyPut<PlayHistoryManager>(() => PlayHistoryManager());
  }

  /// 获取 PlayHistoryManager（延迟获取，确保依赖已注册）
  static PlayHistoryManager getPlayHistoryManager() {
    return DI.get<PlayHistoryManager>();
  }
}

/// 仓库集合
class _Repositories {
  final PlayHistoryRepository playHistoryRepository;
  final VideoRepository videoRepository;

  const _Repositories({
    required this.playHistoryRepository,
    required this.videoRepository,
  });
}

/// 服务集合
class _Services {
  final BangumiService bangumiService;

  const _Services({required this.bangumiService});
}
