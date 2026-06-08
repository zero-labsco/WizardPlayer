import 'dart:async';
import 'package:get/get.dart';
import 'playback_state.dart';

/// 播放器抽象接口
///
/// 设计说明：
/// - 位置更新 Timer 不依赖 GetxController 的 onInit 生命周期
///   因为 player 可能被直接 new 出来（不走 Get.put）
/// - 子类应在构造函数或初始化时调用 startPositionUpdates()
/// - 在 release()/dispose() 时调用 stopPositionUpdates()
abstract class WizardPlayer extends GetxController {
  /// 当前播放状态
  final Rx<PlaybackState> playbackState = PlaybackState.idle.obs;

  /// 当前播放位置
  final Rx<Duration> currentPosition = Duration.zero.obs;

  /// 总时长
  final Rx<Duration> duration = Duration.zero.obs;

  /// 缓冲进度（0.0 - 1.0）
  final Rx<double> bufferProgress = 0.0.obs;

  /// 是否在缓冲中
  final RxBool isBuffering = false.obs;

  /// 当前播放的 URI
  final RxString currentUri = ''.obs;

  Timer? _positionTimer;

  /// 播放 URI
  Future<void> playUri(String uri);

  /// 暂停
  Future<void> pause();

  /// 继续播放
  Future<void> resume();

  /// 停止播放
  Future<void> stop();

  /// 跳转到指定位置
  Future<void> seekTo(Duration position);

  /// 当前音量
  final RxDouble volume = 1.0.obs;

  /// 设置音量（0.0 - 1.0）
  Future<void> setVolume(double value);

  /// 当前播放速度
  final RxDouble playbackSpeed = 1.0.obs;

  /// 设置播放速度
  Future<void> setPlaybackSpeed(double speed);

  /// 进入全屏
  Future<void> enterFullscreen();

  /// 退出全屏
  Future<void> exitFullscreen();

  /// 释放资源
  Future<void> release();

  /// 获取底层播放器实例（平台特定）
  T? getPlatformPlayer<T>();

  /// 启动位置更新定时器（每 200ms）
  ///
  /// 公开方法：外部可以手动调用，不依赖 GetxController 的生命周期
  void startPositionUpdates() {
    if (_positionTimer != null && _positionTimer!.isActive) return;
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      updatePosition();
    });
  }

  /// 停止位置更新定时器
  void stopPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  /// 更新当前播放位置（子类实现）
  void updatePosition() {}

  /// 更新播放状态
  void updatePlaybackState(PlaybackState state) {
    playbackState.value = state;
  }

  /// 更新缓冲进度
  void updateBufferProgress(double progress) {
    bufferProgress.value = progress;
  }
}
