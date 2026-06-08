/// 下载进度信息
///
/// 包含当前下载的进度、速度等信息
class DownloadProgress {
  /// 种子 ID
  final int infoHash;

  /// 下载进度 (0.0 - 1.0)
  final double progress;

  /// 下载速度（字节/秒）
  final int downloadRate;

  /// 上传速度（字节/秒）
  final int uploadRate;

  /// 是否暂停
  final bool isPaused;

  /// 是否完成
  final bool isFinished;

  /// 构造函数
  const DownloadProgress({
    required this.infoHash,
    this.progress = 0.0,
    this.downloadRate = 0,
    this.uploadRate = 0,
    this.isPaused = false,
    this.isFinished = false,
  });

  /// 从 JSON 创建
  factory DownloadProgress.fromJson(Map<String, dynamic> json) {
    return DownloadProgress(
      infoHash: json['info_hash'] as int,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      downloadRate: json['download_rate'] as int? ?? 0,
      uploadRate: json['upload_rate'] as int? ?? 0,
      isPaused: json['is_paused'] as bool? ?? false,
      isFinished: json['is_finished'] as bool? ?? false,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'info_hash': infoHash,
      'progress': progress,
      'download_rate': downloadRate,
      'upload_rate': uploadRate,
      'is_paused': isPaused,
      'is_finished': isFinished,
    };
  }

  /// 创建副本
  DownloadProgress copyWith({
    int? infoHash,
    double? progress,
    int? downloadRate,
    int? uploadRate,
    bool? isPaused,
    bool? isFinished,
  }) {
    return DownloadProgress(
      infoHash: infoHash ?? this.infoHash,
      progress: progress ?? this.progress,
      downloadRate: downloadRate ?? this.downloadRate,
      uploadRate: uploadRate ?? this.uploadRate,
      isPaused: isPaused ?? this.isPaused,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}
