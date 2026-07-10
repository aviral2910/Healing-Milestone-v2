// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MediaAttachment _$MediaAttachmentFromJson(Map<String, dynamic> json) {
  return _MediaAttachment.fromJson(json);
}

/// @nodoc
mixin _$MediaAttachment {
  String get mediaId => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  bool get isSensitive => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get uploadedAt => throw _privateConstructorUsedError;

  /// Serializes this MediaAttachment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaAttachmentCopyWith<MediaAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaAttachmentCopyWith<$Res> {
  factory $MediaAttachmentCopyWith(
          MediaAttachment value, $Res Function(MediaAttachment) then) =
      _$MediaAttachmentCopyWithImpl<$Res, MediaAttachment>;
  @useResult
  $Res call(
      {String mediaId,
      String url,
      String title,
      String description,
      bool isSensitive,
      @TimestampConverter() DateTime uploadedAt});
}

/// @nodoc
class _$MediaAttachmentCopyWithImpl<$Res, $Val extends MediaAttachment>
    implements $MediaAttachmentCopyWith<$Res> {
  _$MediaAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaId = null,
    Object? url = null,
    Object? title = null,
    Object? description = null,
    Object? isSensitive = null,
    Object? uploadedAt = null,
  }) {
    return _then(_value.copyWith(
      mediaId: null == mediaId
          ? _value.mediaId
          : mediaId // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isSensitive: null == isSensitive
          ? _value.isSensitive
          : isSensitive // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadedAt: null == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MediaAttachmentImplCopyWith<$Res>
    implements $MediaAttachmentCopyWith<$Res> {
  factory _$$MediaAttachmentImplCopyWith(_$MediaAttachmentImpl value,
          $Res Function(_$MediaAttachmentImpl) then) =
      __$$MediaAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String mediaId,
      String url,
      String title,
      String description,
      bool isSensitive,
      @TimestampConverter() DateTime uploadedAt});
}

/// @nodoc
class __$$MediaAttachmentImplCopyWithImpl<$Res>
    extends _$MediaAttachmentCopyWithImpl<$Res, _$MediaAttachmentImpl>
    implements _$$MediaAttachmentImplCopyWith<$Res> {
  __$$MediaAttachmentImplCopyWithImpl(
      _$MediaAttachmentImpl _value, $Res Function(_$MediaAttachmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mediaId = null,
    Object? url = null,
    Object? title = null,
    Object? description = null,
    Object? isSensitive = null,
    Object? uploadedAt = null,
  }) {
    return _then(_$MediaAttachmentImpl(
      mediaId: null == mediaId
          ? _value.mediaId
          : mediaId // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isSensitive: null == isSensitive
          ? _value.isSensitive
          : isSensitive // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadedAt: null == uploadedAt
          ? _value.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MediaAttachmentImpl implements _MediaAttachment {
  const _$MediaAttachmentImpl(
      {required this.mediaId,
      required this.url,
      required this.title,
      required this.description,
      this.isSensitive = false,
      @TimestampConverter() required this.uploadedAt});

  factory _$MediaAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaAttachmentImplFromJson(json);

  @override
  final String mediaId;
  @override
  final String url;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey()
  final bool isSensitive;
  @override
  @TimestampConverter()
  final DateTime uploadedAt;

  @override
  String toString() {
    return 'MediaAttachment(mediaId: $mediaId, url: $url, title: $title, description: $description, isSensitive: $isSensitive, uploadedAt: $uploadedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaAttachmentImpl &&
            (identical(other.mediaId, mediaId) || other.mediaId == mediaId) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isSensitive, isSensitive) ||
                other.isSensitive == isSensitive) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, mediaId, url, title, description, isSensitive, uploadedAt);

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaAttachmentImplCopyWith<_$MediaAttachmentImpl> get copyWith =>
      __$$MediaAttachmentImplCopyWithImpl<_$MediaAttachmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaAttachmentImplToJson(
      this,
    );
  }
}

abstract class _MediaAttachment implements MediaAttachment {
  const factory _MediaAttachment(
          {required final String mediaId,
          required final String url,
          required final String title,
          required final String description,
          final bool isSensitive,
          @TimestampConverter() required final DateTime uploadedAt}) =
      _$MediaAttachmentImpl;

  factory _MediaAttachment.fromJson(Map<String, dynamic> json) =
      _$MediaAttachmentImpl.fromJson;

  @override
  String get mediaId;
  @override
  String get url;
  @override
  String get title;
  @override
  String get description;
  @override
  bool get isSensitive;
  @override
  @TimestampConverter()
  DateTime get uploadedAt;

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaAttachmentImplCopyWith<_$MediaAttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
