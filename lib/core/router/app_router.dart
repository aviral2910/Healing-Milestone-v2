import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/public_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/user_list_screen.dart';
import '../../features/milestone/presentation/screens/post_creation_screen.dart';
import '../../features/milestone/presentation/screens/story_detail_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/professional_onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_auth_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/data/auth_provider.dart';
import '../../core/models/user_model.dart';

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
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authProvider).valueOrNull;
      final isAuth = authState?.status == AuthStatus.authenticated;
      final needsOnboarding = authState?.status == AuthStatus.needsOnboarding;
      
      final isGoingToOnboarding = state.matchedLocation == '/role-selection' || state.matchedLocation == '/professional-onboarding';
      
      // Protected routes
      final isProtectedRoute = state.matchedLocation == '/create' || 
                               state.matchedLocation == '/profile' ||
                               state.matchedLocation == '/edit-profile';

      if (authState?.status == AuthStatus.unauthenticated && isGoingToOnboarding) {
        return '/login';
      }

      if (needsOnboarding && !isGoingToOnboarding) {
        return '/role-selection';
      }

      if (!isAuth && isProtectedRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/phone-auth',
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const PostCreationScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/professional-onboarding',
        builder: (context, state) {
          final role = state.extra as UserRole;
          return ProfessionalOnboardingScreen(role: role);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PublicProfileScreen(userId: id);
        },
      ),
      GoRoute(
        path: '/user-list',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final title = extra?['title'] as String? ?? 'Users';
          final userIds = extra?['userIds'] as List<String>? ?? [];
          return UserListScreen(title: title, userIds: userIds);
        },
      ),
      GoRoute(
        path: '/story/:id',
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
