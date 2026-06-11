// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlayHistoryModel _$PlayHistoryModelFromJson(Map<String, dynamic> json) {
  return _PlayHistoryModel.fromJson(json);
}

/// @nodoc
mixin _$PlayHistoryModel {
  /// 记录ID
  String get id => throw _privateConstructorUsedError;

  /// 视频ID
  String get videoId => throw _privateConstructorUsedError;

  /// 视频标题
  String get videoTitle => throw _privateConstructorUsedError;

  /// 封面图片URL
  String get coverUrl => throw _privateConstructorUsedError;

  /// 观看的集数编号
  int get episodeNumber => throw _privateConstructorUsedError;

  /// 播放位置（毫秒）
  int get position => throw _privateConstructorUsedError;

  /// 视频总时长（毫秒）
  int get duration => throw _privateConstructorUsedError;

  /// 视频URL（用于恢复播放链接）
  String? get videoUrl => throw _privateConstructorUsedError;

  /// 最后观看时间
  DateTime get lastWatchTime => throw _privateConstructorUsedError;

  /// 观看次数
  int get watchCount => throw _privateConstructorUsedError;

  /// Serializes this PlayHistoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayHistoryModelCopyWith<PlayHistoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayHistoryModelCopyWith<$Res> {
  factory $PlayHistoryModelCopyWith(
    PlayHistoryModel value,
    $Res Function(PlayHistoryModel) then,
  ) = _$PlayHistoryModelCopyWithImpl<$Res, PlayHistoryModel>;
  @useResult
  $Res call({
    String id,
    String videoId,
    String videoTitle,
    String coverUrl,
    int episodeNumber,
    int position,
    int duration,
    String? videoUrl,
    DateTime lastWatchTime,
    int watchCount,
  });
}

/// @nodoc
class _$PlayHistoryModelCopyWithImpl<$Res, $Val extends PlayHistoryModel>
    implements $PlayHistoryModelCopyWith<$Res> {
  _$PlayHistoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? videoId = null,
    Object? videoTitle = null,
    Object? coverUrl = null,
    Object? episodeNumber = null,
    Object? position = null,
    Object? duration = null,
    Object? videoUrl = freezed,
    Object? lastWatchTime = null,
    Object? watchCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            videoId: null == videoId
                ? _value.videoId
                : videoId // ignore: cast_nullable_to_non_nullable
                      as String,
            videoTitle: null == videoTitle
                ? _value.videoTitle
                : videoTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            coverUrl: null == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            episodeNumber: null == episodeNumber
                ? _value.episodeNumber
                : episodeNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            videoUrl: freezed == videoUrl
                ? _value.videoUrl
                : videoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastWatchTime: null == lastWatchTime
                ? _value.lastWatchTime
                : lastWatchTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            watchCount: null == watchCount
                ? _value.watchCount
                : watchCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayHistoryModelImplCopyWith<$Res>
    implements $PlayHistoryModelCopyWith<$Res> {
  factory _$$PlayHistoryModelImplCopyWith(
    _$PlayHistoryModelImpl value,
    $Res Function(_$PlayHistoryModelImpl) then,
  ) = __$$PlayHistoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String videoId,
    String videoTitle,
    String coverUrl,
    int episodeNumber,
    int position,
    int duration,
    String? videoUrl,
    DateTime lastWatchTime,
    int watchCount,
  });
}

