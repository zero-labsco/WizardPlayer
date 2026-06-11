/// 播放历史记录数据模型
///
/// @author AmisKwok
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_history_model.freezed.dart';
part 'play_history_model.g.dart';

/// 播放历史记录模型
@freezed
class PlayHistoryModel with _$PlayHistoryModel {
  const factory PlayHistoryModel({
    /// 记录ID
    required String id,

    /// 视频ID
    required String videoId,

    /// 视频标题
    required String videoTitle,

    /// 封面图片URL
    required String coverUrl,

    /// 观看的集数编号
    required int episodeNumber,

    /// 播放位置（毫秒）
    required int position,

    /// 视频总时长（毫秒）
    required int duration,

    /// 视频URL（用于恢复播放链接）
    String? videoUrl,

    /// 最后观看时间
    required DateTime lastWatchTime,

    /// 观看次数
    @Default(1) int watchCount,
  }) = _PlayHistoryModel;

  factory PlayHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$$PlayHistoryModelImplFromJson(json);
}
