/// 状态提供者
///
/// 封装可观察状态的核心抽象，业务层不感知具体实现
///
/// @author AmisKwok
library;

import 'package:wizardplayer/core/implementations/state_provider_impl.dart';

/// 状态提供者接口
/// 封装可观察状态，支持流式监听
abstract class StateProvider<T> {
  /// 当前值
  T get value;

  /// 设置新值
  set value(T newValue);

  /// 状态变化流
  Stream<T> get stream;

  /// 更新状态（通过回调函数）
  void update(void Function(T) callback);

  /// 取消监听
  void cancel();
}

/// 状态提供者工厂
/// 用于创建状态提供者实例
class StateProviderFactory {
  /// 创建状态提供者实例
  static StateProvider<T> create<T>(T initialValue) {
    return StateProviderImpl<T>(initialValue);
  }
}
