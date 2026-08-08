// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Question {
  String get questionId;
  String get milestoneId;
  String get askerId;
  String get questionText;
  String? get answerText;
  bool get isAnswered;
  @TimestampConverter()
  DateTime get createdAt;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuestionCopyWith<Question> get copyWith =>
      _$QuestionCopyWithImpl<Question>(this as Question, _$identity);

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Question &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.milestoneId, milestoneId) ||
                other.milestoneId == milestoneId) &&
            (identical(other.askerId, askerId) || other.askerId == askerId) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.answerText, answerText) ||
                other.answerText == answerText) &&
            (identical(other.isAnswered, isAnswered) ||
                other.isAnswered == isAnswered) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, questionId, milestoneId, askerId,
      questionText, answerText, isAnswered, createdAt);

  @override
  String toString() {
    return 'Question(questionId: $questionId, milestoneId: $milestoneId, askerId: $askerId, questionText: $questionText, answerText: $answerText, isAnswered: $isAnswered, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $QuestionCopyWith<$Res> {
  factory $QuestionCopyWith(Question value, $Res Function(Question) _then) =
      _$QuestionCopyWithImpl;
  @useResult
  $Res call(
      {String questionId,
      String milestoneId,
      String askerId,
      String questionText,
      String? answerText,
      bool isAnswered,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class _$QuestionCopyWithImpl<$Res> implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._self, this._then);

  final Question _self;
  final $Res Function(Question) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questionId = null,
    Object? milestoneId = null,
    Object? askerId = null,
    Object? questionText = null,
    Object? answerText = freezed,
    Object? isAnswered = null,
    Object? createdAt = null,
  }) {
    return _then(Question(
      questionId: null == questionId
          ? _self.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      milestoneId: null == milestoneId
          ? _self.milestoneId
          : milestoneId // ignore: cast_nullable_to_non_nullable
              as String,
      askerId: null == askerId
          ? _self.askerId
          : askerId // ignore: cast_nullable_to_non_nullable
              as String,
      questionText: null == questionText
          ? _self.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      answerText: freezed == answerText
          ? _self.answerText
          : answerText // ignore: cast_nullable_to_non_nullable
              as String?,
      isAnswered: null == isAnswered
          ? _self.isAnswered
          : isAnswered // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [Question].
extension QuestionPatterns on Question {
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
    TResult Function(_Question value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Question() when $default != null:
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
    TResult Function(_Question value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Question():
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
    TResult? Function(_Question value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Question() when $default != null:
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
            String questionId,
            String milestoneId,
            String askerId,
            String questionText,
            String? answerText,
            bool isAnswered,
            @TimestampConverter() DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Question() when $default != null:
        return $default(
            _that.questionId,
            _that.milestoneId,
            _that.askerId,
            _that.questionText,
            _that.answerText,
            _that.isAnswered,
            _that.createdAt);
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
            String questionId,
            String milestoneId,
            String askerId,
            String questionText,
            String? answerText,
            bool isAnswered,
            @TimestampConverter() DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Question():
        return $default(
            _that.questionId,
            _that.milestoneId,
            _that.askerId,
            _that.questionText,
            _that.answerText,
            _that.isAnswered,
            _that.createdAt);
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
            String questionId,
            String milestoneId,
            String askerId,
            String questionText,
            String? answerText,
            bool isAnswered,
            @TimestampConverter() DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Question() when $default != null:
        return $default(
            _that.questionId,
            _that.milestoneId,
            _that.askerId,
            _that.questionText,
            _that.answerText,
            _that.isAnswered,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Question implements Question {
  const _Question(
      {required this.questionId,
      required this.milestoneId,
      required this.askerId,
      required this.questionText,
      this.answerText,
      this.isAnswered = false,
      @TimestampConverter() required this.createdAt});
  factory _Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  @override
  final String questionId;
  @override
  final String milestoneId;
  @override
  final String askerId;
  @override
  final String questionText;
  @override
  final String? answerText;
  @override
  @JsonKey()
  final bool isAnswered;
  @override
  @TimestampConverter()
  final DateTime createdAt;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$QuestionCopyWith<_Question> get copyWith =>
      __$QuestionCopyWithImpl<_Question>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$QuestionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Question &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.milestoneId, milestoneId) ||
                other.milestoneId == milestoneId) &&
            (identical(other.askerId, askerId) || other.askerId == askerId) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.answerText, answerText) ||
                other.answerText == answerText) &&
            (identical(other.isAnswered, isAnswered) ||
                other.isAnswered == isAnswered) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, questionId, milestoneId, askerId,
      questionText, answerText, isAnswered, createdAt);

  @override
  String toString() {
    return 'Question(questionId: $questionId, milestoneId: $milestoneId, askerId: $askerId, questionText: $questionText, answerText: $answerText, isAnswered: $isAnswered, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$QuestionCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory _$QuestionCopyWith(_Question value, $Res Function(_Question) _then) =
      __$QuestionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String questionId,
      String milestoneId,
      String askerId,
      String questionText,
      String? answerText,
      bool isAnswered,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class __$QuestionCopyWithImpl<$Res> implements _$QuestionCopyWith<$Res> {
  __$QuestionCopyWithImpl(this._self, this._then);

  final _Question _self;
  final $Res Function(_Question) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? questionId = null,
    Object? milestoneId = null,
    Object? askerId = null,
    Object? questionText = null,
    Object? answerText = freezed,
    Object? isAnswered = null,
    Object? createdAt = null,
  }) {
    return _then(_Question(
      questionId: null == questionId
          ? _self.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      milestoneId: null == milestoneId
          ? _self.milestoneId
          : milestoneId // ignore: cast_nullable_to_non_nullable
              as String,
      askerId: null == askerId
          ? _self.askerId
          : askerId // ignore: cast_nullable_to_non_nullable
              as String,
      questionText: null == questionText
          ? _self.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      answerText: freezed == answerText
          ? _self.answerText
          : answerText // ignore: cast_nullable_to_non_nullable
              as String?,
      isAnswered: null == isAnswered
          ? _self.isAnswered
          : isAnswered // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
