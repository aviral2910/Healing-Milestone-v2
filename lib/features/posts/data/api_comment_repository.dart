import 'package:dio/dio.dart';
import 'package:healing_milestones/core/models/comment_model.dart';
import 'package:healing_milestones/core/models/user_model.dart';
import 'package:healing_milestones/features/posts/data/comment_repository.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiCommentRepositoryProvider = Provider<CommentRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiCommentRepository(apiClient);
});

class ApiCommentRepository implements CommentRepository {
  final ApiClient _apiClient;
  
  ApiCommentRepository(this._apiClient);
  
  Dio get _dio => _apiClient.dio;

  @override
  Stream<List<CommentModel>> getComments(String storyId) async* {
    try {
      final response = await _dio.get('/api/stories/$storyId/comments');
      final items = response.data['items'] as List;
      yield items.map((json) {
        final userJson = json['user'];
        return CommentModel(
          commentId: json['id'] ?? '',
          storyId: storyId,
          commentText: json['text'] ?? '',
          userId: userJson != null ? (userJson['id'] ?? userJson['firebaseUid'] ?? '') : '',
          user: userJson != null ? UserModel.fromMap(userJson) : null,
          createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error parsing comments: $e');
      rethrow;
    }
  }

  @override
  Future<void> addComment(CommentModel comment) async {
    try {
      await _dio.post('/api/stories/${comment.storyId}/comments', data: {
        'content': comment.commentText,
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteComment(String storyId, String commentId) async {
    try {
      await _dio.delete('/api/stories/$storyId/comments/$commentId');
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }
}
