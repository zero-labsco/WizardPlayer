/// 依赖注入抽象
///
/// 业务层获取依赖的统一入口，不感知具体实现
///
/// @author AmisKwok
library;

import 'package:wizardplayer/core/implementations/di_impl.dart';

/// 依赖注入访问器
/// 业务层使用此类获取依赖，不需要感知具体实现细节
class DI {
  DI._();

  /// 获取已注册的实例
  static T get<T>({String? tag}) {
    return DIImpl.get<T>(tag: tag);
  }

  /// 注册实例（单例）
  static T put<T>(T instance, {String? tag, bool permanent = false}) {
    return DIImpl.put<T>(instance, tag: tag, permanent: permanent);
  }

  /// 懒加载注册实例
  static void lazyPut<T>(T Function() factory, {String? tag}) {
    DIImpl.lazyPut<T>(factory, tag: tag);
  }

  /// 删除已注册的实例
  static void delete<T>({String? tag}) {
    DIImpl.delete<T>(tag: tag);
  }

  /// 检查实例是否已注册
  static bool isRegistered<T>({String? tag}) {
    return DIImpl.isRegistered<T>(tag: tag);
  }

  /// 替换已注册的实例
  static T replace<T>(T instance, {String? tag}) {
    return DIImpl.replace<T>(instance, tag: tag);
  }
}
