// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoModelImpl _$$VideoModelImplFromJson(Map<String, dynamic> json) =>
    _$VideoModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverUrl: json['coverUrl'] as String,
      type: $enumDecode(_$VideoTypeEnumMap, json['type']),
      totalEpisodes: (json['totalEpisodes'] as num).toInt(),
      episodes: (json['episodes'] as List<dynamic>)
          .map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
      rating: (json['rating'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$VideoModelImplToJson(_$VideoModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'coverUrl': instance.coverUrl,
      'type': _$VideoTypeEnumMap[instance.type]!,
      'totalEpisodes': instance.totalEpisodes,
      'episodes': instance.episodes,
      'updateTime': instance.updateTime?.toIso8601String(),
      'rating': instance.rating,
      'tags': instance.tags,
    };

const _$VideoTypeEnumMap = {
  VideoType.anime: 'anime',
  VideoType.koreanDrama: 'koreanDrama',
  VideoType.americanDrama: 'americanDrama',
  VideoType.japaneseDrama: 'japaneseDrama',
};

_$EpisodeModelImpl _$$EpisodeModelImplFromJson(Map<String, dynamic> json) =>
    _$EpisodeModelImpl(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      title: json['title'] as String?,
      sources: (json['sources'] as List<dynamic>)
          .map((e) => SourceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$EpisodeModelImplToJson(_$EpisodeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'title': instance.title,
      'sources': instance.sources,
    };

_$SourceModelImpl _$$SourceModelImplFromJson(Map<String, dynamic> json) =>
    _$SourceModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SourceModelImplToJson(_$SourceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'isAvailable': instance.isAvailable,
      'priority': instance.priority,
    };
