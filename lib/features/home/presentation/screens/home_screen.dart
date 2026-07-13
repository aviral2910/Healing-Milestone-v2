import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/logo/healing_milestone_logo.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../../features/posts/presentation/screens/post_screen.dart';
import '../../../../features/awareness/presentation/screens/health_awareness_screen.dart';
import '../../../../main.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(dummyUserProvider);

    return Scaffold(
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
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          prefixIcon: const Icon(Icons.search, color: Color(0xFFA1A1A6)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Optional divider
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 0.0),
                child: Divider(color: Color(0xFF2A2A2A), height: 1),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            PostScreen(),
            HealthAwarenessScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF2A2A2A), width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
          backgroundColor: const Color(0xFF0A0A0A), // Pure dark mode
          selectedItemColor: theme.colorScheme.primary, // Gold
          unselectedItemColor: const Color(0xFFA1A1A6), // Titanium
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.feed_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.feed),
              ),
              label: 'Stories',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.health_and_safety_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.health_and_safety),
              ),
              label: 'Awareness',
            ),
          ],
        ),
      ),
    );
  }
}
