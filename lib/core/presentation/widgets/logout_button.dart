import 'package:healing_milestones/core/router/app_routes.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';

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
      barrierColor: Theme.of(context).dividerColor, // Dim the background
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
          filter:
              ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Premium glass blur
          child: ScaleTransition(
            scale: curvedAnimation,
            child: FadeTransition(
              opacity: animation,
              child: AlertDialog(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(
                        alpha: 0.95), // Slight transparency for glass effect
                surfaceTintColor: Colors.transparent,
                elevation: 24,
                shadowColor: Theme.of(context).dividerColor,
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
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: Theme.of(context).colorScheme.primary,
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
                    color: (Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.grey),
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
                        onPressed: () async {
                          final navContext = Navigator.of(context);
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);

                          navContext.pop(); // dismiss dialog

                          try {
                            context.go(AppRoutes.home);
                            await ref.read(authProvider.notifier).signOut();
                            // GoRouter redirect automatically handles routing
                          } catch (e) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Failed to logout. Please try again.'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurface,
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
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: (Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color ??
                                Colors.grey),
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
