import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/story_model.dart';
import '../../../core/models/global_search_result.dart';

final apiSearchRepositoryProvider = Provider<ApiSearchRepository>((ref) {
  return ApiSearchRepository(apiClient: ref.watch(apiClientProvider));
});

class ApiSearchRepository {
  final ApiClient _apiClient;

  ApiSearchRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Dio get _dio => _apiClient.dio;

  Future<GlobalSearchResult> globalSearch(String query) async {
    try {
      final response = await _dio.get('/api/search/global?q=$query');
      final data = response.data;
      
      final people = (data['people'] as List<dynamic>?)
          ?.map((e) => UserModel.fromMap(e))
          .toList() ?? [];
          
      final tags = (data['tags'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [];
          
      final stories = (data['stories'] as List<dynamic>?)
          ?.map((e) => _mapApiToStoryModel(e))
          .toList() ?? [];

      return GlobalSearchResult(
        people: people,
        tags: tags,
        stories: stories,
      );
    } catch (e) {
      print('Error in global search: $e');
      return GlobalSearchResult(people: [], tags: [], stories: []);
    }
  }

  StoryModel _mapApiToStoryModel(Map<String, dynamic> json) {
    return StoryModel(
      storyId: json['id'] ?? '',
      heading: json['heading'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      mainImage: json['main_image'] ?? '',
      authorId: json['author_id'] ?? '',
      publishedAt: json['published_at'] != null 
          ? DateTime.parse(json['published_at']) 
          : DateTime.now(),
      qrId: json['qr_id'] ?? '',
      readingTime: json['reading_time'] ?? 5,
      verifierId: json['verifier_id'] ?? '',
      type: StoryType.values.firstWhere((e) => e.name == json['type'], orElse: () => StoryType.story),
      imageAssets: List<String>.from(json['image_assets'] ?? []),
      displayAuthorName: json['display_author_name'] ?? true,
      isHidden: json['is_hidden'] ?? false,
    );
  }
}
