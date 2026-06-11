/// 导航实现
///
/// 基于 GetX 实现导航功能
///
/// @author AmisKwok
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 导航页面定义
/// 用于 GetX 路由系统的页面配置
class NavPage {
  /// 路由名称
  final String name;

  /// 页面构建函数
  final Widget Function() page;

  /// 过渡动画类型
  final Transition? transition;

  /// 过渡动画持续时间
  final Duration? transitionDuration;

  const NavPage({
    required this.name,
    required this.page,
    this.transition,
    this.transitionDuration,
  });

  /// 转换为 GetX 的 GetPage
  GetPage toGetPage() {
    return GetPage(
      name: name,
      page: page,
      transition: transition,
      transitionDuration: transitionDuration,
    );
  }
}

/// GetX 导航实现
/// 封装 GetX 的导航功能
class NavImpl {
  NavImpl._();

  /// 导航到指定页面（压栈）- 支持页面构建器
  static Future<T?> to<T>(
    Widget Function() pageBuilder, {
    dynamic arguments,
  }) async {
    return Get.to<T>(pageBuilder, arguments: arguments);
  }

  /// 替换当前页面（出栈后压栈）- 支持页面构建器
  static Future<T?> off<T>(
    Widget Function() pageBuilder, {
    dynamic arguments,
  }) async {
    return Get.off<T>(pageBuilder, arguments: arguments);
  }

  /// 返回上一页
  static Future<T?> back<T>([T? result]) async {
    Get.back<T>(result: result);
    return result;
  }

  /// 获取当前路由参数
  static dynamic get arguments => Get.arguments;

  /// 替换所有页面（清除栈底）- 支持页面构建器
  static Future<T?> offAll<T>(
    Widget Function() pageBuilder, {
    dynamic arguments,
  }) async {
    return Get.offAll<T>(pageBuilder, arguments: arguments);
  }

  /// 返回直到条件满足
  static void popUntil(bool Function(Route<dynamic>) predicate) {
    Navigator.of(Get.context!).popUntil(predicate);
  }

  /// 检查是否可以返回
  static bool canPop() {
    return Navigator.of(Get.context!).canPop();
  }

  /// 获取当前路由名称
  static String? get currentRoute => Get.currentRoute;

  /// 获取当前 BuildContext
  static BuildContext? get context => Get.context;
}
