import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/logo/healing_milestone_logo.dart';
import 'package:healing_milestones/features/settings/presentation/screens/settings_screen.dart';
import 'package:healing_milestones/features/accessibility/data/accessibility_providers.dart';


class CommonSliverAppBar extends ConsumerWidget {
  final bool isHeroEnabled;
  final bool isVisible;
  final VoidCallback? onSearchTapped;

  const CommonSliverAppBar({
    Key? key,
    this.isHeroEnabled = false,
    this.isVisible = true,
    this.onSearchTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isVisible) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final theme = Theme.of(context);

    return SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      centerTitle: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      title: HealingMilestonesLogoWidget(),
      actions: [
        if (onSearchTapped != null)
          IconButton(
            icon: const Icon(Icons.search),
            color: theme.colorScheme.onSurface,
            onPressed: onSearchTapped,
          ),
        // IconButton(
        //   icon: const Icon(Icons.bug_report_outlined),
        //   color: theme.colorScheme.onSurface,
        //   onPressed: () {
        //     context.push(AppRoutes.uat);
        //   },
        // ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          color: theme.colorScheme.onSurface,
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
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
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
            const SizedBox(height: 16),
            // Minimal UI Reading Mode Toggle
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer(
              builder: (context, ref, child) {
                final isGreyscale =
                    ref.watch(accessibilityProvider).isGreyscaleMode;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(accessibilityProvider.notifier)
                        .toggleGreyscaleMode();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isGreyscale
                          ? theme.colorScheme.primary.withValues(alpha: 0.12)
                          : theme.dividerColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isGreyscale
                            ? theme.colorScheme.primary.withValues(alpha: 0.3)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          size: 18,
                          color: isGreyscale
                              ? theme.colorScheme.primary
                              : theme.iconTheme.color?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: isGreyscale
                                  ? 'Want to turn off reading mode? '
                                  : 'Want to turn on reading mode? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: isGreyscale ? 'OFF' : 'ON',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
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
