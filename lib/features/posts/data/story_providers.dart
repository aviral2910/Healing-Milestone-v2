import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/core/repositories/firebase_storage_repository.dart';
import 'package:healing_milestones/core/repositories/storage_repository.dart';
import 'package:healing_milestones/features/posts/data/firebase_story_repository.dart';
import 'package:healing_milestones/features/posts/data/api_story_repository.dart';
import 'package:healing_milestones/features/posts/data/story_repository.dart';
import 'package:healing_milestones/features/posts/data/comment_repository.dart';
import 'package:healing_milestones/features/posts/data/api_comment_repository.dart';
import 'package:healing_milestones/features/posts/data/firebase_comment_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:healing_milestones/core/models/comment_model.dart';

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return FirebaseStorageRepository(ref.watch(firebaseStorageProvider));
});

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return ref.watch(apiStoryRepositoryProvider);
});

final storiesStreamProvider = StreamProvider<List<StoryModel>>((ref) {
  return ref.watch(storyRepositoryProvider).getStories();
});

final userStoriesProvider = StreamProvider.family<List<StoryModel>, String>((ref, userId) {
  return ref.watch(storyRepositoryProvider).getUserStories(userId);
});

final storyByIdProvider = StreamProvider.family<StoryModel?, String>((ref, storyId) {
  return ref.watch(storyRepositoryProvider).getStoryById(storyId);
});

final userTaggedStoriesProvider = StreamProvider.family<List<StoryModel>, String>((ref, userId) {
  return ref.watch(storyRepositoryProvider).getStoriesTaggedWithUser(userId);
});

final bookmarkedStoriesProvider = FutureProvider.family<List<StoryModel>, List<String>>((ref, storyIds) {
  if (storyIds.isEmpty) return Future.value([]);
  return ref.watch(storyRepositoryProvider).getStoriesByIds(storyIds);
});

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return ref.watch(apiCommentRepositoryProvider);
});

final storyCommentsProvider = StreamProvider.family<List<CommentModel>, String>((ref, storyId) {
  return ref.watch(commentRepositoryProvider).getComments(storyId);
});

class PaginatedStoriesNotifier extends AsyncNotifier<List<StoryModel>> {
  dynamic _lastDoc;
  bool hasMore = true;
  bool isLoadingMore = false;

  @override
  Future<List<StoryModel>> build() async {
    debugPrint('PaginatedStoriesNotifier: build() initialized');
    _lastDoc = null;
    hasMore = true;
    isLoadingMore = false;
    return _fetchPage();
  }

  Future<List<StoryModel>> _fetchPage() async {
    if (!hasMore) {
      debugPrint('PaginatedStoriesNotifier: no more stories to fetch');
      return state.value ?? [];
    }
    
    debugPrint('PaginatedStoriesNotifier: fetching page... (startAfter: ${_lastDoc != null ? "yes" : "null"})');
    final repo = ref.read(storyRepositoryProvider);
    final result = await repo.getPaginatedStories(startAfter: _lastDoc, limit: 5);
    
    _lastDoc = result.lastDoc;
    debugPrint('PaginatedStoriesNotifier: fetched ${result.stories.length} stories');
    if (result.stories.length < 5) {
      hasMore = false;
      debugPrint('PaginatedStoriesNotifier: reached end of feed');
    }
    
    return result.stories;
  }

  Future<void> fetchNextPage() async {
    if (isLoadingMore || !hasMore || state.isLoading) {
      debugPrint('PaginatedStoriesNotifier: fetchNextPage skipped (isLoadingMore: $isLoadingMore, hasMore: $hasMore, isLoading: ${state.isLoading})');
      return;
    }
    
    debugPrint('PaginatedStoriesNotifier: fetchNextPage called');
    isLoadingMore = true;
    try {
      final nextStories = await _fetchPage();
      state = AsyncData([...state.value ?? [], ...nextStories]);
    } catch (e) {
      print('Error fetching next page: $e');
    } finally {
      isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    _lastDoc = null;
    hasMore = true;
    isLoadingMore = false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage());
  }
}

final paginatedStoriesProvider = AsyncNotifierProvider<PaginatedStoriesNotifier, List<StoryModel>>(() {
  return PaginatedStoriesNotifier();
});
