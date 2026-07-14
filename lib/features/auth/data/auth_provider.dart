import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/models/user_model.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/repositories/user_repository.dart';
import 'repository_providers.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  needsOnboarding,
  authenticated,
}

class AuthState {
  final AuthStatus status;
  final AuthUser? authUser;
  final UserModel? userModel;
  final String? verificationId;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authUser,
    this.userModel,
    this.verificationId,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? authUser,
    UserModel? userModel,
    String? verificationId,
  }) {
    return AuthState(
      status: status ?? this.status,
      authUser: authUser ?? this.authUser,
      userModel: userModel ?? this.userModel,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthNotifier(this._authRepository, this._userRepository) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _authRepository.authStateChanges.listen((AuthUser? user) async {
      if (user == null) {
        state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
      } else {
        try {
          final userModel = await _userRepository.getUserData(user.uid);
          if (userModel == null) {
            state = AsyncData(AuthState(
              status: AuthStatus.needsOnboarding,
              authUser: user,
            ));
          } else {
            state = AsyncData(AuthState(
              status: AuthStatus.authenticated,
              authUser: user,
              userModel: userModel,
            ));
          }
        } catch (e, st) {
          state = AsyncError(e, st);
        }
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user == null) {
        // User canceled sign-in
        state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
      }
      // The authStateChanges listener will handle the rest if user != null
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signOut();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> completeOnboarding(UserModel userModel) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.createUserData(userModel);
      final currentUser = _authRepository.currentUser;
      state = AsyncData(AuthState(
        status: AuthStatus.authenticated,
        authUser: currentUser,
        userModel: userModel,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber, {required Function() onCodeSent}) async {
    try {
      await _authRepository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (String verificationId, int? resendToken) {
          if (state.value != null) {
            state = AsyncData(state.value!.copyWith(verificationId: verificationId));
            onCodeSent();
          }
        },
        verificationFailed: (Exception e) {
          state = AsyncError(e, StackTrace.current);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (state.value != null) {
            state = AsyncData(state.value!.copyWith(verificationId: verificationId));
          }
        },
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    state = const AsyncValue.loading();
    try {
      final verificationId = state.valueOrNull?.verificationId;
      if (verificationId == null) {
        throw Exception("Verification ID not found. Please try sending OTP again.");
      }
      
      await _authRepository.signInWithPhoneCredential(verificationId, smsCode);
      // The authStateChanges listener will handle the rest
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> linkPhoneNumber(String smsCode) async {
    state = const AsyncValue.loading();
    try {
      final verificationId = state.valueOrNull?.verificationId;
      if (verificationId == null) {
        throw Exception("Verification ID not found. Please try sending OTP again.");
      }
      
      await _authRepository.linkPhoneCredential(verificationId, smsCode);
      // state remains authenticated, but we might want to refresh AuthUser
      final user = _authRepository.currentUser;
      if (user != null && state.value != null) {
         state = AsyncData(state.value!.copyWith(authUser: user));
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthNotifier(authRepository, userRepository);
});

// A convenient provider just to get the authenticated UserModel
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider).valueOrNull;
  if (authState?.status == AuthStatus.authenticated) {
    return authState?.userModel;
  }
  return null;
});
