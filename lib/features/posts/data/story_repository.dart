import 'package:healing_milestones/core/models/story_model.dart';

abstract class StoryRepository {
  Stream<List<StoryModel>> getStories();
  Future<({List<StoryModel> stories, dynamic lastDoc})> getPaginatedStories({dynamic startAfter, int limit = 5});
  Stream<List<StoryModel>> getUserStories(String userId);
  Stream<List<StoryModel>> getStoriesTaggedWithUser(String userId);
  Future<List<StoryModel>> getStoriesByHashtag(String hashtag);
  Stream<List<StoryModel>> watchStoriesByHashtag(String hashtag);
  Stream<StoryModel?> getStoryById(String storyId);
  Future<void> createStory(StoryModel story);
  Future<void> updateStory(StoryModel story);
  Future<void> deleteStory(String storyId);
  Future<void> toggleReaction(String storyId, String userId, String reactionType);
  Future<List<StoryModel>> getStoriesByIds(List<String> storyIds);
}
