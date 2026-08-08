// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_creation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostCreationState {
  String get title;
  String get content;
  List<String> get tags;
  List<UserModel> get selectedUsers;
  String? get imagePath;
  bool get isAnonymous;
  String? get draftId;
  StoryType get type;
  bool get isEditing;
  String? get originalStoryId;

  /// Create a copy of PostCreationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PostCreationStateCopyWith<PostCreationState> get copyWith =>
      _$PostCreationStateCopyWithImpl<PostCreationState>(
          this as PostCreationState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PostCreationState &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality()
                .equals(other.selectedUsers, selectedUsers) &&
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
      const DeepCollectionEquality().hash(tags),
      const DeepCollectionEquality().hash(selectedUsers),
      imagePath,
      isAnonymous,
      draftId,
      type,
      isEditing,
      originalStoryId);

  @override
  String toString() {
    return 'PostCreationState(title: $title, content: $content, tags: $tags, selectedUsers: $selectedUsers, imagePath: $imagePath, isAnonymous: $isAnonymous, draftId: $draftId, type: $type, isEditing: $isEditing, originalStoryId: $originalStoryId)';
  }
}

/// @nodoc
abstract mixin class $PostCreationStateCopyWith<$Res> {
  factory $PostCreationStateCopyWith(
          PostCreationState value, $Res Function(PostCreationState) _then) =
      _$PostCreationStateCopyWithImpl;
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
class _$PostCreationStateCopyWithImpl<$Res>
    implements $PostCreationStateCopyWith<$Res> {
  _$PostCreationStateCopyWithImpl(this._self, this._then);

  final PostCreationState _self;
  final $Res Function(PostCreationState) _then;

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
    return _then(PostCreationState(
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedUsers: null == selectedUsers
          ? _self.selectedUsers
          : selectedUsers // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      imagePath: freezed == imagePath
          ? _self.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isAnonymous: null == isAnonymous
          ? _self.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      draftId: freezed == draftId
          ? _self.draftId
          : draftId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoryType,
      isEditing: null == isEditing
          ? _self.isEditing
          : isEditing // ignore: cast_nullable_to_non_nullable
              as bool,
      originalStoryId: freezed == originalStoryId
          ? _self.originalStoryId
          : originalStoryId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PostCreationState].
extension PostCreationStatePatterns on PostCreationState {
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
    TResult Function(_PostCreationState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostCreationState() when $default != null:
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
    TResult Function(_PostCreationState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostCreationState():
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
    TResult? Function(_PostCreationState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostCreationState() when $default != null:
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
            String title,
            String content,
            List<String> tags,
            List<UserModel> selectedUsers,
            String? imagePath,
            bool isAnonymous,
            String? draftId,
            StoryType type,
            bool isEditing,
            String? originalStoryId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostCreationState() when $default != null:
        return $default(
            _that.title,
            _that.content,
            _that.tags,
            _that.selectedUsers,
            _that.imagePath,
            _that.isAnonymous,
            _that.draftId,
            _that.type,
            _that.isEditing,
            _that.originalStoryId);
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
            String title,
            String content,
            List<String> tags,
            List<UserModel> selectedUsers,
            String? imagePath,
            bool isAnonymous,
            String? draftId,
            StoryType type,
            bool isEditing,
            String? originalStoryId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostCreationState():
        return $default(
            _that.title,
            _that.content,
            _that.tags,
            _that.selectedUsers,
            _that.imagePath,
            _that.isAnonymous,
            _that.draftId,
            _that.type,
            _that.isEditing,
            _that.originalStoryId);
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
            String title,
            String content,
            List<String> tags,
            List<UserModel> selectedUsers,
            String? imagePath,
            bool isAnonymous,
            String? draftId,
            StoryType type,
            bool isEditing,
            String? originalStoryId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostCreationState() when $default != null:
        return $default(
            _that.title,
            _that.content,
            _that.tags,
            _that.selectedUsers,
            _that.imagePath,
            _that.isAnonymous,
            _that.draftId,
            _that.type,
            _that.isEditing,
            _that.originalStoryId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PostCreationState implements PostCreationState {
  const _PostCreationState(
      {this.title = '',
      this.content = '',
      List<String> tags = const [],
      List<UserModel> selectedUsers = const [],
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

  /// Create a copy of PostCreationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PostCreationStateCopyWith<_PostCreationState> get copyWith =>
      __$PostCreationStateCopyWithImpl<_PostCreationState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PostCreationState &&
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

  @override
  String toString() {
    return 'PostCreationState(title: $title, content: $content, tags: $tags, selectedUsers: $selectedUsers, imagePath: $imagePath, isAnonymous: $isAnonymous, draftId: $draftId, type: $type, isEditing: $isEditing, originalStoryId: $originalStoryId)';
  }
}

/// @nodoc
abstract mixin class _$PostCreationStateCopyWith<$Res>
    implements $PostCreationStateCopyWith<$Res> {
  factory _$PostCreationStateCopyWith(
          _PostCreationState value, $Res Function(_PostCreationState) _then) =
      __$PostCreationStateCopyWithImpl;
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
class __$PostCreationStateCopyWithImpl<$Res>
    implements _$PostCreationStateCopyWith<$Res> {
  __$PostCreationStateCopyWithImpl(this._self, this._then);

  final _PostCreationState _self;
  final $Res Function(_PostCreationState) _then;

  /// Create a copy of PostCreationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_PostCreationState(
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedUsers: null == selectedUsers
          ? _self._selectedUsers
          : selectedUsers // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      imagePath: freezed == imagePath
          ? _self.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isAnonymous: null == isAnonymous
          ? _self.isAnonymous
          : isAnonymous // ignore: cast_nullable_to_non_nullable
              as bool,
      draftId: freezed == draftId
          ? _self.draftId
          : draftId // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as StoryType,
      isEditing: null == isEditing
          ? _self.isEditing
          : isEditing // ignore: cast_nullable_to_non_nullable
              as bool,
      originalStoryId: freezed == originalStoryId
          ? _self.originalStoryId
          : originalStoryId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
