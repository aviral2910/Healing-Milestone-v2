// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MediaAttachmentImpl _$$MediaAttachmentImplFromJson(
        Map<String, dynamic> json) =>
    _$MediaAttachmentImpl(
      mediaId: json['mediaId'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isSensitive: json['isSensitive'] as bool? ?? false,
      uploadedAt:
          const TimestampConverter().fromJson(json['uploadedAt'] as Timestamp),
    );

Map<String, dynamic> _$$MediaAttachmentImplToJson(
        _$MediaAttachmentImpl instance) =>
    <String, dynamic>{
      'mediaId': instance.mediaId,
      'url': instance.url,
      'title': instance.title,
      'description': instance.description,
      'isSensitive': instance.isSensitive,
      'uploadedAt': const TimestampConverter().toJson(instance.uploadedAt),
    };
