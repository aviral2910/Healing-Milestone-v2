import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/repositories/auth_repository.dart';
import '../../../core/repositories/user_repository.dart';
import 'firebase_auth_repository.dart';
import 'api_user_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    firebaseAuth: FirebaseAuth.instance,
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return ref.watch(apiUserRepositoryProvider);
});
