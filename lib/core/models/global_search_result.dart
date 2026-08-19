import 'user_model.dart';
import 'story_model.dart';
import '../../features/journey/data/models/journey_models.dart';

class GlobalSearchResult {
  final List<UserModel> people;
  final List<String> tags;
  final List<StoryModel> stories;
  final List<JourneyModel> journeys;

  GlobalSearchResult({
    required this.people,
    required this.tags,
    required this.stories,
    this.journeys = const [],
  });
}
