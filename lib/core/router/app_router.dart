import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/public_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/user_list_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/theme_selection_screen.dart';
import '../../features/uat/presentation/screens/uat_screen.dart';
import '../../features/milestone/presentation/screens/post_creation_screen.dart';
import '../../features/milestone/presentation/screens/story_detail_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/professional_onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_auth_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/data/auth_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/story_model.dart';
import 'app_routes.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      final prevStatus = previous?.valueOrNull?.status;
      final nextStatus = next.valueOrNull?.status;
      if (prevStatus != nextStatus) {
        notifyListeners();
      }
    });
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final authState = ref.read(authProvider).valueOrNull;
      final isAuth = authState?.status == AuthStatus.authenticated;
      final needsOnboarding = authState?.status == AuthStatus.needsOnboarding;
      
      final isGoingToOnboarding = state.matchedLocation == AppRoutes.roleSelection || state.matchedLocation == AppRoutes.professionalOnboarding;
      
      // Protected routes
      final isProtectedRoute = state.matchedLocation == AppRoutes.create || 
                               state.matchedLocation == AppRoutes.profile ||
                               state.matchedLocation == AppRoutes.editProfile;

      if (authState?.status == AuthStatus.unauthenticated && isGoingToOnboarding) {
        return AppRoutes.login;
      }

      if (needsOnboarding && !isGoingToOnboarding) {
        return AppRoutes.roleSelection;
      }

      if (!isAuth && isProtectedRoute) {
        return AppRoutes.login;
      }

      final isAuthScreen = state.matchedLocation == AppRoutes.login ||
                           state.matchedLocation == AppRoutes.phoneAuth ||
                           state.matchedLocation == AppRoutes.verifyOtp;

      if (isAuth && isAuthScreen) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneAuth,
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.create,
        builder: (context, state) {
          final existingStory = state.extra as StoryModel?;
          return PostCreationScreen(existingStory: existingStory);
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.professionalOnboarding,
        builder: (context, state) {
          final role = state.extra as UserRole;
          return ProfessionalOnboardingScreen(role: role);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.uat,
        builder: (context, state) => const UatScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) {
          final contextType = state.extra as MenuContext? ?? MenuContext.home;
          return SettingsScreen(menuContext: contextType);
        },
      ),
      GoRoute(
        path: AppRoutes.themeSelection,
        builder: (context, state) => const ThemeSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.publicProfilePath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PublicProfileScreen(userId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.userList,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final title = extra?['title'] as String? ?? 'Users';
          final userIds = extra?['userIds'] as List<String>? ?? [];
          return UserListScreen(title: title, userIds: userIds);
        },
      ),
      GoRoute(
        path: AppRoutes.storyDetailPath,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: StoryDetailScreen(milestoneId: id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;

              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          );
        },
      ),
    ],
  );
});
