/// 视频数据模型
///
/// @author AmisKwok
/// @deprecated 请使用 wizard_player_datasource 包中的 VideoInfo, EpisodeInfo 模型
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wizard_player_datasource/wizard_player_datasource.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

/// 视频模型
///
/// @deprecated 请使用 wizard_player_datasource 包中的 [VideoInfo]
/// 此模型已弃用，统一使用 wizard_player_datasource 包中的模型
@Deprecated('请使用 wizard_player_datasource 包中的 VideoInfo')
@freezed
class VideoModel with _$VideoModel {
  const factory VideoModel({
    /// 视频ID
    required String id,

    /// 视频标题
    required String title,

    /// 视频描述
    String? description,

    /// 封面图片URL
    required String coverUrl,

    /// 视频类型
    required VideoType type,

    /// 总集数
    required int totalEpisodes,

    /// 集数列表
    required List<EpisodeModel> episodes,

    /// 更新时间
    DateTime? updateTime,

    /// 评分
    double? rating,

    /// 标签
    List<String>? tags,
  }) = _VideoModel;

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  /// 从 VideoInfo 转换
  factory VideoModel.fromVideoInfo(VideoInfo info) {
    return VideoModel(
      id: info.id,
      title: info.title,
      description: info.subtitle,
      coverUrl: info.coverUrl ?? '',
      type: VideoType.anime, // 默认值
      totalEpisodes: info.episodes.length,
      episodes: info.episodes
          .map((ep) => EpisodeModel.fromEpisodeInfo(ep))
          .toList(),
      updateTime: info.publishTime,
      rating: info.rating,
      tags: info.tags,
    );
  }
}

/// 集数模型
///
/// @deprecated 请使用 wizard_player_datasource 包中的 [EpisodeInfo]
/// 此模型已弃用，统一使用 wizard_player_datasource 包中的模型
@Deprecated('请使用 wizard_player_datasource 包中的 EpisodeInfo')
@freezed
class EpisodeModel with _$EpisodeModel {
  const factory EpisodeModel({
    /// 集数ID
    required String id,

    /// 集数编号
    required int number,

    /// 集数标题
    String? title,

    /// 可用源列表
    required List<SourceModel> sources,
  }) = _EpisodeModel;

  factory EpisodeModel.fromJson(Map<String, dynamic> json) =>
      _$EpisodeModelFromJson(json);

  /// 从 EpisodeInfo 转换
  factory EpisodeModel.fromEpisodeInfo(EpisodeInfo info) {
    return EpisodeModel(
      id: info.id,
      number: info.episodeNumber,
      title: info.title,
      sources: [
        const SourceModel(
          id: 'default',
          name: '默认源',
          url: '',
          isAvailable: true,
          priority: 0,
        ),
      ],
    );
  }
}

/// 播放源模型
///
/// @deprecated 请使用 wizard_player_datasource 包中的 [PlayableMedia]
/// 此模型已弃用，播放源信息在 PlayableMedia 中
@Deprecated('请使用 wizard_player_datasource 包中的 PlayableMedia')
@freezed
class SourceModel with _$SourceModel {
  const factory SourceModel({
    /// 源ID
    required String id,

    /// 源名称
    required String name,

    /// 视频URL
    required String url,

    /// 是否可用
    @Default(true) bool isAvailable,

    /// 优先级（数字越小优先级越高）
    @Default(0) int priority,
  }) = _SourceModel;

  factory SourceModel.fromJson(Map<String, dynamic> json) =>
      _$SourceModelFromJson(json);
}
