import 'package:dio/dio.dart';
import 'package:healing_milestones/core/models/user_model.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import 'package:healing_milestones/core/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiUserRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiUserRepository(apiClient);
});

class ApiUserRepository implements UserRepository {
  final ApiClient _apiClient;

  ApiUserRepository(this._apiClient);

  Dio get _dio => _apiClient.dio;

  @override
  Future<UserModel?> getUserData(String uid) async {
    try {
      final response = await _dio.get('/api/users/$uid');
      return UserModel.fromMap(response.data);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserModel?> getUserStream(String uid) async* {
    yield await getUserData(uid);
  }

  @override
  Future<void> createUserData(UserModel user) async {
    // In our new architecture, the backend automatically creates the user 
    // the first time they make an authenticated request.
  }

  @override
  Future<void> updateUserData(UserModel user) async {
    try {
      // For updates, we hit the /api/auth/me endpoint
      await _dio.patch('/api/auth/me', data: user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _dio.get('/api/users/check-username?username=$username');
      return response.data['is_available'] ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _dio.get('/api/users/search?q=$query');
      final items = response.data['items'] as List;
      return items.map((json) => UserModel.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<UserModel>> getUsersByIds(List<String> uids) async {
    // Can be optimized into a single batch endpoint later
    return []; 
  }

  @override
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await _dio.post('/api/users/$targetUserId/follow');
    } catch (e) {
      print('Error following user: $e');
    }
  }

  @override
  Future<void> toggleBookmark(String userId, String storyId) async {
    try {
      await _dio.post('/api/stories/$storyId/bookmark');
    } catch (e) {
      print('Error bookmarking story: $e');
    }
  }
}
