/// 状态提供者实现
///
/// 基于 GetX 实现状态提供者接口
///
/// @author AmisKwok
library;

import 'dart:async';
import 'package:get/get.dart';
import 'package:wizardplayer/core/abstractions/state_provider.dart';

/// GetX 状态提供者实现
/// 封装 GetX 的可观察对象（Rx）
class StateProviderImpl<T> implements StateProvider<T> {
  /// GetX 可观察对象
  final Rx<T> _rx;

  /// 订阅对象，用于取消监听
  StreamSubscription<T>? _subscription;

  StateProviderImpl(T initialValue) : _rx = initialValue.obs;

  @override
  T get value => _rx.value;

  @override
  set value(T newValue) => _rx.value = newValue;

  @override
  Stream<T> get stream => _rx.stream;

  @override
  void update(void Function(T) callback) {
    final currentValue = _rx.value;
    callback(currentValue);
    final newValue = _rx.value;
    if (currentValue != newValue) {
      _rx.value = newValue;
    }
  }

  @override
  void cancel() {
    _subscription?.cancel();
    _subscription = null;
  }
}
