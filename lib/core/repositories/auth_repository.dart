class AuthUser {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;

  const AuthUser({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
  });
}

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  
  Future<AuthUser?> signInWithGoogle();
  
  Future<void> signOut();
  
  AuthUser? get currentUser;
  
  // Phone Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(Exception e) verificationFailed,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  });

  Future<AuthUser?> signInWithPhoneCredential(String verificationId, String smsCode);
  
  // Account Linking
  Future<AuthUser?> linkPhoneCredential(String verificationId, String smsCode);
  Future<AuthUser?> linkGoogleCredential();
  
  // Re-authentication
  Future<void> reauthenticateWithGoogle();
  Future<void> reauthenticateWithPhoneCredential(String verificationId, String smsCode);
  
  Future<void> deleteAccount();
}
