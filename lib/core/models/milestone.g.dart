// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MilestoneImpl _$$MilestoneImplFromJson(Map<String, dynamic> json) =>
    _$MilestoneImpl(
      milestoneId: json['milestoneId'] as String,
      authorId: json['authorId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      templateStyle: json['templateStyle'] as String,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      taggedEntities: (json['taggedEntities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mediaAttachments: (json['mediaAttachments'] as List<dynamic>?)
              ?.map((e) => MediaAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
    );

Map<String, dynamic> _$$MilestoneImplToJson(_$MilestoneImpl instance) =>
    <String, dynamic>{
      'milestoneId': instance.milestoneId,
      'authorId': instance.authorId,
      'title': instance.title,
      'content': instance.content,
      'templateStyle': instance.templateStyle,
      'isAnonymous': instance.isAnonymous,
      'isVerified': instance.isVerified,
      'taggedEntities': instance.taggedEntities,
      'mediaAttachments': instance.mediaAttachments,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
