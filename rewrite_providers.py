import re

with open("lib/features/search/data/search_providers.dart", "r") as f:
    content = f.read()

# Remove everything after PaginatedSearchState
marker = "class PaginatedSearchState<T> {"
if marker in content:
    content = content[:content.find(marker)]

new_providers = """
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

class PaginatedSearchNotifier<T> extends StateNotifier<AsyncValue<PaginatedSearchState<T>>> {
  final Ref ref;
  final Future<List<T>> Function(String query, int skip, int limit) fetcher;

  PaginatedSearchNotifier(this.ref, this.fetcher) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final query = ref.watch(globalSearchQueryProvider);
    if (query.isEmpty) {
      state = AsyncValue.data(PaginatedSearchState(items: []));
      return;
    }

    try {
      final items = await fetcher(query, 0, 20);
      state = AsyncValue.data(PaginatedSearchState(items: items, hasMore: items.length == 20));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    final query = ref.read(globalSearchQueryProvider);
    if (query.isEmpty) return;

    final currentState = state.valueOrNull;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) return;

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final newItems = await fetcher(query, currentState.items.length, 20);
      state = AsyncValue.data(currentState.copyWith(
        items: [...currentState.items, ...newItems],
        isLoadingMore: false,
        hasMore: newItems.length == 20,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final paginatedPeopleProvider = StateNotifierProvider.autoDispose<PaginatedSearchNotifier<UserModel>, AsyncValue<PaginatedSearchState<UserModel>>>((ref) {
  final repo = ref.watch(apiSearchRepositoryProvider);
  return PaginatedSearchNotifier(ref, (q, s, l) => repo.searchPeople(q, skip: s, limit: l));
});

final paginatedStoriesProvider = StateNotifierProvider.autoDispose<PaginatedSearchNotifier<StoryModel>, AsyncValue<PaginatedSearchState<StoryModel>>>((ref) {
  final repo = ref.watch(apiSearchRepositoryProvider);
  return PaginatedSearchNotifier(ref, (q, s, l) => repo.searchStories(q, skip: s, limit: l));
});

final paginatedJourneysProvider = StateNotifierProvider.autoDispose<PaginatedSearchNotifier<JourneyModel>, AsyncValue<PaginatedSearchState<JourneyModel>>>((ref) {
  final repo = ref.watch(apiSearchRepositoryProvider);
  return PaginatedSearchNotifier(ref, (q, s, l) => repo.searchJourneys(q, skip: s, limit: l));
});
"""

content = content + new_providers

with open("lib/features/search/data/search_providers.dart", "w") as f:
    f.write(content)
