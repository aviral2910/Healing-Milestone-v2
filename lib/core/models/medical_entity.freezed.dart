// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicalEntity {
  String get entityId;
  String get name;
  String get type;

  /// Create a copy of MedicalEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MedicalEntityCopyWith<MedicalEntity> get copyWith =>
      _$MedicalEntityCopyWithImpl<MedicalEntity>(
          this as MedicalEntity, _$identity);

  /// Serializes this MedicalEntity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MedicalEntity &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, entityId, name, type);

  @override
  String toString() {
    return 'MedicalEntity(entityId: $entityId, name: $name, type: $type)';
  }
}

/// @nodoc
abstract mixin class $MedicalEntityCopyWith<$Res> {
  factory $MedicalEntityCopyWith(
          MedicalEntity value, $Res Function(MedicalEntity) _then) =
      _$MedicalEntityCopyWithImpl;
  @useResult
  $Res call({String entityId, String name, String type});
}

/// @nodoc
class _$MedicalEntityCopyWithImpl<$Res>
    implements $MedicalEntityCopyWith<$Res> {
  _$MedicalEntityCopyWithImpl(this._self, this._then);

  final MedicalEntity _self;
  final $Res Function(MedicalEntity) _then;

  /// Create a copy of MedicalEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityId = null,
    Object? name = null,
    Object? type = null,
  }) {
    return _then(MedicalEntity(
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [MedicalEntity].
extension MedicalEntityPatterns on MedicalEntity {
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
    TResult Function(_MedicalEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MedicalEntity() when $default != null:
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
    TResult Function(_MedicalEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MedicalEntity():
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
    TResult? Function(_MedicalEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MedicalEntity() when $default != null:
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
    TResult Function(String entityId, String name, String type)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MedicalEntity() when $default != null:
        return $default(_that.entityId, _that.name, _that.type);
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
    TResult Function(String entityId, String name, String type) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MedicalEntity():
        return $default(_that.entityId, _that.name, _that.type);
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
    TResult? Function(String entityId, String name, String type)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MedicalEntity() when $default != null:
        return $default(_that.entityId, _that.name, _that.type);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MedicalEntity implements MedicalEntity {
  const _MedicalEntity(
      {required this.entityId, required this.name, required this.type});
  factory _MedicalEntity.fromJson(Map<String, dynamic> json) =>
      _$MedicalEntityFromJson(json);

  @override
  final String entityId;
  @override
  final String name;
  @override
  final String type;

  /// Create a copy of MedicalEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MedicalEntityCopyWith<_MedicalEntity> get copyWith =>
      __$MedicalEntityCopyWithImpl<_MedicalEntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MedicalEntityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MedicalEntity &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, entityId, name, type);

  @override
  String toString() {
    return 'MedicalEntity(entityId: $entityId, name: $name, type: $type)';
  }
}

/// @nodoc
abstract mixin class _$MedicalEntityCopyWith<$Res>
    implements $MedicalEntityCopyWith<$Res> {
  factory _$MedicalEntityCopyWith(
          _MedicalEntity value, $Res Function(_MedicalEntity) _then) =
      __$MedicalEntityCopyWithImpl;
  @override
  @useResult
  $Res call({String entityId, String name, String type});
}

/// @nodoc
class __$MedicalEntityCopyWithImpl<$Res>
    implements _$MedicalEntityCopyWith<$Res> {
  __$MedicalEntityCopyWithImpl(this._self, this._then);

  final _MedicalEntity _self;
  final $Res Function(_MedicalEntity) _then;

  /// Create a copy of MedicalEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? entityId = null,
    Object? name = null,
    Object? type = null,
  }) {
    return _then(_MedicalEntity(
      entityId: null == entityId
          ? _self.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
