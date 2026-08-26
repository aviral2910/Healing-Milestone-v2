import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/search_providers.dart';
import '../../../auth/data/auth_provider.dart';
import '../widgets/user_profile_card.dart';
import '../../../../shared/widgets/story_card.dart';
import '../../../../features/journey/presentation/widgets/public_journey_carousel.dart';
import '../../../posts/data/hashtag_repository.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  final bool isActiveTab;
  final String? initialQuery;

  const SearchScreen({
    Key? key,
    this.scrollController,
    this.isActiveTab = true,
    this.initialQuery,
  }) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final TabController _tabController;
  Timer? _debounce;
  String? _selectedHashtag;
  
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRecentSearches();
    
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      // Delay slightly to allow providers to initialize
      Future.microtask(() {
        ref.read(globalSearchQueryProvider.notifier).updateQuery(widget.initialQuery!);
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }
  
  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    List<String> searches = prefs.getStringList('recent_searches') ?? [];
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 5) searches = searches.sublist(0, 5);
    await prefs.setStringList('recent_searches', searches);
    if (mounted) {
      setState(() {
        _recentSearches = searches;
      });
    }
  }
  
  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    if (mounted) {
      setState(() {
        _recentSearches = [];
      });
    }
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActiveTab && !oldWidget.isActiveTab) {
      _searchController.clear();
      _selectedHashtag = null;
      _onSearchChanged('');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      ref.read(globalSearchQueryProvider.notifier).updateQuery(query);
      if (query.isNotEmpty && _selectedHashtag != null) {
        setState(() {
          _selectedHashtag = null;
        });
      }
    });
  }

  void _submitSearch(String query) {
    _saveRecentSearch(query);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          controller: widget.scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: theme.scaffoldBackgroundColor,
                floating: true,
                pinned: false,
                snap: true,
                elevation: 0,
                titleSpacing: 0,


                bottom: TabBar(
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
                ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor,
                        width: 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      onChanged: _onSearchChanged,
                      onSubmitted: _submitSearch,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search people, tags, stories...',
                        hintStyle: TextStyle(
                            color: theme.textTheme.bodySmall?.color ?? Colors.grey),
                        prefixIcon: Icon(Icons.search,
                            color: theme.textTheme.bodySmall?.color ?? Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear,
                              color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                              size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                            if (_selectedHashtag != null) {
                              setState(() => _selectedHashtag = null);
                            }
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Consumer(
            builder: (context, ref, child) {
              if (_selectedHashtag != null) {
                return _buildHashtagFeed(ref);
              }

              final query = ref.watch(globalSearchQueryProvider);
              if (query.isEmpty) {
                return _buildEmptyState();
              }

              return _buildResultsState(ref);
            },
          ),
        ),
      ),
    );
  }

  String _truncateContent(String text, int length) {
    if (text.length <= length) return text;
    int end = text.lastIndexOf(' ', length);
    if (end == -1) end = length;
    return '${text.substring(0, end)}...';
  }

  
  Widget _buildHashtagFeed(WidgetRef ref) {
    final storiesAsync = ref.watch(hashtagStoriesProvider(_selectedHashtag!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface, size: 24),
                onPressed: () => setState(() => _selectedHashtag = null),
              ),
              const SizedBox(width: 8),
              Text(
                '#$_selectedHashtag',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: storiesAsync.when(
            loading: () => const Center(child: const AppLoader()),
            error: (err, stack) => Center(
                child: Text('Error: $err',
                    style: const TextStyle(color: Colors.red))),
            data: (stories) {
              if (stories.isEmpty) {
                return const Center(
                    child: Text('No stories found for this tag.',
                        style: TextStyle(color: Colors.grey)));
              }
              return RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).cardColor,
                onRefresh: () async {
                  // ignore: unused_result
                  ref.refresh(hashtagStoriesProvider(_selectedHashtag!));
                },
                child: AnimationLimiter(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: StoryCard(
                                story: stories[index],
                                content: _truncateContent(
                                    stories[index].description, 180),
                                onTap: () {
                                  context.push(AppRoutes.storyDetail(
                                      stories[index].storyId));
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final trendingAsync = ref.watch(trendingHashtagsProvider);
    
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (_recentSearches.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Searches',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _clearRecentSearches,
                    child: Text('Clear', style: TextStyle(color: Theme.of(context).primaryColor)),
                  )
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final search = _recentSearches[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text(search, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  onTap: () {
                    _searchController.text = search;
                    _onSearchChanged(search);
                    _submitSearch(search);
                  },
                );
              },
              childCount: _recentSearches.length,
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text('Trending Tags',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        trendingAsync.when(
          loading: () => const SliverToBoxAdapter(child: Center(child: const AppLoader())),
          error: (err, stack) => SliverToBoxAdapter(
            child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          ),
          data: (tags) {
            if (tags.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: Text('No trending tags yet.', style: TextStyle(color: Colors.grey))),
              );
            }
            final displayTags = tags.take(5).toList();
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildHashtagWrap(displayTags),
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }


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
          child: GridView.builder(
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
          ),
        );
      },
    );
  }

  Widget _buildGlobalSearchTabView(WidgetRef ref) {
    final searchAsync = ref.watch(globalSearchProvider);
    
    return searchAsync.when(
      loading: () => const Center(child: const AppLoader()),
      error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (result) {
        if (result == null || (result.people.isEmpty && result.tags.isEmpty && result.stories.isEmpty && result.journeys.isEmpty)) {
          return const Center(
              child: Text('No results found.', style: TextStyle(color: Colors.grey)));
        }

        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async {
            // ignore: unused_result
            ref.refresh(globalSearchProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (result.people.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text('People',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: result.people.length,
                      itemBuilder: (context, index) {
                        final user = result.people[index];
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 20),
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
                  ),
                ),
              ],
              
              if (result.tags.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Text('Tags',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildHashtagWrap(result.tags),
                  ),
                ),
              ],

              
              if (result.journeys.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Text('Journeys',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: result.journeys.length,
                      itemBuilder: (context, index) {
                        final journey = result.journeys[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: PublicJourneyItem(journey: journey),
                        );
                      },
                    ),
                  ),
                ),
              ],

              if (result.stories.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Text('Stories',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final story = result.stories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    childCount: result.stories.length,
                  ),
                ),
              ],
              
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHashtagWrap(List<String> tags) {
    final theme = Theme.of(context);
    return AnimationLimiter(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          tags.length,
          (index) {
            final tag = tags[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      _submitSearch(tag);
                      setState(() {
                        _selectedHashtag = tag;
                        _searchController.clear();
                        ref.read(globalSearchQueryProvider.notifier).updateQuery('');
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.primary.withValues(alpha: 0.05)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tag, color: theme.colorScheme.primary, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            tag,
                            style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
