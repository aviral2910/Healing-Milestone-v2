import 'package:flutter_riverpod/flutter_riverpod.dart';
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
final hashtagStoriesProvider = StreamProvider.family<List<StoryModel>, String>((ref, hashtag) {
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

