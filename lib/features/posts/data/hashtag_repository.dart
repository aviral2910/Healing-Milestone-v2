import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/posts/data/api_hashtag_repository.dart';

final hashtagRepositoryProvider = Provider<ApiHashtagRepository>((ref) {
  return ref.watch(apiHashtagRepositoryProvider);
});

final trendingHashtagsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(hashtagRepositoryProvider);
  return repository.getTrendingHashtags(limit: 50);
});
