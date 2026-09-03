import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/journey/presentation/screens/time_capsule_list_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/public_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/user_list_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/legal_webview_screen.dart';
import '../../features/settings/presentation/screens/theme_selection_screen.dart';
import '../../features/settings/presentation/screens/accessibility_settings_screen.dart';
import '../../features/uat/presentation/screens/uat_screen.dart';
import '../../features/milestone/presentation/screens/post_content_screen.dart';
import '../../features/milestone/presentation/screens/post_guided_screen.dart';
import '../../features/milestone/presentation/screens/post_manual_screen.dart';
import '../../features/milestone/presentation/screens/post_settings_screen.dart';
import '../../features/milestone/presentation/screens/story_detail_screen.dart';
import '../../features/milestone/presentation/screens/report_screen.dart';
import '../../features/profile/presentation/screens/drafts_screen.dart';
import '../../features/profile/presentation/screens/admin_submissions_screen.dart';
import '../../features/profile/presentation/screens/admin_submission_detail_screen.dart';
import '../../features/chat/presentation/screens/inbox_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/professional_onboarding_screen.dart';
import '../../features/auth/presentation/screens/phone_auth_screen.dart';
import '../../features/auth/presentation/screens/interest_selection_screen.dart';
import '../../features/auth/presentation/screens/suggested_follows_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/suspended_screen.dart';
import '../../features/auth/data/auth_provider.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../logo/healing_milestone_logo.dart';
import '../../core/models/user_model.dart';
import 'app_routes.dart';
import '../../features/milestone/presentation/widgets/mini_player_overlay.dart';
import 'package:flutter/material.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      final prevStatus = previous?.value?.status;
      final nextStatus = next.value?.status;
      if (prevStatus != nextStatus) {
        notifyListeners();
      }
    });
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));



class CurrentRouteNotifier extends Notifier<String> {
  @override
  String build() => '/';
  void updateRoute(String route) => state = route;
}
final currentRouteProvider = NotifierProvider<CurrentRouteNotifier, String>(CurrentRouteNotifier.new);


class AppRouteObserver extends NavigatorObserver {
  final Ref ref;
  AppRouteObserver(this.ref);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _updateRoute(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _updateRoute(newRoute);
  }

