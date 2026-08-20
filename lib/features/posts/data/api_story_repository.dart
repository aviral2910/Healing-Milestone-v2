import 'package:dio/dio.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/core/models/paginated_response.dart';
import 'package:healing_milestones/core/models/user_model.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import 'package:healing_milestones/features/posts/data/story_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

final apiStoryRepositoryProvider = Provider<StoryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiStoryRepository(apiClient);
});

class ApiStoryRepository implements StoryRepository {
  final ApiClient _apiClient;
  
  // View Tracking Batching
  final List<String> _viewedStoryBuffer = [];
  Timer? _batchTimer;
  String? _currentUserId;

  ApiStoryRepository(this._apiClient);

  Dio get _dio => _apiClient.dio;

  @override
  Stream<List<StoryModel>> getStories() async* {
    try {
      final response = await _dio.get('/api/stories/?limit=50');
      final items = response.data['items'] as List;
      yield items.map((json) => _mapApiToStoryModel(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<({List<StoryModel> stories, dynamic lastDoc})> getPaginatedStories({dynamic startAfter, int limit = 5}) async {
    int offset = (startAfter is int) ? startAfter : 0;
    
    try {
      final response = await _dio.get('/api/stories/following?cursor=$offset&limit=$limit');
      final items = response.data['items'] as List;
      final stories = items.map((json) => _mapApiToStoryModel(json)).toList();
      return (stories: stories, lastDoc: offset + limit);
    } catch (e) {
      rethrow;
    }
  }

  StoryModel _mapApiToStoryModel(Map<String, dynamic> json) {
    return StoryModel(
      storyId: json['id'] ?? '',
      authorId: json['authorId'] ?? json['author_id'] ?? '',
      author: json['author'] != null ? UserModel.fromMap(json['author'] as Map<String, dynamic>) : null,
      type: StoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StoryType.story,
      ),
      heading: json['heading'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['shortDescription'] ?? json['short_description'] ?? '',
      mainImage: json['mainImage'] ?? json['main_image'] ?? '',
      imageAssets: List<String>.from(json['imageAssets'] ?? json['image_assets'] ?? []),
      publishedAt: (json['publishedAt'] ?? json['published_at']) != null 
          ? DateTime.parse(json['publishedAt'] ?? json['published_at']) 
          : DateTime.now(),
      reactions: json['reactions'] != null 
          ? (json['reactions'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, List<String>.from(value)),
            )
          : const <String, List<String>>{},
      likesList: const <String>[], 
      likesCount: 0,
      commentCount: json['commentCount'] ?? json['comment_count'] ?? 0,
      taggedUsers: ((json['taggedUsers'] as List?) ?? (json['tagged_users'] as List?))?.map((x) {
        if (x is String) {
          return UserModel(userId: x, email: '', displayName: 'User');
        } else if (x is Map) {
          return UserModel.fromMap(Map<String, dynamic>.from(x));
        }
        return UserModel(userId: '', email: '', displayName: 'User');
      }).toList().cast<UserModel>() ?? <UserModel>[],
      hashtagsList: List<String>.from(json['tags'] ?? []),
      readingTime: json['readingTime'] ?? json['reading_time'] ?? 0,
      isVerifiedStory: json['isVerifiedStory'] ?? json['is_verified_story'] ?? false,
      verificationStatus: json['verificationStatus'] ?? json['verification_status'] ?? 'pending',
      qrId: json['qrId'] ?? json['qr_id'] ?? '',
      displayAuthorName: json['displayAuthorName'] ?? json['display_author_name'] ?? true,
      isHidden: json['isHidden'] ?? json['is_hidden'] ?? false,
      verifierId: json['verifierId'] ?? json['verifier_id'] ?? '',
    );
  }

  @override
  Stream<List<StoryModel>> getUserStories(String userId) async* {
    try {
      final response = await _dio.get('/api/stories/?author_id=$userId&limit=50');
      final items = response.data['items'] as List;
      yield items.map((json) => _mapApiToStoryModel(json)).toList();
    } catch (e, stack) {
      print('Error parsing user stories: $e\n$stack');
      yield [];
    }
  }

  @override
  Stream<List<StoryModel>> getStoriesTaggedWithUser(String userId) async* {
    try {
      final response = await _dio.get('/api/stories/?tagged_user_id=$userId&limit=50');
      final items = response.data['items'] as List;
      yield items.map((json) => _mapApiToStoryModel(json)).toList();
    } catch (e, stack) {
      print('Error parsing tagged stories: $e\n$stack');
      yield [];
    }
  }

  @override
  Future<List<StoryModel>> getStoriesByHashtag(String hashtag, {int limit = 20}) async {
    try {
      final response = await _dio.get('/api/stories/?tag=$hashtag&limit=$limit');
      final items = response.data['items'] as List;
      return items.map((json) => _mapApiToStoryModel(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<StoryModel>> watchStoriesByHashtag(String hashtag, {int limit = 20}) async* {
    yield await getStoriesByHashtag(hashtag, limit: limit);
  }

  @override
  Stream<StoryModel?> getStoryById(String storyId) async* {
    try {
      final response = await _dio.get('/api/stories/$storyId');
      yield _mapApiToStoryModel(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createStory(StoryModel story) async {
    try {
      await _dio.post('/api/stories/', data: {
        'type': story.type.toString().split('.').last,
        'heading': story.heading,
        'description': story.description,
        'short_description': story.shortDescription,
        'main_image': story.mainImage,
        'image_assets': story.imageAssets ?? [],
        'reading_time': story.readingTime ?? 0,
        'qr_id': story.qrId ?? '',
        'display_author_name': story.displayAuthorName ?? true,
        'is_hidden': story.isHidden ?? false,
        'tags': story.hashtagsList ?? [],
        'tagged_user_ids': story.taggedUsers.map((u) => u.userId).toList(),
      });
    } catch (e) {
      print('Error creating story in API: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStory(StoryModel story) async {
    try {
      final data = story.toMap();
      // Remove id from payload
      data.remove('storyId');
      data.remove('id');
      await _dio.put('/api/stories/${story.storyId}', data: data);
    } catch (e) {
      print('Error updating story: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteStory(String storyId) async {
    try {
      await _dio.delete('/api/stories/$storyId');
    } catch (e) {
      print('Error deleting story: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleReaction(String storyId, String userId, String reactionType) async {
    try {
      await _dio.post('/api/stories/$storyId/reactions?reaction_type=$reactionType');
    } catch (e) {
      print('Error toggling reaction: $e');
      rethrow;
    }
  }

  @override
  Future<List<StoryModel>> getStoriesByIds(List<String> storyIds) async {
    if (storyIds.isEmpty) return [];
    try {
      final response = await _dio.post('/api/stories/batch', data: {
        'ids': storyIds,
      });
      final items = response.data['items'] as List;
      return items.map((json) => _mapApiToStoryModel(json)).toList();
    } catch (e) {
      print('Error getting stories by ids: $e');
      rethrow;
    }
  }

  @override
  Future<PaginatedResponse<StoryModel>> getRecommendedStories({String? cursor, int limit = 10}) async {
    try {
      final cursorParam = cursor != null ? '&cursor=$cursor' : '';
      final response = await _dio.get('/api/stories/recommended?limit=$limit$cursorParam');
      return PaginatedResponse<StoryModel>.fromJson(
        response.data,
        (json) => _mapApiToStoryModel(json),
      );
    } catch (e) {
      print('Error getting recommended stories: $e');
      rethrow;
    }
  }

  @override
  Future<void> markStoryAsViewed(String storyId, String userId) async {
    _currentUserId = userId;
    
    if (!_viewedStoryBuffer.contains(storyId)) {
      _viewedStoryBuffer.add(storyId);
    }
    
    // Send batch if we hit 10 items
    if (_viewedStoryBuffer.length >= 10) {
      _sendBatchedViews();
    } else {
      // Or send after 10 seconds of inactivity
      _batchTimer?.cancel();
      _batchTimer = Timer(const Duration(seconds: 10), _sendBatchedViews);
    }
  }

  Future<void> _sendBatchedViews() async {
    if (_viewedStoryBuffer.isEmpty || _currentUserId == null) return;
    
    final batchToSend = List<String>.from(_viewedStoryBuffer);
    _viewedStoryBuffer.clear();
    _batchTimer?.cancel();
    
    try {
      await _apiClient.dio.post('/api/stories/views/batch', data: {
        'user_id': _currentUserId,
        'story_ids': batchToSend,
      });
    } catch (e) {
      print('Error sending batched views: $e');
    }
  }

  @override
  Future<void> reportStory({required String storyId, required String reporterId, required String reason}) async {}
}
