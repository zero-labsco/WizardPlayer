// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayHistoryModelImpl _$$PlayHistoryModelImplFromJson(
  Map<String, dynamic> json,
) => _$PlayHistoryModelImpl(
  id: json['id'] as String,
  videoId: json['videoId'] as String,
  videoTitle: json['videoTitle'] as String,
  coverUrl: json['coverUrl'] as String,
  episodeNumber: (json['episodeNumber'] as num).toInt(),
  position: (json['position'] as num).toInt(),
  duration: (json['duration'] as num).toInt(),
  videoUrl: json['videoUrl'] as String?,
  lastWatchTime: DateTime.parse(json['lastWatchTime'] as String),
  watchCount: (json['watchCount'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$$PlayHistoryModelImplToJson(
  _$PlayHistoryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'videoId': instance.videoId,
  'videoTitle': instance.videoTitle,
  'coverUrl': instance.coverUrl,
  'episodeNumber': instance.episodeNumber,
  'position': instance.position,
  'duration': instance.duration,
  'videoUrl': instance.videoUrl,
  'lastWatchTime': instance.lastWatchTime.toIso8601String(),
  'watchCount': instance.watchCount,
};
