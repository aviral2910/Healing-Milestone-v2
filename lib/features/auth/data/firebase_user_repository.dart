import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      try {
        return UserModel.fromMap(doc.data()!);
      } catch (e) {
        print("Error parsing user data: $e");
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> createUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.userId).set(user.toMap());
  }
}
