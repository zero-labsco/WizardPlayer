/// 依赖注入实现
///
/// 基于 GetX 实现依赖注入功能
///
/// @author AmisKwok
library;

import 'package:get/get.dart';

/// GetX 依赖注入实现
/// 封装 GetX 的依赖注入功能
class DIImpl {
  DIImpl._();

  /// 获取已注册的实例
  static T get<T>({String? tag}) {
    return Get.find<T>(tag: tag);
  }

  /// 注册实例（单例）
  static T put<T>(T instance, {String? tag, bool permanent = false}) {
    return Get.put<T>(instance, tag: tag, permanent: permanent);
  }

  /// 懒加载注册实例
  static void lazyPut<T>(T Function() factory, {String? tag}) {
    Get.lazyPut<T>(factory, tag: tag);
  }

  /// 删除已注册的实例
  static void delete<T>({String? tag}) {
    Get.delete<T>(tag: tag);
  }

  /// 检查实例是否已注册
  static bool isRegistered<T>({String? tag}) {
    return Get.isRegistered<T>(tag: tag);
  }

  /// 替换已注册的实例
  static T replace<T>(T instance, {String? tag}) {
    if (isRegistered<T>(tag: tag)) {
      delete<T>(tag: tag);
    }
    return put<T>(instance, tag: tag);
  }
}
