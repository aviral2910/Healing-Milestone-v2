import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUserData(String uid);
  Stream<UserModel?> getUserStream(String uid);
  Future<void> createUserData(UserModel user);
  Future<void> updateUserData(UserModel user);
  Future<List<UserModel>> getSuggestedUsers();
  Future<bool> isUsernameAvailable(String username);
  Future<List<UserModel>> searchUsers(String query);
  Future<List<UserModel>> getUsersByIds(List<String> uids);
  Future<void> toggleFollow(String currentUserId, String targetUserId);
  Future<void> toggleBookmark(String userId, String storyId);
  Future<void> deleteUserData();
  Future<List<UserModel>> getFollowers(String uid, {int skip = 0, int limit = 20});
  Future<List<UserModel>> getFollowing(String uid, {int skip = 0, int limit = 20});
}