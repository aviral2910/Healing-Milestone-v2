import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_user.dart';

part 'question.freezed.dart';
part 'question.g.dart';

@freezed
abstract class Question with _$Question {
  const factory Question({
    required String questionId,
    required String milestoneId,
    required String askerId,
    required String questionText,
    String? answerText,
    @Default(false) bool isAnswered,
    @TimestampConverter() required DateTime createdAt,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
}
