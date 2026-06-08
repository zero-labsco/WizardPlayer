/// 播放器状态枚举
enum PlaybackState {
  /// 空闲状态
  idle,

  /// 加载中
  loading,

  /// 播放中
  playing,

  /// 已暂停
  paused,

  /// 已停止
  stopped,

  /// 错误状态
  error,

  /// 播放完成
  completed,
}
