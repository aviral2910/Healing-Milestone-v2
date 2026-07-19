import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../data/search_providers.dart';
import '../widgets/user_profile_card.dart';
import '../../../posts/data/hashtag_repository.dart';
import '../../../../shared/widgets/story_card.dart';

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
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primaryColor,
          labelColor: theme.primaryColor,
          unselectedLabelColor: const Color(0xFFA1A1A6),
          tabs: const [
            Tab(text: 'Tags & Stories'),
            Tab(text: 'People'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2A2A2A),
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
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTagsAndStoriesTab(),
                  _buildPeopleTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsAndStoriesTab() {
    if (_selectedHashtag != null) {
      final storiesAsync = ref.watch(hashtagStoriesProvider(_selectedHashtag!));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => setState(() => _selectedHashtag = null),
                ),
                Text('#$_selectedHashtag', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
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
                return ListView.builder(
                  controller: widget.scrollController,
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: StoryCard(
                        story: stories[index],
                        content: stories[index].description,
                        onTap: () {
                          context.push('/story/${stories[index].storyId}');
                        },
                      ),
                    );
                  },
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
        return _buildHashtagList(tags, 'Results');
      },
    );
  }

  Widget _buildHashtagList(List<String> tags, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  child: Icon(Icons.tag, color: Theme.of(context).primaryColor),
                ),
                title: Text(tag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _selectedHashtag = tag;
                    _searchController.clear();
                    ref.read(hashtagSearchQueryProvider.notifier).state = '';
                  });
                },
              );
            },
          ),
        ),
      ],
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
        return ListView.builder(
          controller: widget.scrollController,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return UserProfileCard(
              user: user,
              onTap: () {
                // Navigate to public profile screen if it existed
              },
            );
          },
        );
      },
    );
  }
}
