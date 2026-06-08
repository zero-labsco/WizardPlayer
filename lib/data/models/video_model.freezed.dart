// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) {
  return _VideoModel.fromJson(json);
}

/// @nodoc
mixin _$VideoModel {
  /// 视频ID
  String get id => throw _privateConstructorUsedError;

  /// 视频标题
  String get title => throw _privateConstructorUsedError;

  /// 视频描述
  String? get description => throw _privateConstructorUsedError;

  /// 封面图片URL
  String get coverUrl => throw _privateConstructorUsedError;

  /// 视频类型
  VideoType get type => throw _privateConstructorUsedError;

  /// 总集数
  int get totalEpisodes => throw _privateConstructorUsedError;

  /// 集数列表
  List<EpisodeModel> get episodes => throw _privateConstructorUsedError;

  /// 更新时间
  DateTime? get updateTime => throw _privateConstructorUsedError;

  /// 评分
  double? get rating => throw _privateConstructorUsedError;

  /// 标签
  List<String>? get tags => throw _privateConstructorUsedError;

  /// Serializes this VideoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoModelCopyWith<VideoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoModelCopyWith<$Res> {
  factory $VideoModelCopyWith(
    VideoModel value,
    $Res Function(VideoModel) then,
  ) = _$VideoModelCopyWithImpl<$Res, VideoModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String coverUrl,
    VideoType type,
    int totalEpisodes,
    List<EpisodeModel> episodes,
    DateTime? updateTime,
    double? rating,
    List<String>? tags,
  });
}

/// @nodoc
class _$VideoModelCopyWithImpl<$Res, $Val extends VideoModel>
    implements $VideoModelCopyWith<$Res> {
  _$VideoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? coverUrl = null,
    Object? type = null,
    Object? totalEpisodes = null,
    Object? episodes = null,
    Object? updateTime = freezed,
    Object? rating = freezed,
    Object? tags = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverUrl: null == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as VideoType,
            totalEpisodes: null == totalEpisodes
                ? _value.totalEpisodes
                : totalEpisodes // ignore: cast_nullable_to_non_nullable
                      as int,
            episodes: null == episodes
                ? _value.episodes
                : episodes // ignore: cast_nullable_to_non_nullable
                      as List<EpisodeModel>,
            updateTime: freezed == updateTime
                ? _value.updateTime
                : updateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            rating: freezed == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double?,
            tags: freezed == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VideoModelImplCopyWith<$Res>
    implements $VideoModelCopyWith<$Res> {
  factory _$$VideoModelImplCopyWith(
    _$VideoModelImpl value,
    $Res Function(_$VideoModelImpl) then,
  ) = __$$VideoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String coverUrl,
    VideoType type,
    int totalEpisodes,
    List<EpisodeModel> episodes,
    DateTime? updateTime,
    double? rating,
    List<String>? tags,
  });
}

/// @nodoc
class __$$VideoModelImplCopyWithImpl<$Res>
    extends _$VideoModelCopyWithImpl<$Res, _$VideoModelImpl>
    implements _$$VideoModelImplCopyWith<$Res> {
  __$$VideoModelImplCopyWithImpl(
    _$VideoModelImpl _value,
    $Res Function(_$VideoModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? coverUrl = null,
    Object? type = null,
    Object? totalEpisodes = null,
    Object? episodes = null,
    Object? updateTime = freezed,
    Object? rating = freezed,
    Object? tags = freezed,
  }) {
    return _then(
      _$VideoModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverUrl: null == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as VideoType,
        totalEpisodes: null == totalEpisodes
            ? _value.totalEpisodes
            : totalEpisodes // ignore: cast_nullable_to_non_nullable
                  as int,
        episodes: null == episodes
            ? _value._episodes
            : episodes // ignore: cast_nullable_to_non_nullable
                  as List<EpisodeModel>,
        updateTime: freezed == updateTime
            ? _value.updateTime
            : updateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        rating: freezed == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double?,
        tags: freezed == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoModelImpl implements _VideoModel {
  const _$VideoModelImpl({
    required this.id,
    required this.title,
    this.description,
    required this.coverUrl,
    required this.type,
    required this.totalEpisodes,
    required final List<EpisodeModel> episodes,
    this.updateTime,
    this.rating,
    final List<String>? tags,
  }) : _episodes = episodes,
       _tags = tags;

  factory _$VideoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoModelImplFromJson(json);

  /// 视频ID
  @override
  final String id;

  /// 视频标题
  @override
  final String title;

  /// 视频描述
  @override
  final String? description;

  /// 封面图片URL
  @override
  final String coverUrl;

  /// 视频类型
  @override
  final VideoType type;

  /// 总集数
  @override
  final int totalEpisodes;

  /// 集数列表
  final List<EpisodeModel> _episodes;

  /// 集数列表
  @override
  List<EpisodeModel> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  /// 更新时间
  @override
  final DateTime? updateTime;

  /// 评分
  @override
  final double? rating;

  /// 标签
  final List<String>? _tags;

  /// 标签
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'VideoModel(id: $id, title: $title, description: $description, coverUrl: $coverUrl, type: $type, totalEpisodes: $totalEpisodes, episodes: $episodes, updateTime: $updateTime, rating: $rating, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.totalEpisodes, totalEpisodes) ||
                other.totalEpisodes == totalEpisodes) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            (identical(other.updateTime, updateTime) ||
                other.updateTime == updateTime) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    coverUrl,
    type,
    totalEpisodes,
    const DeepCollectionEquality().hash(_episodes),
    updateTime,
    rating,
    const DeepCollectionEquality().hash(_tags),
  );

  /// Create a copy of VideoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoModelImplCopyWith<_$VideoModelImpl> get copyWith =>
      __$$VideoModelImplCopyWithImpl<_$VideoModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoModelImplToJson(this);
  }
}

