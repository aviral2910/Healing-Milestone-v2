import re

with open("lib/features/search/presentation/screens/search_screen.dart", "r") as f:
    content = f.read()

# 1. Rename old _buildResultsState to _buildGlobalSearchTabView
content = content.replace("Widget _buildResultsState(WidgetRef ref) {", "Widget _buildGlobalSearchTabView(WidgetRef ref) {")

# 2. Add the new _buildResultsState and the missing tab views
new_methods = """
  Widget _buildResultsState(WidgetRef ref) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildGlobalSearchTabView(ref),
        _buildPeopleSearchTabView(ref),
        _buildStoriesSearchTabView(ref),
        _buildJourneysSearchTabView(ref),
      ],
    );
  }

  Widget _buildPeopleSearchTabView(WidgetRef ref) {
    final stateAsync = ref.watch(paginatedPeopleProvider);
    
    return stateAsync.when(
      loading: () => const Center(child: AppLoader()),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (state) {
        if (state.items.isEmpty && !state.isLoadingMore) {
          return const Center(child: Text('No people found.', style: TextStyle(color: Colors.grey)));
        }
        
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!state.isLoadingMore && state.hasMore && 
                scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              ref.read(paginatedPeopleProvider.notifier).loadMore();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ));
              }
              final user = state.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: UserProfileCard(
                  user: user,
                  onTap: () {
                    _submitSearch(_searchController.text);
                    final currentUser = ref.read(currentUserProvider);
                    if (currentUser?.userId == user.userId) {
                      context.push(AppRoutes.profile);
                    } else {
                      context.push(AppRoutes.publicProfile(user.userId));
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStoriesSearchTabView(WidgetRef ref) {
    final stateAsync = ref.watch(paginatedStoriesProvider);
    
    return stateAsync.when(
      loading: () => const Center(child: AppLoader()),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (state) {
        if (state.items.isEmpty && !state.isLoadingMore) {
          return const Center(child: Text('No stories found.', style: TextStyle(color: Colors.grey)));
        }
        
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!state.isLoadingMore && state.hasMore && 
                scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              ref.read(paginatedStoriesProvider.notifier).loadMore();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ));
              }
              final story = state.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: StoryCard(
                  story: story,
                  content: _truncateContent(story.description, 180),
                  onTap: () {
                    _submitSearch(_searchController.text);
                    context.push(AppRoutes.storyDetail(story.storyId));
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildJourneysSearchTabView(WidgetRef ref) {
    final stateAsync = ref.watch(paginatedJourneysProvider);
    
    return stateAsync.when(
      loading: () => const Center(child: AppLoader()),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (state) {
        if (state.items.isEmpty && !state.isLoadingMore) {
          return const Center(child: Text('No journeys found.', style: TextStyle(color: Colors.grey)));
        }
        
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!state.isLoadingMore && state.hasMore && 
                scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              ref.read(paginatedJourneysProvider.notifier).loadMore();
            }
            return false;
          },
          child: ListView.builder(
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
          ),
        );
      },
    );
  }

  Widget _buildGlobalSearchTabView(WidgetRef ref) {"""

content = content.replace("  Widget _buildGlobalSearchTabView(WidgetRef ref) {", new_methods)

with open("lib/features/search/presentation/screens/search_screen.dart", "w") as f:
    f.write(content)
