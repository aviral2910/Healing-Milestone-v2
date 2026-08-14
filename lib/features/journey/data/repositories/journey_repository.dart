import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/journey_models.dart';

class JourneyRepository {
  final ApiClient _apiClient;

  JourneyRepository(this._apiClient);

  Future<List<JourneyModel>> getJourneys() async {
    try {
      final response = await _apiClient.dio.get('/api/journeys/');
      final data = response.data as List;
      return data.map((json) => JourneyModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load journeys: $e');
    }
  }

  Future<JourneyModel> createJourney(String title, String category, MilestoneVisibility visibility) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/journeys/',
        data: {
          'title': title,
          'category': category,
          'visibility': visibility.name,
        },
      );
      return JourneyModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create journey: $e');
    }
  }

  Future<JourneyModel> updateJourney(String id, String title, String category, MilestoneVisibility visibility) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/journeys/$id',
        data: {
          'title': title,
          'category': category,
          'visibility': visibility.name,
        },
      );
      return JourneyModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update journey: $e');
    }
  }

  Future<void> deleteJourney(String id) async {
    try {
      await _apiClient.dio.delete('/api/journeys/$id');
    } catch (e) {
      throw Exception('Failed to delete journey: $e');
    }
  }

  Future<List<JourneyModel>> getFollowingJourneys() async {
    try {
      final response = await _apiClient.dio.get('/api/journeys/following');
      final data = response.data as List;
      return data.map((json) => JourneyModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load following journeys: $e');
    }
  }

  Future<void> followJourney(String journeyId) async {
    try {
      await _apiClient.dio.post('/api/journeys/$journeyId/follow');
    } catch (e) {
      throw Exception('Failed to follow journey: $e');
    }
  }

  Future<void> unfollowJourney(String journeyId) async {
    try {
      await _apiClient.dio.delete('/api/journeys/$journeyId/follow');
    } catch (e) {
      throw Exception('Failed to unfollow journey: $e');
    }
  }

  Future<List<JourneyMilestoneModel>> getMilestones({
    String? journeyId,
    bool isFloating = false,
    bool isPublic = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (journeyId != null) {
        queryParams['journey_id'] = journeyId;
      }
      if (isFloating) {
        queryParams['is_floating'] = true;
      }
      if (isPublic) {
        queryParams['is_public'] = true;
      }
      
      final response = await _apiClient.dio.get(
        '/api/milestones/',
        queryParameters: queryParams,
      );
      final data = response.data as List;
      return data.map((json) => JourneyMilestoneModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load milestones: $e');
    }
  }

  Future<List<JourneyMilestoneModel>> getPublicMilestones() async {
    try {
      final response = await _apiClient.dio.get(
        '/api/milestones/',
        queryParameters: {
          'is_public': true,
        },
      );
      final data = response.data as List;
      return data.map((json) => JourneyMilestoneModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load public feed: $e');
    }
  }

  Future<JourneyMilestoneModel> createMilestone({
    String? journeyId,
    required EmotionStatus emotionStatus,
    String? content,
    MilestoneVisibility visibility = MilestoneVisibility.public,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/milestones/',
        data: {
          'journey_id': journeyId,
          'emotion_status': emotionStatus.name,
          'content': content,
          'visibility': visibility.name,
        },
      );
      return JourneyMilestoneModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to log milestone: $e');
    }
  }

  Future<JourneyMilestoneModel> updateMilestone({
    required String milestoneId,
    required EmotionStatus emotionStatus,
    String? content,
    MilestoneVisibility? visibility,
  }) async {
    try {
      final data = <String, dynamic>{
        'emotion_status': emotionStatus.name,
        'content': content,
      };
      if (visibility != null) {
        data['visibility'] = visibility.name;
      }
      
      final response = await _apiClient.dio.put(
        '/api/milestones/$milestoneId',
        data: data,
      );
      return JourneyMilestoneModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update milestone: $e');
    }
  }

  Future<void> deleteMilestone(String milestoneId) async {
    try {
      await _apiClient.dio.delete('/api/milestones/$milestoneId');
    } catch (e) {
      throw Exception('Failed to delete milestone: $e');
    }
  }

  Future<void> reactToMilestone(String milestoneId, String reactionType) async {
    try {
      await _apiClient.dio.post(
        '/api/milestones/$milestoneId/react',
        queryParameters: {'reaction_type': reactionType},
      );
    } catch (e) {
      throw Exception('Failed to react to milestone: $e');
    }
  }

  Future<void> removeReaction(String milestoneId) async {
    try {
      await _apiClient.dio.delete('/api/milestones/$milestoneId/react');
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }
}
