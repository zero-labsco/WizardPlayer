/// 导航抽象
///
/// 业务层导航的统一入口，不感知具体实现
///
/// @author AmisKwok
library;

import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:wizardplayer/core/implementations/nav_impl.dart';

/// 应用路由定义
/// 用于定义页面路由的名称、页面构建函数和过渡动画
class AppRoute {
  /// 路由名称
  final String name;

  /// 页面构建函数
  final Widget Function() page;

  /// 过渡动画类型
  final Transition? transition;

  /// 过渡动画持续时间
  final Duration? transitionDuration;

  const AppRoute({
    required this.name,
    required this.page,
    this.transition,
    this.transitionDuration,
  });

  /// 转换为导航页面
  NavPage toNavPage() {
    return NavPage(
      name: name,
      page: page,
      transition: transition,
      transitionDuration: transitionDuration,
    );
  }
}

/// 导航访问器
/// 业务层使用此类进行导航，不需要感知具体实现细节
class Nav {
  Nav._();

  /// 导航到指定页面（压栈）- 支持页面构建器
  static Future<T?> to<T>(Widget Function() pageBuilder, {dynamic arguments}) {
    return NavImpl.to<T>(pageBuilder, arguments: arguments);
  }

  /// 替换当前页面（出栈后压栈）- 支持页面构建器
  static Future<T?> off<T>(Widget Function() pageBuilder, {dynamic arguments}) {
    return NavImpl.off<T>(pageBuilder, arguments: arguments);
  }

  /// 返回上一页
  static Future<T?> back<T>([T? result]) {
    return NavImpl.back<T>(result);
  }

  /// 获取当前路由参数
  static dynamic get arguments => NavImpl.arguments;

  /// 替换所有页面（清除栈底）- 支持页面构建器
  static Future<T?> offAll<T>(Widget Function() pageBuilder, {dynamic arguments}) {
    return NavImpl.offAll<T>(pageBuilder, arguments: arguments);
  }

  /// 返回直到条件满足
  static void popUntil(bool Function(Route<dynamic>) predicate) {
    NavImpl.popUntil(predicate);
  }

  /// 检查是否可以返回
  static bool canPop() {
    return NavImpl.canPop();
  }

  /// 获取当前路由名称
  static String? get currentRoute => NavImpl.currentRoute;

  /// 获取当前 BuildContext
  static BuildContext? get context => NavImpl.context;
}
