import re

with open("lib/core/repositories/auth_repository.dart", "r") as f:
    content = f.read()

replacement = """  // Re-authentication
  Future<void> reauthenticateWithGoogle();
  Future<void> reauthenticateWithPhoneCredential(String verificationId, String smsCode);
  
  Future<void> deleteAccount();"""
content = content.replace("  Future<void> deleteAccount();", replacement)

with open("lib/core/repositories/auth_repository.dart", "w") as f:
    f.write(content)


with open("lib/features/auth/data/firebase_auth_repository.dart", "r") as f:
    content = f.read()

replacement2 = """  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  @override
  Future<void> reauthenticateWithGoogle() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception("No user is currently signed in.");
      
      if (!_isGoogleSignInInitialized) {
        await GoogleSignIn.instance.initialize(
          serverClientId: '507010116072-ut55mclmnas5jki5jnb1851tjmvcr4tp.apps.googleusercontent.com',
        );
        _isGoogleSignInInitialized = true;
      }
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) throw Exception("Google sign in cancelled.");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final GoogleSignInClientAuthorization? authz = 
          await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz?.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> reauthenticateWithPhoneCredential(String verificationId, String smsCode) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception("No user is currently signed in.");
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }
}"""

content = re.sub(r'  @override\n  Future<void> deleteAccount\(\) async \{[\s\S]*?\}', replacement2, content)

with open("lib/features/auth/data/firebase_auth_repository.dart", "w") as f:
    f.write(content)
