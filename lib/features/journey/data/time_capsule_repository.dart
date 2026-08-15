import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/models/time_capsule_model.dart';
import 'package:healing_milestones/core/network/api_client.dart';

final timeCapsuleRepositoryProvider = Provider<TimeCapsuleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TimeCapsuleRepository(apiClient);
});

class TimeCapsuleRepository {
  final ApiClient _apiClient;

  TimeCapsuleRepository(this._apiClient);

  Dio get _dio => _apiClient.dio;

  Future<TimeCapsuleModel> createTimeCapsule({
    required String content,
    required DateTime unlockDate,
  }) async {
    final response = await _dio.post(
      '/api/time-capsules/',
      data: {
        'content': content,
        'unlockDate': unlockDate.toUtc().toIso8601String(),
      },
    );
    return TimeCapsuleModel.fromJson(response.data);
  }

  Future<List<TimeCapsuleModel>> getMyTimeCapsules() async {
    final response = await _dio.get('/api/time-capsules/me');
    final data = response.data as List;
    return data.map((json) => TimeCapsuleModel.fromJson(json)).toList();
  }

  Future<TimeCapsuleModel> openTimeCapsule(String capsuleId) async {
    final response = await _dio.put('/api/time-capsules/$capsuleId/open');
    return TimeCapsuleModel.fromJson(response.data);
  }
}
