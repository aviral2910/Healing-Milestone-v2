// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_creation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PostCreationState {
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<UserModel> get selectedUsers => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;
  bool get isAnonymous => throw _privateConstructorUsedError;
  String? get draftId => throw _privateConstructorUsedError;
  StoryType get type => throw _privateConstructorUsedError;
  bool get isEditing => throw _privateConstructorUsedError;
  String? get originalStoryId => throw _privateConstructorUsedError;

  /// Create a copy of PostCreationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostCreationStateCopyWith<PostCreationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostCreationStateCopyWith<$Res> {
  factory $PostCreationStateCopyWith(
          PostCreationState value, $Res Function(PostCreationState) then) =
      _$PostCreationStateCopyWithImpl<$Res, PostCreationState>;
  @useResult
  $Res call(
      {String title,
      String content,
      List<String> tags,
      List<UserModel> selectedUsers,
      String? imagePath,
      bool isAnonymous,
      String? draftId,
      StoryType type,
      bool isEditing,
      String? originalStoryId});
}

/// @nodoc
class _$PostCreationStateCopyWithImpl<$Res, $Val extends PostCreationState>
    implements $PostCreationStateCopyWith<$Res> {
  _$PostCreationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PostCreationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? tags = null,
    Object? selectedUsers = null,
    Object? imagePath = freezed,
    Object? isAnonymous = null,
    Object? draftId = freezed,
    Object? type = null,
    Object? isEditing = null,
    Object? originalStoryId = freezed,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedUsers: null == selectedUsers
          ? _value.selectedUsers
          : selectedUsers // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isAnonymous: null == isAnonymous
          ? _value.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      draftId: freezed == draftId
          ? _value.draftId
          : draftId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoryType,
      isEditing: null == isEditing
          ? _value.isEditing
          : isEditing // ignore: cast_nullable_to_non_nullable
              as bool,
      originalStoryId: freezed == originalStoryId
          ? _value.originalStoryId
          : originalStoryId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostCreationStateImplCopyWith<$Res>
    implements $PostCreationStateCopyWith<$Res> {
  factory _$$PostCreationStateImplCopyWith(_$PostCreationStateImpl value,
          $Res Function(_$PostCreationStateImpl) then) =
      __$$PostCreationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String content,
      List<String> tags,
      List<UserModel> selectedUsers,
      String? imagePath,
      bool isAnonymous,
      String? draftId,
      StoryType type,
      bool isEditing,
      String? originalStoryId});
}

/// @nodoc
class __$$PostCreationStateImplCopyWithImpl<$Res>
    extends _$PostCreationStateCopyWithImpl<$Res, _$PostCreationStateImpl>
    implements _$$PostCreationStateImplCopyWith<$Res> {
  __$$PostCreationStateImplCopyWithImpl(_$PostCreationStateImpl _value,
      $Res Function(_$PostCreationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PostCreationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? tags = null,
    Object? selectedUsers = null,
    Object? imagePath = freezed,
    Object? isAnonymous = null,
    Object? draftId = freezed,
    Object? type = null,
    Object? isEditing = null,
    Object? originalStoryId = freezed,
  }) {
    return _then(_$PostCreationStateImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedUsers: null == selectedUsers
          ? _value._selectedUsers
          : selectedUsers // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isAnonymous: null == isAnonymous
          ? _value.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      draftId: freezed == draftId
          ? _value.draftId
          : draftId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoryType,
      isEditing: null == isEditing
          ? _value.isEditing
          : isEditing // ignore: cast_nullable_to_non_nullable
              as bool,
      originalStoryId: freezed == originalStoryId
          ? _value.originalStoryId
          : originalStoryId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PostCreationStateImpl implements _PostCreationState {
  const _$PostCreationStateImpl(
      {this.title = '',
      this.content = '',
      final List<String> tags = const [],
      final List<UserModel> selectedUsers = const [],
      this.imagePath,
      this.isAnonymous = false,
      this.draftId,
      this.type = StoryType.story,
      this.isEditing = false,
      this.originalStoryId})
      : _tags = tags,
        _selectedUsers = selectedUsers;

  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String content;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<UserModel> _selectedUsers;
  @override
  @JsonKey()
  List<UserModel> get selectedUsers {
    if (_selectedUsers is EqualUnmodifiableListView) return _selectedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedUsers);
  }

  @override
  final String? imagePath;
  @override
  @JsonKey()
  final bool isAnonymous;
  @override
  final String? draftId;
  @override
  @JsonKey()
  final StoryType type;
  @override
  @JsonKey()
  final bool isEditing;
  @override
  final String? originalStoryId;

  @override
  String toString() {
    return 'PostCreationState(title: $title, content: $content, tags: $tags, selectedUsers: $selectedUsers, imagePath: $imagePath, isAnonymous: $isAnonymous, draftId: $draftId, type: $type, isEditing: $isEditing, originalStoryId: $originalStoryId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostCreationStateImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._selectedUsers, _selectedUsers) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.isAnonymous, isAnonymous) ||
                other.isAnonymous == isAnonymous) &&
            (identical(other.draftId, draftId) || other.draftId == draftId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isEditing, isEditing) ||
                other.isEditing == isEditing) &&
            (identical(other.originalStoryId, originalStoryId) ||
                other.originalStoryId == originalStoryId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      content,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_selectedUsers),
      imagePath,
      isAnonymous,
      draftId,
      type,
      isEditing,
      originalStoryId);

  /// Create a copy of PostCreationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostCreationStateImplCopyWith<_$PostCreationStateImpl> get copyWith =>
      __$$PostCreationStateImplCopyWithImpl<_$PostCreationStateImpl>(
          this, _$identity);
}

abstract class _PostCreationState implements PostCreationState {
  const factory _PostCreationState(
      {final String title,
      final String content,
      final List<String> tags,
      final List<UserModel> selectedUsers,
      final String? imagePath,
      final bool isAnonymous,
      final String? draftId,
      final StoryType type,
      final bool isEditing,
      final String? originalStoryId}) = _$PostCreationStateImpl;

  @override
  String get title;
  @override
  String get content;
  @override
  List<String> get tags;
  @override
  List<UserModel> get selectedUsers;
  @override
  String? get imagePath;
  @override
  bool get isAnonymous;
  @override
  String? get draftId;
  @override
  StoryType get type;
  @override
  bool get isEditing;
  @override
  String? get originalStoryId;

  /// Create a copy of PostCreationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostCreationStateImplCopyWith<_$PostCreationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
