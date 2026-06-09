/// 应用颜色常量
///
/// 统一管理所有硬编码颜色，避免魔法数字
///
/// @author WizardPlayer
library;

import 'package:flutter/material.dart';

/// 应用颜色常量
class AppColors {
  // ==================== 主题色 ====================

  /// 主色 - 深紫色
  static const Color primary = Color(0xFF6366F1);

  /// 次要色 - 青色
  static const Color secondary = Color(0xFF06B6D4);

  /// 强调色 - 粉色
  static const Color accent = Color(0xFFEC4899);

  /// 成功色
  static const Color success = Color(0xFF22C55E);

  /// 警告色
  static const Color warning = Color(0xFFF59E0B);

  /// 错误色
  static const Color error = Color(0xFFEF4444);

  /// 信息色
  static const Color info = Color(0xFF3B82F6);

  // ==================== 背景色 ====================

  /// 背景色 - 浅色模式
  static const Color lightBackground = Color(0xFFF8FAFC);

  /// 背景色 - 深色模式
  static const Color darkBackground = Color(0xFF0F172A);

  /// 卡片色 - 浅色模式
  static const Color lightCard = Color(0xFFFFFFFF);

  /// 卡片色 - 深色模式
  static const Color darkCard = Color(0xFF1E293B);

  /// 播放器背景色 - 浅色模式（深灰色，用于区分视频内容）
  static const Color lightPlayerBackground = Color(0xFF1E1E1E);

  // ==================== 文字颜色 ====================

  /// 文字主色 - 浅色模式
  static const Color lightTextPrimary = Color(0xFF1E293B);

  /// 文字主色 - 深色模式
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  /// 文字次要色 - 浅色模式
  static const Color lightTextSecondary = Color(0xFF64748B);

  /// 文字次要色 - 深色模式
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  /// 文字提示色 - 浅色模式
  static const Color lightTextHint = Color(0xFF94A3B8);

  /// 文字提示色 - 深色模式
  static const Color darkTextHint = Color(0xFF64748B);

  // ==================== 边框颜色 ====================

  /// 边框色 - 浅色模式
  static const Color lightBorder = Color(0xFFE2E8F0);

  /// 边框色 - 深色模式
  static const Color darkBorder = Color(0xFF334155);

  // ==================== 透明度相关 ====================

  /// 黑色半透明（用于图片遮罩）
  static const Color black54 = Color(0x8A000000);

  /// 黑色 70% 透明度
  static const Color black70 = Color(0xB3000000);

  /// 黑色 80% 透明度
  static const Color black80 = Color(0xCC000000);

  /// 白色半透明
  static const Color white54 = Color(0x8AFFFFFF);

  /// 白色 70% 透明度
  static const Color white70 = Color(0xB3FFFFFF);

  /// 白色 60% 透明度
  static const Color white60 = Color(0x99FFFFFF);

  // ==================== 灰色系 ====================

  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  /// 根据主题获取对应的颜色
  static Color getBackground(Brightness brightness) =>
      brightness == Brightness.dark ? darkBackground : lightBackground;

  static Color getCard(Brightness brightness) =>
      brightness == Brightness.dark ? darkCard : lightCard;

  static Color getPlayerBackground(Brightness brightness) =>
      brightness == Brightness.dark ? darkCard : lightPlayerBackground;

  static Color getTextPrimary(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  static Color getTextSecondary(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;

  static Color getBorder(Brightness brightness) =>
      brightness == Brightness.dark ? darkBorder : lightBorder;
}
