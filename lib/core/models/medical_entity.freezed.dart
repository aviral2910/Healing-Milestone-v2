// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medical_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MedicalEntity _$MedicalEntityFromJson(Map<String, dynamic> json) {
  return _MedicalEntity.fromJson(json);
}

/// @nodoc
mixin _$MedicalEntity {
  String get entityId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this MedicalEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MedicalEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicalEntityCopyWith<MedicalEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicalEntityCopyWith<$Res> {
  factory $MedicalEntityCopyWith(
          MedicalEntity value, $Res Function(MedicalEntity) then) =
      _$MedicalEntityCopyWithImpl<$Res, MedicalEntity>;
  @useResult
  $Res call({String entityId, String name, String type});
}

/// @nodoc
class _$MedicalEntityCopyWithImpl<$Res, $Val extends MedicalEntity>
    implements $MedicalEntityCopyWith<$Res> {
  _$MedicalEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MedicalEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityId = null,
    Object? name = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MedicalEntityImplCopyWith<$Res>
    implements $MedicalEntityCopyWith<$Res> {
  factory _$$MedicalEntityImplCopyWith(
          _$MedicalEntityImpl value, $Res Function(_$MedicalEntityImpl) then) =
      __$$MedicalEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String entityId, String name, String type});
}

/// @nodoc
class __$$MedicalEntityImplCopyWithImpl<$Res>
    extends _$MedicalEntityCopyWithImpl<$Res, _$MedicalEntityImpl>
    implements _$$MedicalEntityImplCopyWith<$Res> {
  __$$MedicalEntityImplCopyWithImpl(
      _$MedicalEntityImpl _value, $Res Function(_$MedicalEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of MedicalEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityId = null,
    Object? name = null,
    Object? type = null,
  }) {
    return _then(_$MedicalEntityImpl(
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicalEntityImpl implements _MedicalEntity {
  const _$MedicalEntityImpl(
      {required this.entityId, required this.name, required this.type});

  factory _$MedicalEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicalEntityImplFromJson(json);

  @override
  final String entityId;
  @override
  final String name;
  @override
  final String type;

  @override
  String toString() {
    return 'MedicalEntity(entityId: $entityId, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicalEntityImpl &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, entityId, name, type);

  /// Create a copy of MedicalEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicalEntityImplCopyWith<_$MedicalEntityImpl> get copyWith =>
      __$$MedicalEntityImplCopyWithImpl<_$MedicalEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicalEntityImplToJson(
      this,
    );
  }
}

abstract class _MedicalEntity implements MedicalEntity {
  const factory _MedicalEntity(
      {required final String entityId,
      required final String name,
      required final String type}) = _$MedicalEntityImpl;

  factory _MedicalEntity.fromJson(Map<String, dynamic> json) =
      _$MedicalEntityImpl.fromJson;

  @override
  String get entityId;
  @override
  String get name;
  @override
  String get type;

  /// Create a copy of MedicalEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicalEntityImplCopyWith<_$MedicalEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
