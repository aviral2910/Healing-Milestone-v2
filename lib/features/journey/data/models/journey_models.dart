import 'package:freezed_annotation/freezed_annotation.dart';

enum TimelinePosition {
  @JsonValue('standalone')
  standalone,
  @JsonValue('start')
  start,
  @JsonValue('middle')
  middle,
  @JsonValue('end')
  end;

  static TimelinePosition fromString(String value) {
    return TimelinePosition.values.firstWhere((e) => e.name == value, orElse: () => TimelinePosition.standalone);
  }
}

enum EmotionStatus {
  @JsonValue('proud')
  proud,
  @JsonValue('anxious')
  anxious,
  @JsonValue('grieving')
  grieving,
  @JsonValue('hopeful')
  hopeful,
  @JsonValue('neutral')
  neutral;

  static EmotionStatus fromString(String value) {
    return EmotionStatus.values.firstWhere((e) => e.name == value, orElse: () => EmotionStatus.neutral);
  }
}

enum MilestoneVisibility {
  @JsonValue('private')
  private,
  @JsonValue('anonymous')
  anonymous,
  @JsonValue('public')
  public;

  static MilestoneVisibility fromString(String value) {
    return MilestoneVisibility.values.firstWhere((e) => e.name == value, orElse: () => MilestoneVisibility.private);
  }
}

class JourneyModel {
  final String id;
  final String userId;
  final String title;
  final String category;
  final MilestoneVisibility visibility;
  final bool isActive;
  final DateTime createdAt;

  JourneyModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    this.visibility = MilestoneVisibility.public,
    this.isActive = true,
    required this.createdAt,
  });

  factory JourneyModel.fromJson(Map<String, dynamic> json) {
    return JourneyModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'General',
      visibility: MilestoneVisibility.fromString(json['visibility'] as String? ?? 'public'),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'visibility': visibility.name,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class JourneyMilestoneModel {
  final String id;
  final String userId;
  final String? journeyId;
  final TimelinePosition timelinePosition;
  final EmotionStatus emotionStatus;
  final String? content;
  final String? mediaUrl;
  final MilestoneVisibility visibility;
  final DateTime createdAt;
  final String? authorName;
  final String? authorAvatar;

  JourneyMilestoneModel({
    required this.id,
    required this.userId,
    this.journeyId,
    this.timelinePosition = TimelinePosition.standalone,
    required this.emotionStatus,
    this.content,
    this.mediaUrl,
    this.visibility = MilestoneVisibility.private,
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
  });

  factory JourneyMilestoneModel.fromJson(Map<String, dynamic> json) {
    return JourneyMilestoneModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      journeyId: json['journey_id'] as String?,
      timelinePosition: TimelinePosition.fromString(json['timeline_position'] as String? ?? 'standalone'),
      emotionStatus: EmotionStatus.fromString(json['emotion_status'] as String? ?? 'neutral'),
      content: json['content'] as String?,
      mediaUrl: json['media_url'] as String?,
      visibility: MilestoneVisibility.fromString(json['visibility'] as String? ?? 'private'),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      authorName: json['author_name'] as String?,
      authorAvatar: json['author_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'journey_id': journeyId,
      'timeline_position': timelinePosition.name,
      'emotion_status': emotionStatus.name,
      'content': content,
      'media_url': mediaUrl,
      'visibility': visibility.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class MilestoneReactionModel {
  final String id;
  final String milestoneId;
  final String senderUserId;
  final String reactionType;
  final DateTime createdAt;

  MilestoneReactionModel({
    required this.id,
    required this.milestoneId,
    required this.senderUserId,
    required this.reactionType,
    required this.createdAt,
  });

  factory MilestoneReactionModel.fromJson(Map<String, dynamic> json) {
    return MilestoneReactionModel(
      id: json['id'] as String,
      milestoneId: json['milestone_id'] as String,
      senderUserId: json['sender_user_id'] as String,
      reactionType: json['reaction_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'milestone_id': milestoneId,
      'sender_user_id': senderUserId,
      'reaction_type': reactionType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
