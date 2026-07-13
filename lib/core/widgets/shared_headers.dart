import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/logo/healing_milestone_logo.dart';
import '../../main.dart';
import '../data/dummy_data.dart';

class CommonSliverAppBar extends ConsumerWidget {
  final bool isHeroEnabled;

  const CommonSliverAppBar({Key? key, this.isHeroEnabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(dummyUserProvider);

    return SliverAppBar(
      floating: false,
      pinned: true,
      snap: false,
      centerTitle: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: InkWell(
          onTap: () {
            context.push('/profile');
          },
          borderRadius: BorderRadius.circular(20),
          child: HeroMode(
            enabled: isHeroEnabled,
            child: Hero(
              tag: 'profile-avatar-${user.userId}',
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, Colors.amber],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  backgroundImage: NetworkImage(
                    'https://api.dicebear.com/7.x/avataaars/png?seed=${user.userId}',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      title: HealingMilestonesLogoWidget(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              ref.read(uatModeProvider.notifier).state =
                  !ref.read(uatModeProvider);
            },
            child: const Text('UAT',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class CommonSearchBarSliver extends StatelessWidget {
  final bool includeWelcomeText;
  final String userName;
  final String hintText;
  final VoidCallback? onTap;

  const CommonSearchBarSliver({
    Key? key,
    this.includeWelcomeText = false,
    this.userName = '',
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
                  color: const Color(0xFFF5F5F7), // Frost white
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                userName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  color: const Color(0xFFA1A1A6), // Titanium
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
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF2A2A2A),
                  width: 1.0,
                ),
              ),
              child: TextField(
                readOnly: onTap != null,
                onTap: onTap,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Color(0xFF7A7A7A)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFA1A1A6)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