abstract class _VideoModel implements VideoModel {
  const factory _VideoModel({
    required final String id,
    required final String title,
    final String? description,
    required final String coverUrl,
    required final VideoType type,
    required final int totalEpisodes,
    required final List<EpisodeModel> episodes,
    final DateTime? updateTime,
    final double? rating,
    final List<String>? tags,
  }) = _$VideoModelImpl;

  factory _VideoModel.fromJson(Map<String, dynamic> json) =
      _$VideoModelImpl.fromJson;

  /// 视频ID
  @override
  String get id;

  /// 视频标题
  @override
  String get title;

  /// 视频描述
  @override
  String? get description;

  /// 封面图片URL
  @override
  String get coverUrl;

  /// 视频类型
  @override
  VideoType get type;

  /// 总集数
  @override
  int get totalEpisodes;

  /// 集数列表
  @override
  List<EpisodeModel> get episodes;

  /// 更新时间
  @override
  DateTime? get updateTime;

  /// 评分
  @override
  double? get rating;

  /// 标签
  @override
  List<String>? get tags;

  /// Create a copy of VideoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoModelImplCopyWith<_$VideoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EpisodeModel _$EpisodeModelFromJson(Map<String, dynamic> json) {
  return _EpisodeModel.fromJson(json);
}

/// @nodoc
mixin _$EpisodeModel {
  /// 集数ID
  String get id => throw _privateConstructorUsedError;

  /// 集数编号
  int get number => throw _privateConstructorUsedError;

  /// 集数标题
  String? get title => throw _privateConstructorUsedError;

  /// 可用源列表
  List<SourceModel> get sources => throw _privateConstructorUsedError;

  /// Serializes this EpisodeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EpisodeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EpisodeModelCopyWith<EpisodeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodeModelCopyWith<$Res> {
  factory $EpisodeModelCopyWith(
    EpisodeModel value,
    $Res Function(EpisodeModel) then,
  ) = _$EpisodeModelCopyWithImpl<$Res, EpisodeModel>;
  @useResult
  $Res call({String id, int number, String? title, List<SourceModel> sources});
}

/// @nodoc
class _$EpisodeModelCopyWithImpl<$Res, $Val extends EpisodeModel>
    implements $EpisodeModelCopyWith<$Res> {
  _$EpisodeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EpisodeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? title = freezed,
    Object? sources = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            number: null == number
                ? _value.number
                : number // ignore: cast_nullable_to_non_nullable
                      as int,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            sources: null == sources
                ? _value.sources
                : sources // ignore: cast_nullable_to_non_nullable
                      as List<SourceModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EpisodeModelImplCopyWith<$Res>
    implements $EpisodeModelCopyWith<$Res> {
  factory _$$EpisodeModelImplCopyWith(
    _$EpisodeModelImpl value,
    $Res Function(_$EpisodeModelImpl) then,
  ) = __$$EpisodeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, int number, String? title, List<SourceModel> sources});
}

