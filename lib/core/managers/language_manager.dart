/// 语言管理器
///
/// 管理应用的语言切换和记忆
///
/// @author AmisKwok
library;

import 'package:amis_flutter_utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wizardplayer/core/implementations/state_provider_impl.dart';
import 'package:wizardplayer/enum/language.dart';

/// 语言管理器
class LanguageManager extends GetxController {
  /// Shared Preferences 存储键
  static const String _keyLanguage = 'app_language';

  /// 当前语言
  final StateProviderImpl<AppLanguage> language;

  /// 获取当前语言的 Locale
  Locale get locale => Locale(language.value.code);

  /// 构造函数
  LanguageManager() : language = StateProviderImpl<AppLanguage>(AppLanguage.english);

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  /// 加载保存的语言
  Future<void> _loadLanguage() async {
    try {
      AppLogger().d('开始加载语言设置...');
      final savedLanguageCode = SpUtil.get<String>(_keyLanguage);
      if (savedLanguageCode != null && savedLanguageCode.isNotEmpty) {
        AppLogger().d('找到保存的语言: $savedLanguageCode');
        language.value = AppLanguage.fromCode(savedLanguageCode);
      } else {
        AppLogger().d('首次打开，跟随系统语言');
        // 首次打开，跟随系统语言
        _followSystemLanguage();
      }
    } catch (e, stackTrace) {
      AppLogger().e('加载语言失败', error: e, stackTrace: stackTrace);
      _followSystemLanguage();
    }
  }

  /// 跟随系统语言
  void _followSystemLanguage() {
    try {
      final systemLocale = Get.deviceLocale;
      if (systemLocale != null) {
        language.value = AppLanguage.fromCode(systemLocale.languageCode);
      } else {
        language.value = AppLanguage.english;
      }
    } catch (e, stackTrace) {
      AppLogger().e('获取系统语言失败', error: e, stackTrace: stackTrace);
      language.value = AppLanguage.english;
    }
  }

  /// 切换语言
  Future<void> changeLanguage(AppLanguage newLanguage) async {
    if (language.value == newLanguage) return;

    try {
      language.value = newLanguage;
      // 保存到本地存储
      await SpUtil.put(_keyLanguage, newLanguage.code);
      // 更新 GetX 语言
      Get.updateLocale(Locale(newLanguage.code));
      // 通知 GetBuilder 更新
      update();
      AppLogger().d('语言已切换为: ${newLanguage.name}');
    } catch (e, stackTrace) {
      AppLogger().e('切换语言失败', error: e, stackTrace: stackTrace);
    }
  }
}
