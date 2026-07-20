import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/theme/app_theme.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/core/presentation/widgets/logout_button.dart';
import 'package:healing_milestones/core/router/app_routes.dart';

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
            // TODO: Theme customization
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
          icon: Icons.settings_outlined,
          title: 'App Settings',
          subtitle: 'Manage your preferences',
          onTap: () {
            // TODO: Settings
          },
        ),
        _buildOptionCard(
          context,
          icon: Icons.logout_rounded,
          title: 'Logout',
          subtitle: 'Sign out of your account securely',
          isDestructive: true,
          onTap: () {
            LogoutButton.showLogoutDialog(context, ref);
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
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.redAccent : AppTheme.accentPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        color: const Color(0xFF151515), // Premium dark card background
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
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
