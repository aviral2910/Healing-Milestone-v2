// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'milestone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Milestone _$MilestoneFromJson(Map<String, dynamic> json) {
  return _Milestone.fromJson(json);
}

/// @nodoc
mixin _$Milestone {
  String get milestoneId => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get templateStyle => throw _privateConstructorUsedError;
  bool get isAnonymous => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  List<String> get taggedEntities => throw _privateConstructorUsedError;
  List<MediaAttachment> get mediaAttachments =>
      throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Milestone to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MilestoneCopyWith<Milestone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MilestoneCopyWith<$Res> {
  factory $MilestoneCopyWith(Milestone value, $Res Function(Milestone) then) =
      _$MilestoneCopyWithImpl<$Res, Milestone>;
  @useResult
  $Res call(
      {String milestoneId,
      String authorId,
      String title,
      String content,
      String templateStyle,
      bool isAnonymous,
      bool isVerified,
      List<String> taggedEntities,
      List<MediaAttachment> mediaAttachments,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class _$MilestoneCopyWithImpl<$Res, $Val extends Milestone>
    implements $MilestoneCopyWith<$Res> {
  _$MilestoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? milestoneId = null,
    Object? authorId = null,
    Object? title = null,
    Object? content = null,
    Object? templateStyle = null,
    Object? isAnonymous = null,
    Object? isVerified = null,
    Object? taggedEntities = null,
    Object? mediaAttachments = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      milestoneId: null == milestoneId
          ? _value.milestoneId
          : milestoneId // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      templateStyle: null == templateStyle
          ? _value.templateStyle
          : templateStyle // ignore: cast_nullable_to_non_nullable
              as String,
      isAnonymous: null == isAnonymous
          ? _value.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      taggedEntities: null == taggedEntities
          ? _value.taggedEntities
          : taggedEntities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mediaAttachments: null == mediaAttachments
          ? _value.mediaAttachments
          : mediaAttachments // ignore: cast_nullable_to_non_nullable
              as List<MediaAttachment>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MilestoneImplCopyWith<$Res>
    implements $MilestoneCopyWith<$Res> {
  factory _$$MilestoneImplCopyWith(
          _$MilestoneImpl value, $Res Function(_$MilestoneImpl) then) =
      __$$MilestoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String milestoneId,
      String authorId,
      String title,
      String content,
      String templateStyle,
      bool isAnonymous,
      bool isVerified,
      List<String> taggedEntities,
      List<MediaAttachment> mediaAttachments,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class __$$MilestoneImplCopyWithImpl<$Res>
    extends _$MilestoneCopyWithImpl<$Res, _$MilestoneImpl>
    implements _$$MilestoneImplCopyWith<$Res> {
  __$$MilestoneImplCopyWithImpl(
      _$MilestoneImpl _value, $Res Function(_$MilestoneImpl) _then)
      : super(_value, _then);

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? milestoneId = null,
    Object? authorId = null,
    Object? title = null,
    Object? content = null,
    Object? templateStyle = null,
    Object? isAnonymous = null,
    Object? isVerified = null,
    Object? taggedEntities = null,
    Object? mediaAttachments = null,
    Object? createdAt = null,
  }) {
    return _then(_$MilestoneImpl(
      milestoneId: null == milestoneId
          ? _value.milestoneId
          : milestoneId // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      templateStyle: null == templateStyle
          ? _value.templateStyle
          : templateStyle // ignore: cast_nullable_to_non_nullable
              as String,
      isAnonymous: null == isAnonymous
          ? _value.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      taggedEntities: null == taggedEntities
          ? _value._taggedEntities
          : taggedEntities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mediaAttachments: null == mediaAttachments
          ? _value._mediaAttachments
          : mediaAttachments // ignore: cast_nullable_to_non_nullable
              as List<MediaAttachment>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MilestoneImpl implements _Milestone {
  const _$MilestoneImpl(
      {required this.milestoneId,
      required this.authorId,
      required this.title,
      required this.content,
      required this.templateStyle,
      this.isAnonymous = false,
      this.isVerified = false,
      final List<String> taggedEntities = const [],
      final List<MediaAttachment> mediaAttachments = const [],
      @TimestampConverter() required this.createdAt})
      : _taggedEntities = taggedEntities,
        _mediaAttachments = mediaAttachments;

  factory _$MilestoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$MilestoneImplFromJson(json);

  @override
  final String milestoneId;
  @override
  final String authorId;
  @override
  final String title;
  @override
  final String content;
  @override
  final String templateStyle;
  @override
  @JsonKey()
  final bool isAnonymous;
  @override
  @JsonKey()
  final bool isVerified;
  final List<String> _taggedEntities;
  @override
  @JsonKey()
  List<String> get taggedEntities {
    if (_taggedEntities is EqualUnmodifiableListView) return _taggedEntities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_taggedEntities);
  }

  final List<MediaAttachment> _mediaAttachments;
  @override
  @JsonKey()
  List<MediaAttachment> get mediaAttachments {
    if (_mediaAttachments is EqualUnmodifiableListView)
      return _mediaAttachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediaAttachments);
  }

  @override
  @TimestampConverter()
  final DateTime createdAt;

  @override
  String toString() {
    return 'Milestone(milestoneId: $milestoneId, authorId: $authorId, title: $title, content: $content, templateStyle: $templateStyle, isAnonymous: $isAnonymous, isVerified: $isVerified, taggedEntities: $taggedEntities, mediaAttachments: $mediaAttachments, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MilestoneImpl &&
            (identical(other.milestoneId, milestoneId) ||
                other.milestoneId == milestoneId) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.templateStyle, templateStyle) ||
                other.templateStyle == templateStyle) &&
            (identical(other.isAnonymous, isAnonymous) ||
                other.isAnonymous == isAnonymous) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            const DeepCollectionEquality()
                .equals(other._taggedEntities, _taggedEntities) &&
            const DeepCollectionEquality()
                .equals(other._mediaAttachments, _mediaAttachments) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      milestoneId,
      authorId,
      title,
      content,
      templateStyle,
      isAnonymous,
      isVerified,
      const DeepCollectionEquality().hash(_taggedEntities),
      const DeepCollectionEquality().hash(_mediaAttachments),
      createdAt);

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MilestoneImplCopyWith<_$MilestoneImpl> get copyWith =>
      __$$MilestoneImplCopyWithImpl<_$MilestoneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MilestoneImplToJson(
      this,
    );
  }
}

abstract class _Milestone implements Milestone {
  const factory _Milestone(
          {required final String milestoneId,
          required final String authorId,
          required final String title,
          required final String content,
          required final String templateStyle,
          final bool isAnonymous,
          final bool isVerified,
          final List<String> taggedEntities,
          final List<MediaAttachment> mediaAttachments,
          @TimestampConverter() required final DateTime createdAt}) =
      _$MilestoneImpl;

  factory _Milestone.fromJson(Map<String, dynamic> json) =
      _$MilestoneImpl.fromJson;

  @override
  String get milestoneId;
  @override
  String get authorId;
  @override
  String get title;
  @override
  String get content;
  @override
  String get templateStyle;
  @override
  bool get isAnonymous;
  @override
  bool get isVerified;
  @override
  List<String> get taggedEntities;
  @override
  List<MediaAttachment> get mediaAttachments;
  @override
  @TimestampConverter()
  DateTime get createdAt;

  /// Create a copy of Milestone
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MilestoneImplCopyWith<_$MilestoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
