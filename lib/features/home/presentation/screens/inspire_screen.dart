import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/shared_headers.dart';
import '../../../posts/presentation/screens/post_screen.dart';
import '../../../posts/presentation/screens/recommended_swipe_screen.dart';
import '../../../awareness/presentation/screens/health_awareness_screen.dart';
import '../../../../features/auth/data/auth_provider.dart';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';

class InspireScreen extends ConsumerStatefulWidget {
  final ScrollController timelineScrollController;
  final ScrollController forYouScrollController;
  final ScrollController awarenessScrollController;
  final VoidCallback onSearchTapped;
  final bool isActiveTab;

  const InspireScreen({
    Key? key,
    required this.timelineScrollController,
    required this.forYouScrollController,
    required this.awarenessScrollController,
    required this.onSearchTapped,
    this.isActiveTab = true,
  }) : super(key: key);

  @override
  ConsumerState<InspireScreen> createState() => _InspireScreenState();
}

class _InspireScreenState extends ConsumerState<InspireScreen>
    with SingleTickerProviderStateMixin {
  late TabController _topTabController;
  late ScrollController _outerScrollController;

  @override
  void initState() {
    super.initState();
    _topTabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _outerScrollController = ScrollController();
    
    _topTabController.addListener(() {
      if (_topTabController.indexIsChanging || _topTabController.index == _topTabController.animation?.value) {
        setState(() {}); // Rebuild to update isActiveTab and isVisible
      }
    });
  }

  @override
  void dispose() {
    _topTabController.dispose();
    _outerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ExtendedNestedScrollView(
          controller: _outerScrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              CommonSliverAppBar(
                isHeroEnabled: widget.isActiveTab,
                isVisible: _topTabController.index != 1,
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _topTabController,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorWeight: 3.0,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                    dividerColor: theme.dividerColor,
                    tabs: const [
                      Tab(text: 'Timeline'),
                      Tab(text: 'For You'),
                      Tab(text: 'Awareness'),
                    ],
                  ),
                  theme.scaffoldBackgroundColor,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _topTabController,
            children: [
              PostScreen(
                isActiveTab: widget.isActiveTab && _topTabController.index == 0,
                onSearchTapped: widget.onSearchTapped,
              ),
              RecommendedSwipeScreen(
                isActiveTab: widget.isActiveTab && _topTabController.index == 1,
                onSearchTapped: widget.onSearchTapped,
              ),
              HealthAwarenessScreen(
                isActiveTab: widget.isActiveTab && _topTabController.index == 2,
                onSearchTapped: widget.onSearchTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;

  _TabBarDelegate(this._tabBar, this.backgroundColor);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return oldDelegate._tabBar != _tabBar;
  }
}
