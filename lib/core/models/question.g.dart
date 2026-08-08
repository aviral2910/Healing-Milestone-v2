// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Question _$QuestionFromJson(Map<String, dynamic> json) => _Question(
      questionId: json['questionId'] as String,
      milestoneId: json['milestoneId'] as String,
      askerId: json['askerId'] as String,
      questionText: json['questionText'] as String,
      answerText: json['answerText'] as String?,
      isAnswered: json['isAnswered'] as bool? ?? false,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
    );

Map<String, dynamic> _$QuestionToJson(_Question instance) => <String, dynamic>{
      'questionId': instance.questionId,
      'milestoneId': instance.milestoneId,
      'askerId': instance.askerId,
      'questionText': instance.questionText,
      'answerText': instance.answerText,
      'isAnswered': instance.isAnswered,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
