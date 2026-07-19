import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String storyId;
  final String commentText;
  final String userId;
  final DateTime createdAt;

  CommentModel({
    required this.commentId,
    required this.storyId,
    required this.commentText,
    required this.userId,
    required this.createdAt,
  });

  CommentModel copyWith({
    String? commentId,
    String? storyId,
    String? commentText,
    String? userId,
    DateTime? createdAt,
  }) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      storyId: storyId ?? this.storyId,
      commentText: commentText ?? this.commentText,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'storyId': storyId,
      'commentText': commentText,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CommentModel(
      commentId: documentId,
      storyId: map['storyId'] ?? '',
      commentText: map['commentText'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
