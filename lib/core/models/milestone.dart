import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_user.dart';
import 'media_attachment.dart';

part 'milestone.freezed.dart';
part 'milestone.g.dart';

@freezed
class Milestone with _$Milestone {
  const factory Milestone({
    required String milestoneId,
    required String authorId,
    required String title,
    required String content,
    required String templateStyle,
    @Default(false) bool isAnonymous,
    @Default(false) bool isVerified,
    @Default([]) List<String> taggedEntities,
    @Default([]) List<MediaAttachment> mediaAttachments,
    @TimestampConverter() required DateTime createdAt,
  }) = _Milestone;

  factory Milestone.fromJson(Map<String, dynamic> json) => _$MilestoneFromJson(json);
}
