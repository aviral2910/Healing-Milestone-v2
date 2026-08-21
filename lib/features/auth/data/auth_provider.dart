import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../../main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healing_milestones/core/models/user_model.dart';
import 'package:healing_milestones/core/network/api_client.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/repositories/user_repository.dart';
import 'repository_providers.dart';

enum AuthStatus { initial, unauthenticated, needsOnboarding, authenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? authUser;
  final UserModel? userModel;
  final String? verificationId;
  final String? linkingPhoneNumber;

  const AuthState({
    this.status = AuthStatus.initial,
    this.authUser,
    this.userModel,
    this.verificationId,
    this.linkingPhoneNumber,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? authUser,
    UserModel? userModel,
    String? verificationId,
    String? linkingPhoneNumber,
  }) {
    return AuthState(
      status: status ?? this.status,
      authUser: authUser ?? this.authUser,
      userModel: userModel ?? this.userModel,
      verificationId: verificationId ?? this.verificationId,
      linkingPhoneNumber: linkingPhoneNumber ?? this.linkingPhoneNumber,
    );
  }
}

class AuthNotifier extends Notifier<AsyncValue<AuthState>> {
  late AuthRepository _authRepository;
  late UserRepository _userRepository;

  @override
  AsyncValue<AuthState> build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _userRepository = ref.watch(userRepositoryProvider);
    // Use Future.microtask or similar if _init modifies state synchronously?
    // Actually, _init just sets up a listener, which is fine to call in build.
    _init();
    return const AsyncValue.loading();
  }

  void _init() {
    _authRepository.authStateChanges.listen((AuthUser? user) async {
      if (user == null) {
        state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
      } else {
        await _handleUserAuthenticated(user);
      }
    });
  }

  Future<void> _handleUserAuthenticated(AuthUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUserStr = prefs.getString('cached_user_model_${user.uid}');
      if (cachedUserStr != null) {
        try {
          final cachedUserModel = UserModel.fromMap(jsonDecode(cachedUserStr));
          state = AsyncData(
            AuthState(
              status: AuthStatus.authenticated,
              authUser: user,
              userModel: cachedUserModel,
            ),
          );
        } catch (e) {
          print('Failed to parse cached user: $e');
        }
      }

      final userModel = await _userRepository.getUserData(user.uid);
      if (userModel == null) {
        state = AsyncData(
          AuthState(status: AuthStatus.needsOnboarding, authUser: user),
        );
      } else {
        await prefs.setString('cached_user_model_${user.uid}', jsonEncode(userModel.toMap()));
        state = AsyncData(
          AuthState(
            status: AuthStatus.authenticated,
            authUser: user,
            userModel: userModel,
          ),
        );
      }
    } catch (e, st) {
      if (state.value?.userModel == null) {
        state = AsyncError(e, st);
      } else {
        print('Background fetch failed, keeping cached user data.');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user == null) {
        // User canceled sign-in
        state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
      } else {
        await _handleUserAuthenticated(user);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    final currentState = state.value;
    try {
      if (currentState?.authUser?.uid != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('cached_user_model_${currentState!.authUser!.uid}');
      }
      state = const AsyncValue.loading();
      await _authRepository.signOut();
      // Note: We don't manually set the state to unauthenticated here.
      // The _authRepository.authStateChanges listener will automatically
      // detect the sign-out and update the state safely.
    } catch (e, st) {
      // Revert to the previous authenticated state if sign-out fails
      if (currentState != null) {
        state = AsyncData(currentState);
      } else {
        state = AsyncError(e, st);
      }
      rethrow; // Rethrow so the UI can catch it (e.g., to show a Snackbar)
    }
  }

  Future<void> completeOnboarding(UserModel userModel) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.createUserData(userModel);
      final currentUser = _authRepository.currentUser;
      state = AsyncData(
        AuthState(
          status: AuthStatus.authenticated,
          authUser: currentUser,
          userModel: userModel,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    required Function() onCodeSent,
  }) async {
    try {
      await _authRepository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (String verificationId, int? resendToken) {
          final currentState = state.value;
          if (currentState != null) {
            state = AsyncData(
              (state.value ?? const AuthState()).copyWith(
                verificationId: verificationId,
                linkingPhoneNumber: phoneNumber,
              ),
            );
            onCodeSent();
          }
        },
        verificationFailed: (Exception e) {
          state = AsyncError(e, StackTrace.current);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          final currentState = state.value;
          if (currentState != null) {
            state = AsyncData(
              (state.value ?? const AuthState()).copyWith(
                verificationId: verificationId,
                linkingPhoneNumber: phoneNumber,
              ),
            );
          }
        },
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    final verificationId = state.value?.verificationId;
    if (verificationId == null) {
      state = AsyncError(
        Exception("Verification ID not found. Please try sending OTP again."),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      await _authRepository.signInWithPhoneCredential(verificationId, smsCode);
      // The authStateChanges listener will handle the rest
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> linkPhoneNumber(String smsCode) async {
    final currentState = state.value;
    final verificationId = currentState?.verificationId;
    if (verificationId == null) {
      state = AsyncError(
        Exception("Verification ID not found. Please try sending OTP again."),
        StackTrace.current,
      );
      return;
    }

    try {
      final user = await _authRepository.linkPhoneCredential(
        verificationId,
        smsCode,
      );
      if (user != null && currentState != null) {
        var updatedUserModel = currentState.userModel;

        final phoneToSave = user.phoneNumber ?? currentState.linkingPhoneNumber;

        if (phoneToSave != null &&
            phoneToSave.isNotEmpty &&
            updatedUserModel != null) {
          updatedUserModel = updatedUserModel.copyWith(
            phoneNumber: phoneToSave,
          );
          await _userRepository.updateUserData(updatedUserModel);
        }

        state = AsyncData(
          (state.value ?? const AuthState()).copyWith(
            authUser: user,
            userModel: updatedUserModel,
            linkingPhoneNumber: null, // clear it
          ),
        );
      }
    } catch (e) {
      if (currentState != null) {
        state = AsyncData(currentState); // Restore state so we don't log out
      }
      rethrow;
    }
  }

  Future<void> linkGoogleAccount() async {
    final currentState = state.value;
    try {
      final user = await _authRepository.linkGoogleCredential();
      if (user != null && currentState != null) {
        var updatedUserModel = currentState.userModel;
        if (user.email != null && updatedUserModel != null) {
          updatedUserModel = updatedUserModel.copyWith(email: user.email);
          await _userRepository.updateUserData(updatedUserModel);
        }
        state = AsyncData(
          (state.value ?? const AuthState()).copyWith(authUser: user, userModel: updatedUserModel),
        );
      }
    } catch (e) {
      print('Link Google Account Error: $e');
      if (currentState != null) {
        state = AsyncData(currentState); // Restore state so we don't log out
      }
      rethrow; // So the UI can catch and show a snackbar
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    final currentState = state.value;
    try {
      await _userRepository.updateUserData(updatedUser);
      if (currentState != null) {
        state = AsyncData((state.value ?? const AuthState()).copyWith(userModel: updatedUser));
      }
      // Force UI components listening to these streams to fetch the latest data from the API
      ref.invalidate(userStreamProvider(updatedUser.userId));
      ref.invalidate(userByIdProvider(updatedUser.userId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshUser() async {
    final currentState = state.value;
    final currentUser = currentState?.authUser;
    if (currentUser == null) return;

    try {
      final userModel = await _userRepository.getUserData(currentUser.uid);
      if (userModel != null && currentState != null) {
        state = AsyncData((state.value ?? const AuthState()).copyWith(userModel: userModel));
      }
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  Future<void> toggleFollow(String targetUserId) async {
    final currentState = state.value;
    final userModel = currentState?.userModel;
    if (userModel == null) return;

    try {
      // Actually perform the network request
      await _userRepository.toggleFollow(userModel.userId, targetUserId);

      // Invalidate target user so it refreshes in the background
      ref.invalidate(userStreamProvider(targetUserId));
      ref.invalidate(userByIdProvider(targetUserId));

      // AWAIT the refresh of the current user so the spinner stays active until fresh data arrives
      await ref.refresh(userStreamProvider(userModel.userId).future);
      ref.invalidate(userByIdProvider(userModel.userId));
    } catch (e) {
      // Revert on error
      if (currentState != null) {
        state = AsyncData(currentState);
      }
      print('Error toggling follow: $e');
    }
  }

  Future<void> applyForVerification() async {
    final currentUser = state.value?.userModel;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(appliedForVerification: true);
    await updateProfile(updatedUser);
  }

  Future<bool> isUsernameAvailable(String username) async {
    try {
      return await _userRepository.isUsernameAvailable(username);
    } catch (e) {
      print('Check username available error: $e');
      return false; // Assume unavailable on error
    }
  }

  Future<void> reauthenticateWithGoogle() async {
    try {
      await _authRepository.reauthenticateWithGoogle();
    } catch (e) {
      print('Reauthenticate Google error: $e');
      rethrow;
    }
  }

  Future<void> reauthenticateWithPhoneCredential(String smsCode) async {
    try {
      final verificationId = state.value?.verificationId;
      if (verificationId == null) {
        throw Exception("Verification ID is missing.");
      }
      await _authRepository.reauthenticateWithPhoneCredential(verificationId, smsCode);
      
      // Clear verification id
      state = AsyncValue.data(
        (state.value ?? const AuthState()).copyWith(
          verificationId: null,
          linkingPhoneNumber: null,
        ),
      );
    } catch (e) {
      print('Reauthenticate Phone error: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    final currentState = state.value;
    try {
      if (currentState?.authUser?.uid != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('cached_user_model_${currentState!.authUser!.uid}');
      }
      state = const AsyncValue.loading();

      // 1. Delete user from the backend database (PostgreSQL)
      await _userRepository.deleteUserData();

      // 2. Delete user from Firebase Authentication
      await _authRepository.deleteAccount();

      // The authStateChanges listener will handle transition to unauthenticated automatically.
    } catch (e, st) {
      if (currentState != null) {
        state = AsyncData(currentState);
      } else {
        state = AsyncError(e, st);
      }
      rethrow;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<AuthState>>(() {
  return AuthNotifier();
});

final userStreamProvider = StreamProvider.autoDispose.family<UserModel?, String>((
  ref,
  userId,
) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserStream(userId);
});

// A convenient provider just to get the authenticated UserModel
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider).value;
  if (authState?.status == AuthStatus.authenticated &&
      authState?.authUser != null) {
    // Watch the real-time stream of the user's data
    final userStream = ref.watch(userStreamProvider(authState!.authUser!.uid));
    return userStream.value ?? authState.userModel;
  }
  return null;
});

// A provider to fetch any user's profile by ID
final userByIdProvider = userStreamProvider;

// A provider to fetch a list of users by their IDs
final getUsersByIdsProvider =
    FutureProvider.autoDispose.family<List<UserModel>, List<String>>((ref, userIds) {
      final userRepository = ref.watch(userRepositoryProvider);
      return userRepository.getUsersByIds(userIds);
    });

final isFollowingProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  targetUid,
) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.dio.get(
      '/api/users/$targetUid/is-following',
    );
    return response.data['isFollowing'] ?? false;
  } catch (e) {
    return false;
  }
});
