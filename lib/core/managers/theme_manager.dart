/// 主题管理器
///
/// 管理应用的主题切换和记忆
///
/// @author AmisKwok
library;

import 'package:amis_flutter_utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wizardplayer/core/implementations/state_provider_impl.dart';

/// 主题管理器
class ThemeManager extends GetxController {
  /// Shared Preferences 存储键
  static const String _keyTheme = 'app_theme';

  /// 当前主题模式
  final StateProviderImpl<ThemeMode> themeMode;

  /// 构造函数
  ThemeManager() : themeMode = StateProviderImpl<ThemeMode>(ThemeMode.system);

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// 加载保存的主题
  Future<void> _loadTheme() async {
    try {
      AppLogger().d('开始加载主题设置...');
      final savedThemeIndex = SpUtil.get<int>(_keyTheme);
      if (savedThemeIndex != null &&
          savedThemeIndex >= 0 &&
          savedThemeIndex < ThemeMode.values.length) {
        AppLogger().d('找到保存的主题: ${ThemeMode.values[savedThemeIndex].name}');
        themeMode.value = ThemeMode.values[savedThemeIndex];
      }
    } catch (e, stackTrace) {
      AppLogger().e('加载主题失败', error: e, stackTrace: stackTrace);
    }
  }

  /// 切换主题
  Future<void> changeTheme(ThemeMode newTheme) async {
    if (themeMode.value == newTheme) return;

    try {
      themeMode.value = newTheme;
      // 保存到本地存储
      await SpUtil.put(_keyTheme, newTheme.index);
      // 更新 GetX 主题
      Get.changeThemeMode(newTheme);
      // 通知 GetBuilder 更新
      update();
      AppLogger().d('主题已切换为: ${newTheme.name}');
    } catch (e, stackTrace) {
      AppLogger().e('切换主题失败', error: e, stackTrace: stackTrace);
    }
  }
}
