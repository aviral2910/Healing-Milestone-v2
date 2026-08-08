// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaAttachment {
  String get mediaId;
  String get url;
  String get title;
  String get description;
  bool get isSensitive;
  @TimestampConverter()
  DateTime get uploadedAt;

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MediaAttachmentCopyWith<MediaAttachment> get copyWith =>
      _$MediaAttachmentCopyWithImpl<MediaAttachment>(
          this as MediaAttachment, _$identity);

  /// Serializes this MediaAttachment to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MediaAttachment &&
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

  @override
  String toString() {
    return 'MediaAttachment(mediaId: $mediaId, url: $url, title: $title, description: $description, isSensitive: $isSensitive, uploadedAt: $uploadedAt)';
  }
}

/// @nodoc
abstract mixin class $MediaAttachmentCopyWith<$Res> {
  factory $MediaAttachmentCopyWith(
          MediaAttachment value, $Res Function(MediaAttachment) _then) =
      _$MediaAttachmentCopyWithImpl;
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
class _$MediaAttachmentCopyWithImpl<$Res>
    implements $MediaAttachmentCopyWith<$Res> {
  _$MediaAttachmentCopyWithImpl(this._self, this._then);

  final MediaAttachment _self;
  final $Res Function(MediaAttachment) _then;

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
    return _then(MediaAttachment(
      mediaId: null == mediaId
          ? _self.mediaId
          : mediaId // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isSensitive: null == isSensitive
          ? _self.isSensitive
          : isSensitive // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadedAt: null == uploadedAt
          ? _self.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [MediaAttachment].
extension MediaAttachmentPatterns on MediaAttachment {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MediaAttachment value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MediaAttachment() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MediaAttachment value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MediaAttachment():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MediaAttachment value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MediaAttachment() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String mediaId,
            String url,
            String title,
            String description,
            bool isSensitive,
            @TimestampConverter() DateTime uploadedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MediaAttachment() when $default != null:
        return $default(_that.mediaId, _that.url, _that.title,
            _that.description, _that.isSensitive, _that.uploadedAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String mediaId,
            String url,
            String title,
            String description,
            bool isSensitive,
            @TimestampConverter() DateTime uploadedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MediaAttachment():
        return $default(_that.mediaId, _that.url, _that.title,
            _that.description, _that.isSensitive, _that.uploadedAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String mediaId,
            String url,
            String title,
            String description,
            bool isSensitive,
            @TimestampConverter() DateTime uploadedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MediaAttachment() when $default != null:
        return $default(_that.mediaId, _that.url, _that.title,
            _that.description, _that.isSensitive, _that.uploadedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MediaAttachment implements MediaAttachment {
  const _MediaAttachment(
      {required this.mediaId,
      required this.url,
      required this.title,
      required this.description,
      this.isSensitive = false,
      @TimestampConverter() required this.uploadedAt});
  factory _MediaAttachment.fromJson(Map<String, dynamic> json) =>
      _$MediaAttachmentFromJson(json);

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

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MediaAttachmentCopyWith<_MediaAttachment> get copyWith =>
      __$MediaAttachmentCopyWithImpl<_MediaAttachment>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MediaAttachmentToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MediaAttachment &&
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

  @override
  String toString() {
    return 'MediaAttachment(mediaId: $mediaId, url: $url, title: $title, description: $description, isSensitive: $isSensitive, uploadedAt: $uploadedAt)';
  }
}

/// @nodoc
abstract mixin class _$MediaAttachmentCopyWith<$Res>
    implements $MediaAttachmentCopyWith<$Res> {
  factory _$MediaAttachmentCopyWith(
          _MediaAttachment value, $Res Function(_MediaAttachment) _then) =
      __$MediaAttachmentCopyWithImpl;
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
class __$MediaAttachmentCopyWithImpl<$Res>
    implements _$MediaAttachmentCopyWith<$Res> {
  __$MediaAttachmentCopyWithImpl(this._self, this._then);

  final _MediaAttachment _self;
  final $Res Function(_MediaAttachment) _then;

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? mediaId = null,
    Object? url = null,
    Object? title = null,
    Object? description = null,
    Object? isSensitive = null,
    Object? uploadedAt = null,
  }) {
    return _then(_MediaAttachment(
      mediaId: null == mediaId
          ? _self.mediaId
          : mediaId // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isSensitive: null == isSensitive
          ? _self.isSensitive
          : isSensitive // ignore: cast_nullable_to_non_nullable
              as bool,
      uploadedAt: null == uploadedAt
          ? _self.uploadedAt
          : uploadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
