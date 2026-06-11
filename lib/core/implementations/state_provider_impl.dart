/// 状态提供者实现
///
/// 基于 GetX 实现状态提供者接口
/// 继承 Rx<T> 以支持 GetX 的 Obx 监听
///
/// @author AmisKwok
library;

import 'dart:async';
import 'package:get/get.dart';
import 'package:wizardplayer/core/abstractions/state_provider.dart';

/// GetX 状态提供者实现
/// 继承 Rx<T> 以支持 Obx 监听
class StateProviderImpl<T> extends Rx<T> implements StateProvider<T> {
  StreamController<T>? _controller;

  StateProviderImpl(super.initialValue);

  @override
  set value(T newValue) => super.value = newValue;

  @override
  Stream<T> get stream {
    // 转发到内部的 stream
    return super.stream;
  }

  @override
  void update(void Function(T) callback) {
    final currentValue = super.value;
    callback(currentValue);
    final newValue = super.value;
    if (currentValue != newValue) {
      super.value = newValue;
    }
  }

  @override
  void cancel() {
    _controller?.close();
    _controller = null;
  }
}
