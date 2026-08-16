import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:healing_milestones/core/models/comment_model.dart';
import 'package:healing_milestones/core/models/paginated_response.dart';
import 'package:healing_milestones/core/models/user_model.dart';
import 'package:healing_milestones/core/network/api_client.dart';

part 'paginated_comments_provider.g.dart';

@riverpod
class PaginatedComments extends _$PaginatedComments {
  bool _isFetchingMore = false;

  @override
  Future<PaginatedResponse<CommentModel>> build(String storyId) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.dio.get('/api/stories/$storyId/comments?skip=0&limit=100');
    final items = (response.data['items'] as List).map((json) {
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
    
    return PaginatedResponse<CommentModel>(
      items: items,
      nextCursor: response.data['next_cursor'],
      isEnd: response.data['is_end'] ?? true,
    );
  }

  Future<void> fetchNextPage() async {
    if (_isFetchingMore) return;
    final currentState = state.value;
    if (currentState == null || currentState.isEnd) return;

    _isFetchingMore = true;
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.get('/api/stories/$storyId/comments?skip=${currentState.nextCursor}&limit=100');
      
      final newItems = (response.data['items'] as List).map((json) {
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
      
      state = AsyncData(PaginatedResponse<CommentModel>(
        items: [...currentState.items, ...newItems],
        nextCursor: response.data['next_cursor'],
        isEnd: response.data['is_end'] ?? true,
      ));
    } finally {
      _isFetchingMore = false;
    }
  }
}
