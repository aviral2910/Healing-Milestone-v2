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

  final Map<String, Future<UserModel?>> _inFlightUserRequests = {};
  final Map<String, UserModel> _userCache = {};
  final Map<String, DateTime> _userCacheTime = {};

  @override
  Future<UserModel?> getUserData(String uid) {
    // 1. Return if request is already in-flight
    if (_inFlightUserRequests.containsKey(uid)) {
      return _inFlightUserRequests[uid]!;
    }
    
    // 2. Return if we have a fresh cache (less than 2 minutes old)
    if (_userCache.containsKey(uid)) {
      final cacheAge = DateTime.now().difference(_userCacheTime[uid]!);
      if (cacheAge.inMinutes < 2) {
        return Future.value(_userCache[uid]);
      }
    }

    final future = _fetchUserData(uid).then((user) {
      if (user != null) {
        _userCache[uid] = user;
        _userCacheTime[uid] = DateTime.now();
      }
      return user;
    }).whenComplete(() {
      _inFlightUserRequests.remove(uid);
    });

    _inFlightUserRequests[uid] = future;
    return future;
  }

  Future<UserModel?> _fetchUserData(String uid) async {
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
    // However, the profile setup screen sets initial data like username, 
    // so we need to PATCH that data to the backend.
    await updateUserData(user);
  }

  @override
  Future<void> updateUserData(UserModel user) async {
    try {
      // For updates, we hit the /api/auth/me endpoint
      await _dio.patch('/api/auth/me', data: user.toMap());
      _userCache[user.userId] = user;
      _userCacheTime[user.userId] = DateTime.now();
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  @override
  
  Future<List<UserModel>> getSuggestedUsers() async {
    try {
      final response = await _dio.get('/api/users/suggested');
      final items = response.data['items'] as List;
      return items.map((e) => UserModel.fromMap(e)).toList();
    } catch (e) {
      print('Error getting suggested users: $e');
      return [];
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
    if (uids.isEmpty) return [];
    
    // For now, fetch users individually in parallel. 
    // Can be optimized into a single batch endpoint later if needed.
    final futures = uids.map((uid) => getUserData(uid));
    final users = await Future.wait(futures);
    
    // Filter out any nulls if a user wasn't found
    return users.whereType<UserModel>().toList();
  }

  @override
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await _dio.post('/api/users/$targetUserId/follow');
      _userCache.remove(currentUserId);
      _userCache.remove(targetUserId);
    } catch (e) {
      print('Error following user: $e');
    }
  }

  @override
  Future<void> toggleBookmark(String userId, String storyId) async {
    try {
      await _dio.post('/api/stories/$storyId/bookmarks');
    } catch (e) {
      print('Error bookmarking story: $e');
    }
  }

  @override
  Future<void> deleteUserData() async {
    try {
      await _dio.delete('/api/auth/me');
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }
  @override
  Future<List<UserModel>> getFollowers(String uid, {int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get('/api/users/$uid/followers', queryParameters: {'skip': skip, 'limit': limit});
      final items = response.data['items'] as List;
      return items.map((e) => UserModel.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching followers: $e');
      return [];
    }
  }

  @override
  Future<List<UserModel>> getFollowing(String uid, {int skip = 0, int limit = 20}) async {
    try {
      final response = await _dio.get('/api/users/$uid/following', queryParameters: {'skip': skip, 'limit': limit});
      final items = response.data['items'] as List;
      return items.map((e) => UserModel.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching following: $e');
      return [];
    }
  }
}