import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:amis_flutter_utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wizard_player_torrent/wizard_player_torrent.dart';
import 'package:wizard_player_media/wizard_player_media.dart';
import 'package:wizardplayer/core/l10n/app_localizations.dart';
import 'package:wizardplayer/core/managers/language_manager.dart';
import 'package:wizardplayer/core/managers/theme_manager.dart';
import 'package:wizardplayer/core/theme/app_theme.dart';
import 'package:wizardplayer/core/services/play_history_service.dart';
import 'package:wizardplayer/core/services/bangumi_service.dart';
import 'package:wizardplayer/data/repositories/play_history_repository.dart';
import 'package:wizardplayer/data/repositories/video_repository.dart';
import 'package:wizardplayer/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化媒体播放引擎（libmpv）——必须在任何视频播放前调用
  ensureWizardPlayerMediaInitialized();

  // 移动端只允许竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 初始化日志
  AppLogger().initialize();
  AppLogger().d('应用开始初始化...');

  try {
    // 初始化 Shared Preferences
    AppLogger().d('初始化 SpUtil...');
    await SpUtil.init();
    AppLogger().d('SpUtil 初始化完成');

    // 初始化 BT 播放器
    AppLogger().d('初始化 WizardPlayerTorrent...');
    final tempDir = await getTemporaryDirectory();
    final torrentCacheDir = Directory('${tempDir.path}/wizard_torrents');
    if (!await torrentCacheDir.exists()) {
      await torrentCacheDir.create(recursive: true);
    }
    final wizardPlayerTorrent = WizardPlayerTorrent();
    await wizardPlayerTorrent.initialize(cacheDir: torrentCacheDir.path);
    AppLogger().d('WizardPlayerTorrent 初始化完成');

    // 全局注册管理器
    AppLogger().d('注册管理器...');
    final themeManager = ThemeManager();
    final languageManager = LanguageManager();

    // 初始化仓库（数据源已在 VideoRepository 内部初始化）
    AppLogger().d('初始化仓库...');
    final playHistoryRepository = PlayHistoryRepository();
    final videoRepository = VideoRepository();

    // 初始化 BangumiService
    AppLogger().d('初始化 BangumiService...');
    final bangumiService = BangumiService();
    await bangumiService.init();

    Get.put(themeManager);
    Get.put(languageManager);
    Get.put(PlayHistoryManager());
    Get.put(playHistoryRepository);
    Get.put(videoRepository);
    Get.put(wizardPlayerTorrent);
    Get.put(bangumiService);
    AppLogger().d('管理器注册完成');

    // 等待管理器初始化
    AppLogger().d('等待管理器加载数据...');
    await Future.delayed(const Duration(milliseconds: 100));
    AppLogger().d('管理器初始化完成');

    runApp(const MyApp());
  } catch (e, stackTrace) {
    AppLogger().e('初始化失败', error: e, stackTrace: stackTrace);
    // 即使出错也尝试运行应用
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Get.find<ThemeManager>();
    final languageManager = Get.find<LanguageManager>();

    return GetBuilder<ThemeManager>(
      init: themeManager,
      builder: (_) => GetBuilder<LanguageManager>(
        init: languageManager,
        builder: (_) => GetMaterialApp(
          title: 'Wizard Player',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeManager.themeMode.value,
          locale: languageManager.locale,
          fallbackLocale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('zh')],
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
