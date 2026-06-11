/// 状态列表提供者实现
///
/// 基于 GetX RxList 实现状态提供者接口
/// 支持列表类型的状态管理
///
/// @author AmisKwok
library;

import 'package:get/get.dart';

/// GetX 状态列表提供者实现
/// 继承 RxList<T> 以支持 Obx 监听
class StateListProviderImpl<T> extends RxList<T> {
  StateListProviderImpl([List<T>? initial]) : super(initial ?? []);
}
