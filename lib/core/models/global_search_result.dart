import 'user_model.dart';
import 'story_model.dart';

class GlobalSearchResult {
  final List<UserModel> people;
  final List<String> tags;
  final List<StoryModel> stories;

  GlobalSearchResult({
    required this.people,
    required this.tags,
    required this.stories,
  });
}
