import re

with open("lib/features/search/data/search_providers.dart", "r") as f:
    content = f.read()

# Replace the StateNotifier implementations with AsyncNotifier
marker = "class PaginatedSearchNotifier<T> extends StateNotifier<AsyncValue<PaginatedSearchState<T>>> {"
if marker in content:
    content = content[:content.find(marker)]

new_providers = """
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
    
    final currentState = state.valueOrNull;
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
    
    final currentState = state.valueOrNull;
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
    
    final currentState = state.valueOrNull;
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
"""

content = content + new_providers

with open("lib/features/search/data/search_providers.dart", "w") as f:
    f.write(content)
