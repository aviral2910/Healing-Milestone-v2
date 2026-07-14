import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUserData(String uid);
  Future<void> createUserData(UserModel user);
}
