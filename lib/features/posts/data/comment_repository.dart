import 'package:healing_milestones/core/models/comment_model.dart';

abstract class CommentRepository {
  Stream<List<CommentModel>> getComments(String storyId);
  Future<void> addComment(CommentModel comment);
  Future<void> deleteComment(String storyId, String commentId);
}