/// @nodoc
class __$$PlayHistoryModelImplCopyWithImpl<$Res>
    extends _$PlayHistoryModelCopyWithImpl<$Res, _$PlayHistoryModelImpl>
    implements _$$PlayHistoryModelImplCopyWith<$Res> {
  __$$PlayHistoryModelImplCopyWithImpl(
    _$PlayHistoryModelImpl _value,
    $Res Function(_$PlayHistoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? videoId = null,
    Object? videoTitle = null,
    Object? coverUrl = null,
    Object? episodeNumber = null,
    Object? position = null,
    Object? duration = null,
    Object? videoUrl = freezed,
    Object? lastWatchTime = null,
    Object? watchCount = null,
  }) {
    return _then(
      _$PlayHistoryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        videoId: null == videoId
            ? _value.videoId
            : videoId // ignore: cast_nullable_to_non_nullable
                  as String,
        videoTitle: null == videoTitle
            ? _value.videoTitle
            : videoTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        coverUrl: null == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        episodeNumber: null == episodeNumber
            ? _value.episodeNumber
            : episodeNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        videoUrl: freezed == videoUrl
            ? _value.videoUrl
            : videoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastWatchTime: null == lastWatchTime
            ? _value.lastWatchTime
            : lastWatchTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        watchCount: null == watchCount
            ? _value.watchCount
            : watchCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayHistoryModelImpl implements _PlayHistoryModel {
  const _$PlayHistoryModelImpl({
    required this.id,
    required this.videoId,
    required this.videoTitle,
    required this.coverUrl,
    required this.episodeNumber,
    required this.position,
    required this.duration,
    this.videoUrl,
    required this.lastWatchTime,
    this.watchCount = 1,
  });

  factory _$PlayHistoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayHistoryModelImplFromJson(json);

  /// 记录ID
  @override
  final String id;

  /// 视频ID
  @override
  final String videoId;

  /// 视频标题
  @override
  final String videoTitle;

  /// 封面图片URL
  @override
  final String coverUrl;

  /// 观看的集数编号
  @override
  final int episodeNumber;

  /// 播放位置（毫秒）
  @override
  final int position;

  /// 视频总时长（毫秒）
  @override
  final int duration;

  /// 视频URL（用于恢复播放链接）
  @override
  final String? videoUrl;

  /// 最后观看时间
  @override
  final DateTime lastWatchTime;

  /// 观看次数
  @override
  @JsonKey()
  final int watchCount;

  @override
  String toString() {
    return 'PlayHistoryModel(id: $id, videoId: $videoId, videoTitle: $videoTitle, coverUrl: $coverUrl, episodeNumber: $episodeNumber, position: $position, duration: $duration, videoUrl: $videoUrl, lastWatchTime: $lastWatchTime, watchCount: $watchCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayHistoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.videoTitle, videoTitle) ||
                other.videoTitle == videoTitle) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.episodeNumber, episodeNumber) ||
                other.episodeNumber == episodeNumber) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.lastWatchTime, lastWatchTime) ||
                other.lastWatchTime == lastWatchTime) &&
            (identical(other.watchCount, watchCount) ||
                other.watchCount == watchCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    videoId,
    videoTitle,
    coverUrl,
    episodeNumber,
    position,
    duration,
    videoUrl,
    lastWatchTime,
    watchCount,
  );

  /// Create a copy of PlayHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayHistoryModelImplCopyWith<_$PlayHistoryModelImpl> get copyWith =>
      __$$PlayHistoryModelImplCopyWithImpl<_$PlayHistoryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayHistoryModelImplToJson(this);
  }
}

abstract class _PlayHistoryModel implements PlayHistoryModel {
  const factory _PlayHistoryModel({
    required final String id,
    required final String videoId,
    required final String videoTitle,
    required final String coverUrl,
    required final int episodeNumber,
    required final int position,
    required final int duration,
    final String? videoUrl,
    required final DateTime lastWatchTime,
    final int watchCount,
  }) = _$PlayHistoryModelImpl;

  factory _PlayHistoryModel.fromJson(Map<String, dynamic> json) =
      _$PlayHistoryModelImpl.fromJson;

  /// 记录ID
  @override
  String get id;

  /// 视频ID
  @override
  String get videoId;

  /// 视频标题
  @override
  String get videoTitle;

  /// 封面图片URL
  @override
  String get coverUrl;

  /// 观看的集数编号
  @override
  int get episodeNumber;

  /// 播放位置（毫秒）
  @override
  int get position;

  /// 视频总时长（毫秒）
  @override
  int get duration;

  /// 视频URL（用于恢复播放链接）
  @override
  String? get videoUrl;

  /// 最后观看时间
  @override
  DateTime get lastWatchTime;

  /// 观看次数
  @override
  int get watchCount;

  /// Create a copy of PlayHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayHistoryModelImplCopyWith<_$PlayHistoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
