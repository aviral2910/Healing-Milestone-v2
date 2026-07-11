class CommentModel {
  final String commentId;
  final String storyId;
  final String commentText;
  final String userId;

  CommentModel({
    required this.commentId,
    required this.storyId,
    required this.commentText,
    required this.userId,
  });

  CommentModel copyWith({
    String? commentId,
    String? storyId,
    String? commentText,
    String? userId,
  }) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      storyId: storyId ?? this.storyId,
      commentText: commentText ?? this.commentText,
      userId: userId ?? this.userId,
    );
  }
}
