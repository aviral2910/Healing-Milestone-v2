import 'package:healing_milestones/core/router/app_routes.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/core/theme/app_theme.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () => showLogoutDialog(context, ref),
    );
  }

  static void showLogoutDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Dismiss',
          barrierColor:
              Colors.black.withValues(alpha: 0.6), // Dim the background
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            return const SizedBox(); // Not used, we use transitionBuilder
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack, // Nice bouncy spring effect
            );

            return BackdropFilter(
              filter: ui.ImageFilter.blur(
                  sigmaX: 8, sigmaY: 8), // Premium glass blur
              child: ScaleTransition(
                scale: curvedAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: AlertDialog(
                    backgroundColor: AppTheme.surface.withValues(
                        alpha: 0.95), // Slight transparency for glass effect
                    surfaceTintColor: Colors.transparent,
                    elevation: 24,
                    shadowColor: Colors.black.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20), // Even rounder for a floating bubble look
                      side: const BorderSide(
                        color: Color(
                            0xFF2A2A2A), // Soft titanium border instead of gold
                        width: 1,
                      ),
                    ),
                    title: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.accentPrimary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  AppTheme.accentPrimary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: AppTheme.accentPrimary,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Logout',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontSize: 26,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'Are you sure you want to logout?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    actionsAlignment: MainAxisAlignment.center,
                    actionsPadding: const EdgeInsets.only(
                        bottom: 24, left: 24, right: 24, top: 16),
                    actions: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ref.read(authProvider.notifier).signOut();
                              context.go(AppRoutes.home);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: AppTheme.accentPrimary,
                              foregroundColor: Colors.black,
                              elevation: 0, // Flat premium look
                            ),
                            child: const Text('Log out'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
  }
}
