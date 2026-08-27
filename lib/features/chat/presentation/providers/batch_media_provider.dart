import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/features/journey/data/models/journey_models.dart';
import 'package:hooks_riverpod/legacy.dart';

class BatchMediaState {
  final Map<String, JourneyModel?> journeys;
  final Map<String, StoryModel?> stories;

  BatchMediaState({this.journeys = const {}, this.stories = const {}});

  BatchMediaState copyWith({
    Map<String, JourneyModel?>? journeys,
    Map<String, StoryModel?>? stories,
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
      final res = await _apiClient.dio.post(
        '/api/journeys/batch',
        data: {'ids': needed},
      );
      if (res.data is List) {
        final List data = res.data;
        final newJourneys = <String, JourneyModel?>{
          for (var j in data) j['id'].toString(): JourneyModel.fromJson(j),
        };
        
        for (var id in needed) {
          if (!newJourneys.containsKey(id)) {
            newJourneys[id] = null;
          }
        }
        
        if (mounted) {
          state = state.copyWith(journeys: {...state.journeys, ...newJourneys});
        }
      } else {
        print("Backend returned non-list for journeys batch: ${res.data}");
      }
    } catch (e) {
      print('Error loadJourneys: $e');
      // Update state with nulls to stop infinite loading shimmer
      final errorJourneys = <String, JourneyModel?>{
        for (var id in needed) id: null
      };
      if (mounted) {
        state = state.copyWith(journeys: {...state.journeys, ...errorJourneys});
      }
    }
  }

  void loadStories(List<String> ids) async {
    final needed = ids.where((id) => !_requestedStories.contains(id)).toList();
    if (needed.isEmpty) return;

    _requestedStories.addAll(needed);
    try {
      final res = await _apiClient.dio.post(
        '/api/stories/batch',
        data: {'ids': needed},
      );
      final List data = res.data['items'] ?? [];
      final newStories = <String, StoryModel?>{
        for (var s in data)
          s['id'].toString(): StoryModel.fromMap(s, s['id'].toString()),
      };
      
      for (var id in needed) {
        if (!newStories.containsKey(id)) {
          newStories[id] = null;
        }
      }
      
      if (mounted) {
        state = state.copyWith(stories: {...state.stories, ...newStories});
      }
    } catch (e) {
      print('Error loadStories: $e');
      final errorStories = <String, StoryModel?>{
        for (var id in needed) id: null
      };
      if (mounted) {
        state = state.copyWith(stories: {...state.stories, ...errorStories});
      }
    }
  }
}

final batchMediaProvider =
    StateNotifierProvider<BatchMediaNotifier, BatchMediaState>((ref) {
      return BatchMediaNotifier(ref.watch(apiClientProvider));
    });
