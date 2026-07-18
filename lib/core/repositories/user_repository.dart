import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUserData(String uid);
  Future<void> createUserData(UserModel user);
  Future<void> updateUserData(UserModel user);
  Future<bool> isUsernameAvailable(String username);
}
