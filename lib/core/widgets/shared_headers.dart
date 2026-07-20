import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/logo/healing_milestone_logo.dart';
import '../../main.dart';
import '../../features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/settings/presentation/screens/settings_screen.dart';

class CommonSliverAppBar extends ConsumerWidget {
  final bool isHeroEnabled;

  const CommonSliverAppBar({Key? key, this.isHeroEnabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authProvider);
    final isAuthLoading = authState.isLoading;
    final isAuthenticated =
        authState.valueOrNull?.status == AuthStatus.authenticated;
    final isProfileLoading = isAuthLoading || (isAuthenticated && user == null);

    return SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      centerTitle: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          onTap: () {
            if (user != null) {
              context.push(AppRoutes.profile);
            } else {
              context.push(AppRoutes.login);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: user != null
              ? HeroMode(
                  enabled: isHeroEnabled,
                  child: Hero(
                    tag: 'profile-avatar-${user.userId}',
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        backgroundImage: NetworkImage(
                          user.profilePicture ??
                              'https://api.dicebear.com/7.x/avataaars/png?seed=${user.userId}',
                        ),
                      ),
                    ),
                  ),
                )
              : isProfileLoading
                  ? const _SkeletonAvatar()
                  : Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.24)),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.person_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
        ),
      ),
      title: HealingMilestonesLogoWidget(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              context.push(AppRoutes.uat);
            },
            child: const Text('UAT',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            context.push(AppRoutes.settings, extra: MenuContext.home);
          },
        ),
      ],
    );
  }
}

class CommonSearchBarSliver extends StatelessWidget {
  final bool includeWelcomeText;
  final String displayName;
  final String hintText;
  final VoidCallback? onTap;

  const CommonSearchBarSliver({
    Key? key,
    this.includeWelcomeText = false,
    this.displayName = '',
    this.hintText = 'Search...',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          if (includeWelcomeText) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Welcome Reader,',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                displayName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1.0,
                ),
              ),
              child: TextField(
                readOnly: onTap != null,
                onTap: onTap,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Color(0xFF7A7A7A)),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFFA1A1A6)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: Theme.of(context).dividerColor, height: 1),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SkeletonAvatar extends StatefulWidget {
  const _SkeletonAvatar({Key? key}) : super(key: key);

  @override
  State<_SkeletonAvatar> createState() => _SkeletonAvatarState();
}

class _SkeletonAvatarState extends State<_SkeletonAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_controller.value * 0.5),
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF3A3A3C),
            ),
          ),
        );
      },
    );
  }
}
