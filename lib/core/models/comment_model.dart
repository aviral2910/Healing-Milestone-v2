import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healing_milestones/core/models/user_model.dart';

class CommentModel {
  final String commentId;
  final String storyId;
  final String commentText;
  final String userId;
  final DateTime createdAt;
  final UserModel? user;

  CommentModel({
    required this.commentId,
    required this.storyId,
    required this.commentText,
    required this.userId,
    required this.createdAt,
    this.user,
  });

  CommentModel copyWith({
    String? commentId,
    String? storyId,
    String? commentText,
    String? userId,
    DateTime? createdAt,
    UserModel? user,
  }) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      storyId: storyId ?? this.storyId,
      commentText: commentText ?? this.commentText,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'storyId': storyId,
      'commentText': commentText,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      // omit user from map to not write it to firestore directly
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CommentModel(
      commentId: documentId,
      storyId: map['storyId'] ?? '',
      commentText: map['commentText'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      user: map['user'] != null ? UserModel.fromMap(map['user']) : null,
    );
  }
}
