import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/features/journey/data/models/journey_models.dart';

class BatchMediaState {
  final Map<String, JourneyModel> journeys;
  final Map<String, StoryModel> stories;
  
  BatchMediaState({this.journeys = const {}, this.stories = const {}});
  
  BatchMediaState copyWith({
    Map<String, JourneyModel>? journeys,
    Map<String, StoryModel>? stories,
  }) {
    return BatchMediaState(
      journeys: journeys ?? this.journeys,
      stories: stories ?? this.stories,
    );
  }
}

class BatchMediaNotifier extends StateNotifier<BatchMediaState> {
  final ApiClient _apiClient;
  final Set<String> _requestedJourneys = {};
  final Set<String> _requestedStories = {};

  BatchMediaNotifier(this._apiClient) : super(BatchMediaState());

  void loadJourneys(List<String> ids) async {
    final needed = ids.where((id) => !_requestedJourneys.contains(id)).toList();
    if (needed.isEmpty) return;

    _requestedJourneys.addAll(needed);
    try {
      final res = await _apiClient.dio.post('/api/journeys/batch', data: {'ids': needed});
      final List data = res.data;
      final newJourneys = {for (var j in data) j['id'].toString(): JourneyModel.fromJson(j)};
      if (mounted) {
        state = state.copyWith(journeys: {...state.journeys, ...newJourneys});
      }
    } catch (e) {
      _requestedJourneys.removeAll(needed); // Allow retry
    }
  }

  void loadStories(List<String> ids) async {
    final needed = ids.where((id) => !_requestedStories.contains(id)).toList();
    if (needed.isEmpty) return;

    _requestedStories.addAll(needed);
    try {
      final res = await _apiClient.dio.post('/api/stories/batch', data: {'ids': needed});
      final List data = res.data['items'] ?? [];
      final newStories = {for (var s in data) s['id'].toString(): StoryModel.fromMap(s, s['id'].toString())};
      if (mounted) {
        state = state.copyWith(stories: {...state.stories, ...newStories});
      }
    } catch (e) {
      _requestedStories.removeAll(needed); // Allow retry
    }
  }
}

final batchMediaProvider = StateNotifierProvider<BatchMediaNotifier, BatchMediaState>((ref) {
  return BatchMediaNotifier(ref.watch(apiClientProvider));
});