/// @nodoc
class __$$EpisodeModelImplCopyWithImpl<$Res>
    extends _$EpisodeModelCopyWithImpl<$Res, _$EpisodeModelImpl>
    implements _$$EpisodeModelImplCopyWith<$Res> {
  __$$EpisodeModelImplCopyWithImpl(
    _$EpisodeModelImpl _value,
    $Res Function(_$EpisodeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EpisodeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? title = freezed,
    Object? sources = null,
  }) {
    return _then(
      _$EpisodeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        number: null == number
            ? _value.number
            : number // ignore: cast_nullable_to_non_nullable
                  as int,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        sources: null == sources
            ? _value._sources
            : sources // ignore: cast_nullable_to_non_nullable
                  as List<SourceModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EpisodeModelImpl implements _EpisodeModel {
  const _$EpisodeModelImpl({
    required this.id,
    required this.number,
    this.title,
    required final List<SourceModel> sources,
  }) : _sources = sources;

  factory _$EpisodeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EpisodeModelImplFromJson(json);

  /// 集数ID
  @override
  final String id;

  /// 集数编号
  @override
  final int number;

  /// 集数标题
  @override
  final String? title;

  /// 可用源列表
  final List<SourceModel> _sources;

  /// 可用源列表
  @override
  List<SourceModel> get sources {
    if (_sources is EqualUnmodifiableListView) return _sources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sources);
  }

  @override
  String toString() {
    return 'EpisodeModel(id: $id, number: $number, title: $title, sources: $sources)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._sources, _sources));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    number,
    title,
    const DeepCollectionEquality().hash(_sources),
  );

  /// Create a copy of EpisodeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeModelImplCopyWith<_$EpisodeModelImpl> get copyWith =>
      __$$EpisodeModelImplCopyWithImpl<_$EpisodeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EpisodeModelImplToJson(this);
  }
}

abstract class _EpisodeModel implements EpisodeModel {
  const factory _EpisodeModel({
    required final String id,
    required final int number,
    final String? title,
    required final List<SourceModel> sources,
  }) = _$EpisodeModelImpl;

  factory _EpisodeModel.fromJson(Map<String, dynamic> json) =
      _$EpisodeModelImpl.fromJson;

  /// 集数ID
  @override
  String get id;

  /// 集数编号
  @override
  int get number;

  /// 集数标题
  @override
  String? get title;

  /// 可用源列表
  @override
  List<SourceModel> get sources;

  /// Create a copy of EpisodeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EpisodeModelImplCopyWith<_$EpisodeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SourceModel _$SourceModelFromJson(Map<String, dynamic> json) {
  return _SourceModel.fromJson(json);
}

/// @nodoc
mixin _$SourceModel {
  /// 源ID
  String get id => throw _privateConstructorUsedError;

  /// 源名称
  String get name => throw _privateConstructorUsedError;

  /// 视频URL
  String get url => throw _privateConstructorUsedError;

  /// 是否可用
  bool get isAvailable => throw _privateConstructorUsedError;

  /// 优先级（数字越小优先级越高）
  int get priority => throw _privateConstructorUsedError;

  /// Serializes this SourceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SourceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SourceModelCopyWith<SourceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SourceModelCopyWith<$Res> {
  factory $SourceModelCopyWith(
    SourceModel value,
    $Res Function(SourceModel) then,
  ) = _$SourceModelCopyWithImpl<$Res, SourceModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String url,
    bool isAvailable,
    int priority,
  });
}

/// @nodoc
class _$SourceModelCopyWithImpl<$Res, $Val extends SourceModel>
    implements $SourceModelCopyWith<$Res> {
  _$SourceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SourceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? url = null,
    Object? isAvailable = null,
    Object? priority = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SourceModelImplCopyWith<$Res>
    implements $SourceModelCopyWith<$Res> {
  factory _$$SourceModelImplCopyWith(
    _$SourceModelImpl value,
    $Res Function(_$SourceModelImpl) then,
  ) = __$$SourceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String url,
    bool isAvailable,
    int priority,
  });
}

/// @nodoc
class __$$SourceModelImplCopyWithImpl<$Res>
    extends _$SourceModelCopyWithImpl<$Res, _$SourceModelImpl>
    implements _$$SourceModelImplCopyWith<$Res> {
  __$$SourceModelImplCopyWithImpl(
    _$SourceModelImpl _value,
    $Res Function(_$SourceModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SourceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? url = null,
    Object? isAvailable = null,
    Object? priority = null,
  }) {
    return _then(
      _$SourceModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SourceModelImpl implements _SourceModel {
  const _$SourceModelImpl({
    required this.id,
    required this.name,
    required this.url,
    this.isAvailable = true,
    this.priority = 0,
  });

  factory _$SourceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SourceModelImplFromJson(json);

  /// 源ID
  @override
  final String id;

  /// 源名称
  @override
  final String name;

  /// 视频URL
  @override
  final String url;

  /// 是否可用
  @override
  @JsonKey()
  final bool isAvailable;

  /// 优先级（数字越小优先级越高）
  @override
  @JsonKey()
  final int priority;

  @override
  String toString() {
    return 'SourceModel(id: $id, name: $name, url: $url, isAvailable: $isAvailable, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SourceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.priority, priority) ||
                other.priority == priority));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, url, isAvailable, priority);

  /// Create a copy of SourceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SourceModelImplCopyWith<_$SourceModelImpl> get copyWith =>
      __$$SourceModelImplCopyWithImpl<_$SourceModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SourceModelImplToJson(this);
  }
}

abstract class _SourceModel implements SourceModel {
  const factory _SourceModel({
    required final String id,
    required final String name,
    required final String url,
    final bool isAvailable,
    final int priority,
  }) = _$SourceModelImpl;

  factory _SourceModel.fromJson(Map<String, dynamic> json) =
      _$SourceModelImpl.fromJson;

  /// 源ID
  @override
  String get id;

  /// 源名称
  @override
  String get name;

  /// 视频URL
  @override
  String get url;

  /// 是否可用
  @override
  bool get isAvailable;

  /// 优先级（数字越小优先级越高）
  @override
  int get priority;

  /// Create a copy of SourceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SourceModelImplCopyWith<_$SourceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