  void _updateRoute(Route<dynamic> route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? location = route.settings.name;
      if (location == null) {
        try {
          final router = ref.read(routerProvider);
          location = router.routerDelegate.currentConfiguration.last.matchedLocation;
        } catch (e) {
          location = 'unknown';
        }
      }
      ref.read(currentRouteProvider.notifier).updateRoute(location);
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {

  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    observers: [AppRouteObserver(ref)],
    refreshListenable: notifier,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      if (state.matchedLocation == AppRoutes.splash || state.matchedLocation == AppRoutes.ascensionTransition) {
        return null;
      }

      final authState = ref.read(authProvider).value;
      final isAuth = authState?.status == AuthStatus.authenticated;
      final needsOnboarding = authState?.status == AuthStatus.needsOnboarding;

      final isGoingToOnboarding =
          state.matchedLocation == AppRoutes.roleSelection ||
              state.matchedLocation == AppRoutes.professionalOnboarding;

      final userStatus = authState?.userModel?.status;
      final isBanned = userStatus == 'banned' || userStatus == 'suspended';

      if (isBanned && state.matchedLocation != AppRoutes.suspended) {
        return AppRoutes.suspended;
      }
      
      if (!isBanned && state.matchedLocation == AppRoutes.suspended) {
        return AppRoutes.splash;
      }

      // Protected routes
      final isProtectedRoute = state.matchedLocation == AppRoutes.create ||
          state.matchedLocation == AppRoutes.timeCapsulesVault ||
          state.matchedLocation == AppRoutes.createPostGuided ||
          state.matchedLocation == AppRoutes.createPostManual ||
          state.matchedLocation == AppRoutes.createPostSettings ||
          state.matchedLocation == AppRoutes.profile ||
          state.matchedLocation == AppRoutes.editProfile;

      if (authState?.status == AuthStatus.unauthenticated &&
          isGoingToOnboarding) {
        return AppRoutes.login;
      }

      if (needsOnboarding && !isGoingToOnboarding) {
        return AppRoutes.roleSelection;
      }

      final needsInterests = isAuth && (authState?.userModel?.interests.isEmpty ?? false);
      final isGoingToInterests = state.matchedLocation == AppRoutes.interestSelection || 
                                 state.matchedLocation == AppRoutes.suggestedFollows;

      if (needsInterests && !isGoingToInterests && !isGoingToOnboarding) {
        return AppRoutes.interestSelection;
      }

      if (!isAuth && isProtectedRoute) {
        return AppRoutes.login;
      }

      final isAuthScreen = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.phoneAuth ||
          state.matchedLocation == AppRoutes.verifyOtp;

      if (isAuth && isAuthScreen) {
        return AppRoutes.ascensionTransition;
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Stack(
            children: [
              child,
              const MiniPlayerOverlay(),
            ],
          );
        },
        routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.suspended,
        builder: (context, state) => const SuspendedScreen(),
      ),
      GoRoute(
        path: AppRoutes.ascensionTransition,
        builder: (context, state) => const AscensionOverlayScreen(isTransitionMode: true),
      ),
      GoRoute(
        path: AppRoutes.timeCapsulesVault,
        builder: (context, state) => const TimeCapsuleListScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) {
          final q = state.uri.queryParameters['q'];
          return SearchScreen(initialQuery: q);
        },
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
        path: AppRoutes.interestSelection,
        builder: (context, state) => const InterestSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.suggestedFollows,
        builder: (context, state) => const SuggestedFollowsScreen(),
      ),
      GoRoute(
        path: AppRoutes.create,
        builder: (context, state) => const PostContentScreen(),
      ),
      GoRoute(
        path: AppRoutes.createPostGuided,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return PostGuidedScreen(prefillData: data);
        },
      ),
      GoRoute(
        path: AppRoutes.createPostManual,
        builder: (context, state) => const PostManualScreen(),
      ),
      GoRoute(
        path: AppRoutes.createPostSettings,
        builder: (context, state) => const PostSettingsScreen(),
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
          final roleStr = state.uri.queryParameters['role'];
          final role = UserRole.values.firstWhere(
            (e) => e.name == roleStr,
            orElse: () => state.extra as UserRole? ?? UserRole.member,
          );
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
        path: AppRoutes.privacy,
        builder: (context, state) => const LegalWebViewScreen(
          title: 'Privacy Policy',
          url: 'https://healingmilestones.in/privacy',
        ),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) => const LegalWebViewScreen(
          title: 'Terms of Service',
          url: 'https://healingmilestones.in/terms',
        ),
      ),
      GoRoute(
        path: AppRoutes.themeSelection,
        builder: (context, state) => const ThemeSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.accessibilitySettings,
        builder: (context, state) => const AccessibilitySettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.drafts,
        builder: (context, state) => const DraftsScreen(),
      ),
      GoRoute(
        path: AppRoutes.reportStoryPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReportScreen(storyId: id);
        },
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
          final userIds = extra?['userIds'] as List<String>?;
          final targetUserId = extra?['targetUserId'] as String?;
          final listType = extra?['listType'] as String?;
          return UserListScreen(
            title: title, 
            userIds: userIds,
            targetUserId: targetUserId,
            listType: listType,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.storyDetailPath,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: StoryDetailScreen(milestoneId: id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminSubmissions,
        builder: (context, state) => const AdminSubmissionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.supportChat,
        builder: (context, state) => const InboxScreen(),
      ),
      GoRoute(
        path: '/admin-submissions/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final data = state.extra as Map<String, dynamic>? ?? {};
          return AdminSubmissionDetailScreen(
            submissionId: id,
            data: data,
          );
        },
      ),
    ]
      ),
    ],
  );
});
