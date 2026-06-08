import 'dart:async';
import 'package:get/get.dart';
import 'playback_state.dart';

/// 播放器抽象接口
abstract class WizardPlayer extends GetxController {
  /// 当前播放状态
  final Rx<PlaybackState> playbackState = PlaybackState.idle.obs;

  /// 当前播放位置（毫秒）
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

  @override
  void onInit() {
    super.onInit();
    _startPositionTimer();
  }

  @override
  void onClose() {
    _stopPositionTimer();
    super.onClose();
  }

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

  /// 启动位置更新定时器
  void _startPositionTimer() {
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      updatePosition();
    });
  }

  /// 停止位置更新定时器
  void _stopPositionTimer() {
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
