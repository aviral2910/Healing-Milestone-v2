import re

with open("lib/features/search/presentation/screens/search_screen.dart", "r") as f:
    content = f.read()

# 1. Fix the TabBar UI
old_tabbar = """                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  tabs: const [
                    Tab(text: 'Top'),
                    Tab(text: 'People'),
                    Tab(text: 'Stories'),
                    Tab(text: 'Journeys'),
                  ],
                ),"""

new_tabbar = """                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: theme.colorScheme.primary,
                  ),
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onSurface,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Top', height: 36),
                    Tab(text: 'People', height: 36),
                    Tab(text: 'Stories', height: 36),
                    Tab(text: 'Journeys', height: 36),
                  ],
                ),"""

content = content.replace(old_tabbar, new_tabbar)

# 2. Fix the layout crash in _buildJourneysSearchTabView by using a GridView
old_journeys_list = """          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ));
              }
              final journey = state.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: PublicJourneyItem(journey: journey),
              );
            },
          ),"""

new_journeys_list = """          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final journey = state.items[index];
              return PublicJourneyItem(journey: journey);
            },
          ),"""

content = content.replace(old_journeys_list, new_journeys_list)

with open("lib/features/search/presentation/screens/search_screen.dart", "w") as f:
    f.write(content)
