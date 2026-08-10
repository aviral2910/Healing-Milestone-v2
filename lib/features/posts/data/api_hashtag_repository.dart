import 'package:dio/dio.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiHashtagRepositoryProvider = Provider<ApiHashtagRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiHashtagRepository(apiClient);
});

class ApiHashtagRepository {
  final ApiClient _apiClient;
  
  ApiHashtagRepository(this._apiClient);
  
  Dio get _dio => _apiClient.dio;

  Future<List<String>> getTrendingHashtags({int limit = 50}) async {
    try {
      final response = await _dio.get('/api/tags/trending?limit=$limit');
      return List<String>.from(response.data['items'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> searchHashtags(String query) async {
    try {
      final response = await _dio.get('/api/tags/search?q=$query');
      return List<String>.from(response.data['items'] ?? []);
    } catch (e) {
      return [];
    }
  }
}
