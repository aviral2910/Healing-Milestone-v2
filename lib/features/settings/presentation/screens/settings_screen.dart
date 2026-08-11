import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/theme/app_theme.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/core/presentation/widgets/logout_button.dart';
import 'package:healing_milestones/core/router/app_routes.dart';

import 'package:healing_milestones/features/accessibility/data/accessibility_providers.dart';
import 'package:healing_milestones/features/milestone/presentation/providers/draft_settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum MenuContext { home, profile }

class SettingsScreen extends ConsumerWidget {
  final MenuContext menuContext;

  const SettingsScreen({Key? key, required this.menuContext}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    List<Widget> options = [];

    if (menuContext == MenuContext.home) {
      options.addAll([
        _buildOptionCard(
          context,
          icon: Icons.palette_outlined,
          title: 'Theme & Appearance',
          subtitle: 'Customize your visual experience',
          onTap: () {
            context.push(AppRoutes.themeSelection);
          },
        ),
        _buildOptionCard(
          context,
          icon: Icons.text_format_rounded,
          title: 'Text & Accessibility',
          subtitle: 'Adjust text size and contrast',
          onTap: () {
            context.push(AppRoutes.accessibilitySettings);
          },
        ),
        _buildOptionCard(
          context,
          icon: Icons.bug_report_outlined,
          title: 'UAT Mode',
          subtitle: 'Enable testing features and dummy data',
          onTap: () {
            context.push(AppRoutes.uat);
          },
        ),
        _buildOptionCard(
          context,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'Read how we protect your data',
          onTap: () {
            context.push(AppRoutes.privacy);
          },
        ),
        _buildOptionCard(
          context,
          icon: Icons.gavel_rounded,
          title: 'Terms of Service',
          subtitle: 'Read our platform rules and terms',
          onTap: () {
            context.push(AppRoutes.terms);
          },
        ),
        if (user != null)
          _buildOptionCard(
            context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out of your account securely',
            isDestructive: true,
            onTap: () {
              LogoutButton.showLogoutDialog(context, ref);
            },
          )
        else
          _buildOptionCard(
            context,
            icon: Icons.login_rounded,
            title: 'Sign In',
            subtitle: 'Log in to access your profile',
            onTap: () {
              context.push(AppRoutes.login);
            },
          ),
      ]);
    } else if (menuContext == MenuContext.profile) {
      options.addAll([
        _buildOptionCard(
          context,
          icon: Icons.edit_outlined,
          title: 'Edit Profile',
          subtitle: 'Update your personal details',
          onTap: () {
            context.push(AppRoutes.editProfile);
          },
        ),
        _buildOptionCard(
          context,
          icon: Icons.drafts_outlined,
          title: 'My Drafts',
          subtitle: 'Manage your saved story drafts',
          onTap: () {
            context.push(AppRoutes.drafts);
          },
        ),
        _buildOptionCard(
          context,
          icon: Icons.save_outlined,
          title: 'Auto-Save Drafts',
          subtitle: 'Automatically save while writing posts',
          onTap: () {
            final currentValue = ref.read(draftAutoSaveProvider);
            ref.read(draftAutoSaveProvider.notifier).toggleAutoSave(!currentValue);
          },
          trailing: Switch(
            value: ref.watch(draftAutoSaveProvider),
            onChanged: (val) {
              ref.read(draftAutoSaveProvider.notifier).toggleAutoSave(val);
            },
          ),
        ),
        _buildOptionCard(
          context,
          icon: Icons.logout_rounded,
          title: 'Logout',
          subtitle: 'Sign out of your account securely',
          onTap: () {
            LogoutButton.showLogoutDialog(context, ref);
          },
        ),
        _buildOptionCard(
          context,
          icon: Icons.delete_forever_rounded,
          title: 'Delete Account',
          subtitle: 'Permanently remove your account and data',
          isDestructive: true,
          onTap: () {
            _showDeleteAccountDialog(context, ref);
          },
        ),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          menuContext == MenuContext.home ? 'Menu' : 'Profile Options',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          ...options,
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? Colors.redAccent
        : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        color: Theme.of(context).cardColor, // Premium dark card background
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(Icons.chevron_right_rounded,
                        color: Theme.of(context).iconTheme.color?.withOpacity(0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: theme.dividerColor,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curvedAnimation,
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 24,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5), width: 1),
              ),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.warning_rounded, color: theme.colorScheme.error, size: 36),
                  ),
                  const SizedBox(height: 20),
                  Text('Delete Account', style: theme.textTheme.headlineLarge?.copyWith(fontSize: 24)),
                ],
              ),
              content: Text(
                'Are you sure you want to permanently delete your account?\n\nThis action cannot be undone. All your stories, comments, bookmarks, and chats will be lost forever.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.5),
              ),
              actionsPadding: const EdgeInsets.all(24),
              actions: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final navContext = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        
                        // Show a loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        try {
                          await ref.read(authProvider.notifier).deleteAccount();
                          // Pop loading indicator
                          navContext.pop();
                          // Pop dialog
                          navContext.pop();
                          
                          context.go(AppRoutes.home);
                        } catch (e) {
                          // Pop loading indicator
                          navContext.pop();
                          // Pop dialog
                          navContext.pop();
                          
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete account: $e'),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        elevation: 0,
                      ),
                      child: const Text('Yes, delete my account'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
