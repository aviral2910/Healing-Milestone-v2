

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/core/models/paginated_response.dart';
import 'package:healing_milestones/core/repositories/firebase_storage_repository.dart';
import 'package:healing_milestones/core/repositories/storage_repository.dart';
import 'package:healing_milestones/features/posts/data/api_story_repository.dart';
import 'package:healing_milestones/features/posts/data/story_repository.dart';
import 'package:healing_milestones/features/posts/data/comment_repository.dart';
import 'package:healing_milestones/features/posts/data/api_comment_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:healing_milestones/core/models/comment_model.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';

final firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider =
    Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return FirebaseStorageRepository(ref.watch(firebaseStorageProvider));
});

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return ref.watch(apiStoryRepositoryProvider);
});

final storiesStreamProvider = StreamProvider<List<StoryModel>>((ref) {
  return ref.watch(storyRepositoryProvider).getStories();
});

final userStoriesProvider =
    StreamProvider.family<List<StoryModel>, String>((ref, userId) {
  return ref.watch(storyRepositoryProvider).getUserStories(userId);
});

class RecommendedStoriesNotifier
    extends AsyncNotifier<PaginatedResponse<StoryModel>> {
  bool _isFetchingMore = false;

  @override
  Future<PaginatedResponse<StoryModel>> build() async {
    return ref.watch(storyRepositoryProvider).getRecommendedStories();
  }

  Future<void> fetchNextPage() async {
    if (_isFetchingMore) return;
    final currentState = state.value;
    if (currentState == null || currentState.isEnd) return;

    _isFetchingMore = true;
    try {
      final response = await ref
          .read(storyRepositoryProvider)
          .getRecommendedStories(cursor: currentState.nextCursor);
      state = AsyncValue.data(
        PaginatedResponse(
          items: [...currentState.items, ...response.items],
          nextCursor: response.nextCursor,
          isEnd: response.isEnd,
        ),
      );
    } catch (e, st) {
      print('Error fetching next page: $e');
      // ignore: invalid_use_of_internal_member
      state = AsyncValue<PaginatedResponse<StoryModel>>.error(e, st).copyWithPrevious(state);
    } finally {
      _isFetchingMore = false;
    }
  }
}

final recommendedStoriesProvider = AsyncNotifierProvider<
    RecommendedStoriesNotifier, PaginatedResponse<StoryModel>>(() {
  return RecommendedStoriesNotifier();
});

final storyByIdProvider =
    StreamProvider.family<StoryModel?, String>((ref, storyId) {
  return ref.watch(storyRepositoryProvider).getStoryById(storyId);
});

final userTaggedStoriesProvider =
    StreamProvider.family<List<StoryModel>, String>((ref, userId) {
  return ref.watch(storyRepositoryProvider).getStoriesTaggedWithUser(userId);
});

final bookmarkedStoriesProvider =
    FutureProvider.family<List<StoryModel>, String>((ref, userId) async {
  final user = await ref.watch(userStreamProvider(userId).future);
  if (user == null || user.bookmarkedStories.isEmpty) return [];
  return ref
      .watch(storyRepositoryProvider)
      .getStoriesByIds(user.bookmarkedStories);
});

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return ref.watch(apiCommentRepositoryProvider);
});

final storyCommentsProvider =
    StreamProvider.family<List<CommentModel>, String>((ref, storyId) {
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

    debugPrint(
        'PaginatedStoriesNotifier: fetching page... (startAfter: ${_lastDoc != null ? "yes" : "null"})');
    final repo = ref.read(storyRepositoryProvider);
    final result =
        await repo.getPaginatedStories(startAfter: _lastDoc, limit: 5);

    _lastDoc = result.lastDoc;
    debugPrint(
        'PaginatedStoriesNotifier: fetched ${result.stories.length} stories');
    if (result.stories.length < 5) {
      hasMore = false;
      debugPrint('PaginatedStoriesNotifier: reached end of feed');
    }

    return result.stories;
  }

  Future<void> fetchNextPage() async {
    if (isLoadingMore || !hasMore || state.isLoading) {
      debugPrint(
          'PaginatedStoriesNotifier: fetchNextPage skipped (isLoadingMore: $isLoadingMore, hasMore: $hasMore, isLoading: ${state.isLoading})');
      return;
    }

    debugPrint('PaginatedStoriesNotifier: fetchNextPage called');
    isLoadingMore = true;
    try {
      final nextStories = await _fetchPage();
      state = AsyncData([...state.value ?? [], ...nextStories]);
    } catch (e, st) {
      print('Error fetching next page: $e');
      // ignore: invalid_use_of_internal_member
      state = AsyncValue<List<StoryModel>>.error(e, st).copyWithPrevious(state);
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

final paginatedStoriesProvider =
    AsyncNotifierProvider<PaginatedStoriesNotifier, List<StoryModel>>(() {
  return PaginatedStoriesNotifier();
});








