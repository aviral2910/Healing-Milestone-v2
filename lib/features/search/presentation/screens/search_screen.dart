import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../data/search_providers.dart';
import '../../../auth/data/auth_provider.dart';
import '../widgets/user_profile_card.dart';
import '../../../posts/data/hashtag_repository.dart';
import '../../../../shared/widgets/story_card.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  final bool isActiveTab;

  const SearchScreen({
    Key? key,
    this.scrollController,
    this.isActiveTab = true,
  }) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late TabController _tabController;
  Timer? _debounce;
  String? _selectedHashtag;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _onSearchChanged(_searchController.text);
      if (_tabController.index == 1) {
        _selectedHashtag = null; // Clear selected hashtag when moving to People
      }
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActiveTab && !oldWidget.isActiveTab) {
      // Clear the search text when switching to this tab
      _searchController.clear();
      _selectedHashtag = null;
      _onSearchChanged('');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (_tabController.index == 0) {
        ref.read(hashtagSearchQueryProvider.notifier).state = query;
      } else {
        ref.read(peopleSearchQueryProvider.notifier).state = query;
      }
      
      // If user types, we leave the selected hashtag view
      if (query.isNotEmpty && _selectedHashtag != null) {
        setState(() {
          _selectedHashtag = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: NestedScrollView(
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
                toolbarHeight: 72,
                title: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white),
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: _tabController.index == 0 ? 'Search hashtags...' : 'Search people...',
                        hintStyle: const TextStyle(color: Color(0xFF7A7A7A)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFA1A1A6)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFFA1A1A6), size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                            if (_selectedHashtag != null) {
                              setState(() => _selectedHashtag = null);
                            }
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      TabBar(
                        controller: _tabController,
                        indicatorColor: theme.colorScheme.primary,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 3.0,
                        dividerColor: Colors.transparent,
                        labelColor: theme.colorScheme.primary,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit', fontSize: 16),
                        unselectedLabelColor: const Color(0xFFA1A1A6),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Outfit', fontSize: 16),
                        splashBorderRadius: BorderRadius.circular(8),
                        tabs: const [
                          Tab(text: 'Tags & Stories'),
                          Tab(text: 'People'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTagsAndStoriesTab(),
              _buildPeopleTab(),
            ],
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

  Widget _buildTagsAndStoriesTab() {
    if (_selectedHashtag != null) {
      final storiesAsync = ref.watch(hashtagStoriesProvider(_selectedHashtag!));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  onPressed: () => setState(() => _selectedHashtag = null),
                ),
                const SizedBox(width: 8),
                Text(
                  '#$_selectedHashtag',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
              ],
            ),
          ),
          Expanded(
            child: storiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
              data: (stories) {
                if (stories.isEmpty) {
                  return const Center(child: Text('No stories found for this tag.', style: TextStyle(color: Colors.grey)));
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
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: StoryCard(
                                  story: stories[index],
                                  content: _truncateContent(stories[index].description, 180),
                                  onTap: () {
                                    context.push(AppRoutes.storyDetail(stories[index].storyId));
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

    final query = ref.watch(hashtagSearchQueryProvider);
    if (query.isEmpty) {
      final trendingAsync = ref.watch(trendingHashtagsProvider);
      return trendingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (tags) {
          if (tags.isEmpty) return const Center(child: Text('No trending tags yet.', style: TextStyle(color: Colors.grey)));
          return _buildHashtagList(tags, 'Trending Tags');
        },
      );
    }

    final searchAsync = ref.watch(searchHashtagsProvider);
    return searchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (tags) {
        if (tags.isEmpty) return const Center(child: Text('No tags found.', style: TextStyle(color: Colors.grey)));
        return _buildHashtagList(tags, 'Results', isSearch: true);
      },
    );
  }

  Widget _buildHashtagList(List<String> tags, String title, {bool isSearch = false}) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      color: theme.primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: () async {
        if (isSearch) {
          // ignore: unused_result
          ref.refresh(searchHashtagsProvider);
        } else {
          // ignore: unused_result
          ref.refresh(trendingHashtagsProvider);
        }
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AnimationLimiter(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 16,
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
                                    setState(() {
                                      _selectedHashtag = tag;
                                      _searchController.clear();
                                      ref.read(hashtagSearchQueryProvider.notifier).state = '';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [theme.colorScheme.primary.withValues(alpha: 0.15), theme.colorScheme.primary.withValues(alpha: 0.05)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.tag, color: theme.colorScheme.primary, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          tag,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
                  ),
                ),
                const SizedBox(height: 32), // bottom padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeopleTab() {
    final query = ref.watch(peopleSearchQueryProvider);
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('Search for people by username', style: TextStyle(color: Color(0xFFA1A1A6), fontSize: 16)),
          ],
        ),
      );
    }

    final usersAsync = ref.watch(searchUsersProvider);
    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text('No people found.', style: TextStyle(color: Colors.grey)));
        }
        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async {
            // ignore: unused_result
            ref.refresh(searchUsersProvider);
          },
          child: AnimationLimiter(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: UserProfileCard(
                        user: user,
                        onTap: () {
                          final currentUser = ref.read(currentUserProvider);
                          if (currentUser?.userId == user.userId) {
                            context.push(AppRoutes.profile);
                          } else {
                            context.push(AppRoutes.publicProfile(user.userId));
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
