import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healing_milestones/core/models/comment_model.dart';
import 'comment_repository.dart';

class FirebaseCommentRepository implements CommentRepository {
  final FirebaseFirestore _firestore;

  FirebaseCommentRepository(this._firestore);

  @override
  Stream<List<CommentModel>> getComments(String storyId) {
    return _firestore
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> addComment(CommentModel comment) async {
    final storyRef = _firestore.collection('stories').doc(comment.storyId);
    final commentRef = storyRef.collection('comments').doc();

    await _firestore.runTransaction((transaction) async {
      final storyDoc = await transaction.get(storyRef);
      if (!storyDoc.exists) return;

      final data = storyDoc.data() as Map<String, dynamic>;
      int commentCount = data['commentCount'] ?? 0;
      commentCount++;

      // In UserModel, we could also update the user's comments list, but let's keep it simple
      // and only update story's comment count for now.
      transaction.update(storyRef, {
        'commentCount': commentCount,
      });
      
      // we need to set the commentId on the object before saving it
      final newComment = comment.copyWith(commentId: commentRef.id);
      transaction.set(commentRef, newComment.toMap());
    });
  }

  @override
  Future<void> deleteComment(String storyId, String commentId) async {
    final storyRef = _firestore.collection('stories').doc(storyId);
    final commentRef = storyRef.collection('comments').doc(commentId);

    await _firestore.runTransaction((transaction) async {
      final storyDoc = await transaction.get(storyRef);
      if (!storyDoc.exists) return;

      final data = storyDoc.data() as Map<String, dynamic>;
      int commentCount = data['commentCount'] ?? 0;
      if (commentCount > 0) commentCount--;

      transaction.update(storyRef, {
        'commentCount': commentCount,
      });

      transaction.delete(commentRef);
    });
  }
}
