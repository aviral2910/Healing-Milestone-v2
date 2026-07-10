import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_user.dart'; // For TimestampConverter

part 'media_attachment.freezed.dart';
part 'media_attachment.g.dart';

@freezed
class MediaAttachment with _$MediaAttachment {
  const factory MediaAttachment({
    required String mediaId,
    required String url,
    required String title,
    required String description,
    @Default(false) bool isSensitive,
    @TimestampConverter() required DateTime uploadedAt,
  }) = _MediaAttachment;

  factory MediaAttachment.fromJson(Map<String, dynamic> json) => _$MediaAttachmentFromJson(json);
}
