import 'package:healing_milestones/core/models/story_model.dart';

abstract class StoryRepository {
  Stream<List<StoryModel>> getStories();
  Stream<List<StoryModel>> getUserStories(String userId);
  Stream<List<StoryModel>> getStoriesTaggedWithUser(String userId);
  Future<List<StoryModel>> getStoriesByHashtag(String hashtag);
  Stream<StoryModel?> getStoryById(String storyId);
  Future<void> createStory(StoryModel story);
  Future<void> updateStory(StoryModel story);
  Future<void> deleteStory(String storyId);
  Future<void> toggleLike(String storyId, String userId);
}
