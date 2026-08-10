import 'package:dio/dio.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import 'package:healing_milestones/features/posts/data/story_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiStoryRepositoryProvider = Provider<StoryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiStoryRepository(apiClient);
});

class ApiStoryRepository implements StoryRepository {
  final ApiClient _apiClient;

  ApiStoryRepository(this._apiClient);

  Dio get _dio => _apiClient.dio;

  @override
  Stream<List<StoryModel>> getStories() async* {
    try {
      final response = await _dio.get('/api/stories/?limit=50');
      final items = response.data['items'] as List;
      yield items.map((json) => _mapApiToStoryModel(json)).toList();
    } catch (e) {
      yield [];
    }
  }

  @override
  Future<({List<StoryModel> stories, dynamic lastDoc})> getPaginatedStories({dynamic startAfter, int limit = 5}) async {
    int offset = (startAfter is int) ? startAfter : 0;
    
    try {
      final response = await _dio.get('/api/stories/?skip=$offset&limit=$limit');
      final items = response.data['items'] as List;
      final stories = items.map((json) => _mapApiToStoryModel(json)).toList();
      return (stories: stories, lastDoc: offset + limit);
    } catch (e) {
      return (stories: <StoryModel>[], lastDoc: null);
    }
  }

  StoryModel _mapApiToStoryModel(Map<String, dynamic> json) {
    return StoryModel(
      storyId: json['id'] ?? '',
      authorId: json['author_id'] ?? '',
      type: json['type'] ?? 'StoryType.milestone', // Ensure it maps to your enum if needed
      heading: json['heading'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      mainImage: json['main_image'] ?? '',
      imageAssets: List<String>.from(json['image_assets'] ?? []),
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at']) : DateTime.now(),
      reactions: {}, 
      likesList: [], 
      likesCount: 0,
      tags: [],
      taggedPeople: [],
      hashtagsList: [],
      readingTime: json['reading_time'] ?? 0,
      isVerifiedStory: json['is_verified_story'] ?? false,
      verificationStatus: json['verification_status'] ?? 'pending',
      qrId: json['qr_id'] ?? '',
      displayAuthorName: json['display_author_name'] ?? true,
      isHidden: json['is_hidden'] ?? false,
    );
  }

  @override
  Stream<List<StoryModel>> getUserStories(String userId) async* { yield []; }

  @override
  Stream<List<StoryModel>> getStoriesTaggedWithUser(String userId) async* { yield []; }

  @override
  Future<List<StoryModel>> getStoriesByHashtag(String hashtag, {int limit = 20}) async { return []; }

  @override
  Stream<List<StoryModel>> watchStoriesByHashtag(String hashtag, {int limit = 20}) async* { yield []; }

  @override
  Stream<StoryModel?> getStoryById(String storyId) async* { yield null; }

  @override
  Future<void> createStory(StoryModel story) async {
    try {
      await _dio.post('/api/stories/', data: {
        'type': story.type.toString().split('.').last,
        'heading': story.heading,
        'description': story.description,
        'short_description': story.shortDescription,
        'main_image': story.mainImage,
        'image_assets': story.imageAssets,
        'reading_time': story.readingTime,
        'qr_id': story.qrId,
        'display_author_name': story.displayAuthorName,
        'is_hidden': story.isHidden,
        'tags': story.hashtagsList,
        'tagged_user_ids': story.taggedPeople,
      });
    } catch (e) {
      print('Error creating story in API: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStory(StoryModel story) async {}

  @override
  Future<void> deleteStory(String storyId) async {}

  @override
  Future<void> toggleReaction(String storyId, String userId, String reactionType) async {}

  @override
  Future<List<StoryModel>> getStoriesByIds(List<String> storyIds) async { return []; }

  @override
  Future<void> reportStory({required String storyId, required String reporterId, required String reason}) async {}
}
