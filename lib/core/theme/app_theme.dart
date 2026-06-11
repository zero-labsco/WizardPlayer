/// 应用主题配置
///
/// 采用现代 Material Design 3
/// @author WizardPlayer
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 获取iOS平台的页面过渡构建器（兼容所有平台）
PageTransitionsBuilder _getIosPageTransitionBuilder() {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return const CupertinoPageTransitionsBuilder();
  }
  return const FadeUpwardsPageTransitionsBuilder();
}

/// 应用主题配置
class AppTheme {
  // ==================== 颜色系统 ====================

  /// 主色 - 深紫色
  static const Color _primaryColor = Color(0xFF6366F1);

  /// 次要色 - 青色
  static const Color _secondaryColor = Color(0xFF06B6D4);

  /// 强调色 - 粉色
  static const Color _accentColor = Color(0xFFEC4899);

  /// 背景色 - 浅色模式
  static const Color _lightBackground = Color(0xFFF8FAFC);

  /// 背景色 - 深色模式
  static const Color _darkBackground = Color(0xFF0F172A);

  /// 卡片色 - 浅色模式
  static const Color _lightCard = Color(0xFFFFFFFF);

  /// 卡片色 - 深色模式
  static const Color _darkCard = Color(0xFF1E293B);

  // ==================== 浅色主题 ====================

  /// 浅色主题
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _accentColor,
      surface: _lightCard,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,

      // 应用栏
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: _lightBackground,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 卡片
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _lightCard,
      ),

      // 按钮
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // 输入框
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
      ),

      // 底部导航
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _lightCard,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        elevation: 8,
      ),

      // 导航轨道
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _lightCard,
        selectedIconTheme: const IconThemeData(color: _primaryColor),
        unselectedIconTheme: IconThemeData(color: Colors.grey.shade500),
        indicatorColor: _primaryColor.withValues(alpha: 0.1),
      ),

      // 进度条
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryColor,
        linearTrackColor: Color(0xFFE2E8F0),
      ),

      // 滑块
      sliderTheme: SliderThemeData(
        activeTrackColor: _primaryColor,
        inactiveTrackColor: Colors.grey.shade300,
        thumbColor: _primaryColor,
        overlayColor: _primaryColor.withValues(alpha: 0.2),
      ),

      // 文字主题
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
      ),

      // 分割线
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),

      // 页面过渡
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: _getIosPageTransitionBuilder(),
          TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: const FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: const FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ==================== 深色主题 ====================

  /// 深色主题
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _accentColor,
      surface: _darkCard,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,

      // 应用栏
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: _darkBackground,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 卡片
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: _darkCard,
      ),

      // 按钮
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // 输入框
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
      ),

      // 底部导航
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _darkCard,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        elevation: 8,
      ),

      // 导航轨道
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _darkCard,
        selectedIconTheme: const IconThemeData(color: _primaryColor),
        unselectedIconTheme: IconThemeData(color: Colors.grey.shade500),
        indicatorColor: _primaryColor.withValues(alpha: 0.2),
      ),

      // 进度条
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primaryColor,
        linearTrackColor: Colors.grey.shade800,
      ),

      // 滑块
      sliderTheme: SliderThemeData(
        activeTrackColor: _primaryColor,
        inactiveTrackColor: Colors.grey.shade700,
        thumbColor: _primaryColor,
        overlayColor: _primaryColor.withValues(alpha: 0.2),
      ),

      // 文字主题
      textTheme: TextTheme(
        headlineLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.grey.shade300),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.grey.shade400),
        bodySmall: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),

      // 分割线
      dividerTheme: DividerThemeData(color: Colors.grey.shade800, thickness: 1),

      // 页面过渡
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: _getIosPageTransitionBuilder(),
          TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: const FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: const FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
