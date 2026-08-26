import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../features/journey/data/models/journey_models.dart';
import '../../../core/models/user_model.dart';
import '../../auth/data/repository_providers.dart';
import '../../posts/data/hashtag_repository.dart';
import '../../posts/data/story_providers.dart';
import '../../../core/models/story_model.dart';
import '../../../core/models/global_search_result.dart';
import 'api_search_repository.dart';

// The current search query for Hashtags
class HashtagSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) {
    state = newQuery;
  }
}

final hashtagSearchQueryProvider = NotifierProvider<HashtagSearchQueryNotifier, String>(HashtagSearchQueryNotifier.new);

// The current search query for People
class PeopleSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) {
    state = newQuery;
  }
}

final peopleSearchQueryProvider = NotifierProvider<PeopleSearchQueryNotifier, String>(PeopleSearchQueryNotifier.new);

// Provider to fetch users based on search query
final searchUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final query = ref.watch(peopleSearchQueryProvider);
  if (query.isEmpty) return [];

  final userRepository = ref.watch(userRepositoryProvider);
  return await userRepository.searchUsers(query);
});

// Provider to fetch hashtags based on search query
final searchHashtagsProvider = FutureProvider<List<String>>((ref) async {
  final query = ref.watch(hashtagSearchQueryProvider);
  if (query.isEmpty) return [];

  final hashtagRepository = ref.watch(hashtagRepositoryProvider);
  return await hashtagRepository.searchHashtags(query);
});

// Provider to fetch stories containing a specific hashtag (real-time stream)
final hashtagStoriesProvider = StreamProvider.autoDispose.family<List<StoryModel>, String>((ref, hashtag) {
  if (hashtag.isEmpty) return Stream.value([]);
  final repo = ref.watch(storyRepositoryProvider);
  return repo.watchStoriesByHashtag(hashtag);
});

// The current search query for Global Search
class GlobalSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) {
    state = newQuery;
  }
}

final globalSearchQueryProvider = NotifierProvider<GlobalSearchQueryNotifier, String>(GlobalSearchQueryNotifier.new);

// Provider to fetch global search results
final globalSearchProvider = FutureProvider<GlobalSearchResult?>((ref) async {
  final query = ref.watch(globalSearchQueryProvider);
  if (query.isEmpty) return null;

  final searchRepository = ref.watch(apiSearchRepositoryProvider);
  return await searchRepository.globalSearch(query);
});


// Paginated Providers


class PaginatedSearchState<T> {
  final List<T> items;
  final bool isLoadingMore;
  final bool hasMore;

  PaginatedSearchState({
    required this.items,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  PaginatedSearchState<T> copyWith({
    List<T>? items,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return PaginatedSearchState<T>(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}


class PeopleSearchNotifier extends AsyncNotifier<PaginatedSearchState<UserModel>> {
  @override
  Future<PaginatedSearchState<UserModel>> build() async {
    final query = ref.watch(globalSearchQueryProvider);
    if (query.isEmpty) return PaginatedSearchState(items: []);
    
    final repo = ref.watch(apiSearchRepositoryProvider);
    final items = await repo.searchPeople(query, skip: 0, limit: 20);
    return PaginatedSearchState(items: items, hasMore: items.length == 20);
  }

  Future<void> loadMore() async {
    final query = ref.read(globalSearchQueryProvider);
    if (query.isEmpty) return;
    
    final currentState = state.asData?.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) return;

    state = AsyncData(currentState.copyWith(isLoadingMore: true));
    
    try {
      final repo = ref.read(apiSearchRepositoryProvider);
      final newItems = await repo.searchPeople(query, skip: currentState.items.length, limit: 20);
      
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...newItems],
        isLoadingMore: false,
        hasMore: newItems.length == 20,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

class StoriesSearchNotifier extends AsyncNotifier<PaginatedSearchState<StoryModel>> {
  @override
  Future<PaginatedSearchState<StoryModel>> build() async {
    final query = ref.watch(globalSearchQueryProvider);
    if (query.isEmpty) return PaginatedSearchState(items: []);
    
    final repo = ref.watch(apiSearchRepositoryProvider);
    final items = await repo.searchStories(query, skip: 0, limit: 20);
    return PaginatedSearchState(items: items, hasMore: items.length == 20);
  }

  Future<void> loadMore() async {
    final query = ref.read(globalSearchQueryProvider);
    if (query.isEmpty) return;
    
    final currentState = state.asData?.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) return;

    state = AsyncData(currentState.copyWith(isLoadingMore: true));
    
    try {
      final repo = ref.read(apiSearchRepositoryProvider);
      final newItems = await repo.searchStories(query, skip: currentState.items.length, limit: 20);
      
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...newItems],
        isLoadingMore: false,
        hasMore: newItems.length == 20,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

class JourneysSearchNotifier extends AsyncNotifier<PaginatedSearchState<JourneyModel>> {
  @override
  Future<PaginatedSearchState<JourneyModel>> build() async {
    final query = ref.watch(globalSearchQueryProvider);
    if (query.isEmpty) return PaginatedSearchState(items: []);
    
    final repo = ref.watch(apiSearchRepositoryProvider);
    final items = await repo.searchJourneys(query, skip: 0, limit: 20);
    return PaginatedSearchState(items: items, hasMore: items.length == 20);
  }

  Future<void> loadMore() async {
    final query = ref.read(globalSearchQueryProvider);
    if (query.isEmpty) return;
    
    final currentState = state.asData?.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) return;

    state = AsyncData(currentState.copyWith(isLoadingMore: true));
    
    try {
      final repo = ref.read(apiSearchRepositoryProvider);
      final newItems = await repo.searchJourneys(query, skip: currentState.items.length, limit: 20);
      
      state = AsyncData(currentState.copyWith(
        items: [...currentState.items, ...newItems],
        isLoadingMore: false,
        hasMore: newItems.length == 20,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final paginatedPeopleProvider = AsyncNotifierProvider.autoDispose<PeopleSearchNotifier, PaginatedSearchState<UserModel>>(() {
  return PeopleSearchNotifier();
});

final paginatedStoriesProvider = AsyncNotifierProvider.autoDispose<StoriesSearchNotifier, PaginatedSearchState<StoryModel>>(() {
  return StoriesSearchNotifier();
});

final paginatedJourneysProvider = AsyncNotifierProvider.autoDispose<JourneysSearchNotifier, PaginatedSearchState<JourneyModel>>(() {
  return JourneysSearchNotifier();
});
