import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  bool _isGoogleSignInInitialized = false;

  FirebaseAuthRepository({
    required FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  AuthUser _mapFirebaseUser(User? user) {
    if (user == null) {
      throw Exception('User is null');
    }
    return AuthUser(
      uid: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) return null;
      return _mapFirebaseUser(user);
    });
  }

  @override
  AuthUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUser(user);
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      if (!_isGoogleSignInInitialized) {
        await GoogleSignIn.instance.initialize(
          serverClientId: '507010116072-ut55mclmnas5jki5jnb1851tjmvcr4tp.apps.googleusercontent.com',
        );
        _isGoogleSignInInitialized = true;
      }
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
          
      final GoogleSignInClientAuthorization? authz = 
          await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz?.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) return null;
      return _mapFirebaseUser(user);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      print('Google Sign-In Error: $e');
      rethrow;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    if (!_isGoogleSignInInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: '507010116072-ut55mclmnas5jki5jnb1851tjmvcr4tp.apps.googleusercontent.com',
      );
      _isGoogleSignInInitialized = true;
    }
    await GoogleSignIn.instance.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(Exception e) verificationFailed,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatically sign in on some devices (Android)
        // For now, we rely on the manual OTP entry to keep the flow consistent,
        // but we could auto-sign-in here if we passed a callback for it.
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        codeAutoRetrievalTimeout(verificationId);
      },
      timeout: const Duration(seconds: 60),
    );
  }

  @override
  Future<AuthUser?> signInWithPhoneCredential(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) return null;
      return _mapFirebaseUser(user);
    } catch (e) {
      print('Phone Sign-In Error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> linkPhoneCredential(String verificationId, String smsCode) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception("No user is currently signed in to link.");

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await user.linkWithCredential(credential);
      return _mapFirebaseUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        throw Exception("This phone number is already linked to another account.");
      }
      rethrow;
    } catch (e) {
      print('Link Phone Error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> linkGoogleCredential() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) throw Exception("No user is currently signed in to link.");

      if (!_isGoogleSignInInitialized) {
        await GoogleSignIn.instance.initialize(
          serverClientId: '507010116072-ut55mclmnas5jki5jnb1851tjmvcr4tp.apps.googleusercontent.com',
        );
        _isGoogleSignInInitialized = true;
      }
      
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final GoogleSignInClientAuthorization? authz = 
          await googleUser.authorizationClient.authorizationForScopes(['email', 'profile']);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz?.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseUser.linkWithCredential(credential);
      return _mapFirebaseUser(userCredential.user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        throw Exception("This Google account is already linked to another account.");
      }
      rethrow;
    } catch (e) {
      print('Link Google Error: $e');
      rethrow;
    }
  }
}
