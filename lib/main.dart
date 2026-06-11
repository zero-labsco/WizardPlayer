import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amis_flutter_utils/utils.dart';
import 'package:wizardplayer/core/bootstrap/app_bootstrapper.dart';
import 'package:wizardplayer/core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志（保留在 main 中）
  AppLogger().initialize();
  AppLogger().d('应用开始初始化...');

  // 移动端只允许竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 引导应用初始化（包含 SpUtil、媒体引擎、仓库、服务、管理器）
  AppLogger().d('开始引导初始化...');
  final result = await AppBootstrapper.bootstrap();

  if (result.success) {
    AppLogger().d('应用初始化完成');
  } else {
    AppLogger().e('应用初始化存在错误: ${result.error}');
  }

  runApp(AppConfig.buildApp());
}
