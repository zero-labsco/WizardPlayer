/// 应用配置
///
/// 配置 GetMaterialApp 的主题、语言和本地化
///
/// @author AmisKwok
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:wizardplayer/core/abstractions/di.dart';
import 'package:wizardplayer/core/l10n/app_localizations.dart';
import 'package:wizardplayer/core/theme/app_theme.dart';
import 'package:wizardplayer/core/managers/theme_manager.dart';
import 'package:wizardplayer/core/managers/language_manager.dart';
import 'package:wizardplayer/presentation/screens/home_screen.dart';

/// 应用配置
/// 配置 GetMaterialApp 的根组件
class AppConfig {
  AppConfig._();

  /// 创建 GetMaterialApp
  static Widget buildApp() {
    return const _AppRoot();
  }
}

/// 应用根组件
class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    // 获取已注册的 ThemeManager 和 LanguageManager
    final themeManager = DI.get<ThemeManager>();
    final languageManager = DI.get<LanguageManager>();

    return GetBuilder<ThemeManager>(
      init: themeManager,
      builder: (theme) => GetBuilder<LanguageManager>(
        init: languageManager,
        builder: (lang) => GetMaterialApp(
          title: 'Wizard Player',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: theme.themeMode.value,
          locale: lang.locale,
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
