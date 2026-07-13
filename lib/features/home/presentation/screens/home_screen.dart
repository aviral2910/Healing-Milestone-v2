import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/logo/healing_milestone_logo.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../../features/posts/presentation/screens/post_screen.dart';
import '../../../../features/awareness/presentation/screens/health_awareness_screen.dart';
import '../../../../main.dart';

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;
  final double height;

  _SliverTabBarDelegate({required this.tabBar, this.height = 64});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor, // matches background
      alignment: Alignment.center,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(dummyUserProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 1. Pinned Top App Bar
              SliverAppBar(
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
                    child: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                      backgroundImage: NetworkImage(
                        'https://api.dicebear.com/7.x/avataaars/png?seed=${user.userId}',
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onPressed: () {
                        ref.read(uatModeProvider.notifier).state = !ref.read(uatModeProvider);
                      },
                      child: const Text('UAT', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

              // 2. Scrollable Welcome Text + Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Reader,',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFF5F5F7), // Frost white
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.userName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 22,
                          color: const Color(0xFFA1A1A6), // Titanium
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF151515),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2A2A2A),
                            width: 1.0,
                          ),
                        ),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search stories, topics, people...',
                            hintStyle: const TextStyle(color: Color(0xFF7A7A7A)),
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xFFA1A1A6)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              // Optional divider before tabs
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Divider(color: Color(0xFF2A2A2A), height: 1),
                ),
              ),

              // 3. Pinned Segmented Tab Buttons
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  tabBar: Container(
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF2A2A2A),
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelColor: Colors.black, // Dark text on gold
                        unselectedLabelColor: const Color(0xFFA1A1A6),
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                        tabs: const [
                          Tab(text: 'Stories'),
                          Tab(text: 'Awareness'),
                        ],
                      ),
                    ),
                  ),
                  height: 64, // 48 (tabbar) + 16 bottom padding
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              PostScreen(),
              HealthAwarenessScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
