import re

with open("lib/features/search/data/api_search_repository.dart", "r") as f:
    content = f.read()

new_methods = """
  Future<List<UserModel>> searchPeople(String query, {int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get('/api/search/people?q=$query&skip=$skip&limit=$limit');
      final data = response.data as List<dynamic>;
      return data.map((e) => UserModel.fromMap(e)).toList();
    } catch (e) {
      print('Error in searchPeople: $e');
      return [];
    }
  }

  Future<List<StoryModel>> searchStories(String query, {int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get('/api/search/stories?q=$query&skip=$skip&limit=$limit');
      final data = response.data as List<dynamic>;
      return data.map((e) => _mapApiToStoryModel(e)).toList();
    } catch (e) {
      print('Error in searchStories: $e');
      return [];
    }
  }

  Future<List<JourneyModel>> searchJourneys(String query, {int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get('/api/search/journeys?q=$query&skip=$skip&limit=$limit');
      final data = response.data as List<dynamic>;
      return data.map((e) => JourneyModel.fromJson(e)).toList();
    } catch (e) {
      print('Error in searchJourneys: $e');
      return [];
    }
  }

  StoryModel _mapApiToStoryModel(Map<String, dynamic> json) {"""

content = content.replace("  StoryModel _mapApiToStoryModel(Map<String, dynamic> json) {", new_methods)

with open("lib/features/search/data/api_search_repository.dart", "w") as f:
    f.write(content)
