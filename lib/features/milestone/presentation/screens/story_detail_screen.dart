import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/media_attachment.dart';
import '../../../../core/models/story_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/presentation/widgets/user_badge.dart';
import '../../../../core/presentation/widgets/verified_story_badge.dart';
import '../../../posts/presentation/widgets/post_display_widget.dart';
import '../widgets/milestone_media_gallery.dart';
import '../widgets/comments_thread.dart';
import '../../../accessibility/data/accessibility_providers.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../auth/data/repository_providers.dart';
import '../../../posts/data/story_providers.dart';

import '../../../../core/data/dummy_data.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

class StoryDetailScreen extends ConsumerWidget {
  final String milestoneId;

  const StoryDetailScreen({Key? key, required this.milestoneId})
      : super(key: key);

  void _showAccessibilityBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Reading Settings',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                const Text('Text Size',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600)),
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(accessibilityProvider);
                    return Slider(
                      value: state.textSizeFactor,
                      min: 0.8,
                      max: 2.0,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (val) => ref
                          .read(accessibilityProvider.notifier)
                          .updateTextSizeFactor(val),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('Contrast/Opacity',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600)),
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(accessibilityProvider);
                    return Slider(
                      value: state.textOpacity,
                      min: 0.5,
                      max: 1.0,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (val) => ref
                          .read(accessibilityProvider.notifier)
                          .updateTextOpacity(val),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyAsync = ref.watch(storyByIdProvider(milestoneId));
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return storyAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error loading story: $error')),
      ),
      data: (story) {
        if (story == null) {
          return const Scaffold(
            body: Center(child: Text('Story not found')),
          );
        }

        final userAsync = ref.watch(userByIdProvider(story.authorId));

        final List<MediaAttachment> actualMedia = [];
        if (story.mainImage.isNotEmpty) {
          actualMedia.add(MediaAttachment(
            mediaId: 'main',
            url: story.mainImage,
            title: 'Cover Image',
            description: '',
            isSensitive: false,
            uploadedAt: story.publishedAt,
          ));
        }
        for (var i = 0; i < story.imageAssets.length; i++) {
          actualMedia.add(MediaAttachment(
            mediaId: 'asset_$i',
            url: story.imageAssets[i],
            title: 'Image ${i + 1}',
            description: '',
            isSensitive: false,
            uploadedAt: story.publishedAt,
          ));
        }

    return Scaffold(
      body: Stack(
        children: [
          AnimationLimiter(
            child: CustomScrollView(
              slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_display_outlined),
                    onPressed: () =>
                        _showAccessibilityBottomSheet(context, ref),
                  )
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Massive Editorial Typography Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.heading.isNotEmpty
                                ? story.heading
                                : 'A Healing Journey',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 42, // Massive scale
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFF5F5F7), // Frost white
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Author Metadata Row
                          GestureDetector(
                            onTap: story.displayAuthorName ? () {
                              if (currentUser?.userId == story.authorId) {
                                context.push('/profile');
                              } else {
                                context.push('/user/${story.authorId}');
                              }
                            } : null,
                            child: Row(
                              children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: theme.colorScheme.surface,
                                  backgroundImage: NetworkImage(
                                    userAsync.valueOrNull?.profilePicture ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=${story.authorId}'
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        userAsync.when(
                                          data: (user) {
                                            final displayName = user?.displayName;
                                            final username = user?.username;
                                            
                                            String authorText = 'Author ${story.authorId}';
                                            if (!story.displayAuthorName) {
                                              authorText = 'Anonymous';
                                            } else if (displayName != null && displayName.isNotEmpty) {
                                              authorText = displayName;
                                            } else if (username != null && username.isNotEmpty) {
                                              authorText = '@$username';
                                            }

                                            return Text(
                                              authorText,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFFF5F5F7),
                                              ),
                                            );
                                          },
                                          loading: () => Text(
                                            !story.displayAuthorName ? 'Anonymous' : 'Loading...',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFF5F5F7),
                                            ),
                                          ),
                                          error: (_, __) => Text(
                                            !story.displayAuthorName ? 'Anonymous' : 'Author',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFF5F5F7),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        UserBadge(
                                          role: userAsync.valueOrNull?.role ?? story.authorRole,
                                          isVerified: userAsync.valueOrNull?.isVerified ?? story.isAuthorVerified,
                                          iconSize: 16,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Published just now • 5 min read',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFFA1A1A6),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (story.isVerifiedStory)
                                const VerifiedStoryBadge(),
                            ],
                          ),
                        ),
                        ],
                      ),
                    ),
                    // Hashtags
                    if (story.hashtagsList.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _ExpandableTagsList(tags: story.hashtagsList),
                      ),
                    ],
                    
                    // Tagged People
                    if (story.taggedPeople.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _TaggedPeopleList(taggedUserIds: story.taggedPeople),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // The Immutable Post Widget Template - NO DIVIDERS
                    // Encased in a beautiful midnight matte if it's minimal
                    Container(
                      color: theme.colorScheme.surface,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 8.0),
                        child: PostDisplayWidget(
                          content: story.description,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final currentUser = ref.watch(currentUserProvider);
                              final isLiked = story.likesList.contains(currentUser?.userId);
                              
                              return Row(
                                children: [
                                  Text(
                                    story.likesCount.toString(),
                                    style: TextStyle(
                                      color: isLiked ? theme.colorScheme.primary : const Color(0xFFA1A1A6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                                    onPressed: () {
                                      if (currentUser == null) {
                                        context.push('/login');
                                      } else {
                                        ref.read(storyRepositoryProvider).toggleLike(story.storyId, currentUser.userId);
                                      }
                                    },
                                    color: isLiked ? theme.colorScheme.primary : const Color(0xFFA1A1A6),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Consumer(
                            builder: (context, ref, child) {
                              final currentUser = ref.watch(currentUserProvider);
                              final isBookmarked = currentUser?.bookmarkedStories.contains(story.storyId) ?? false;
                              
                              return IconButton(
                                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                                onPressed: () {
                                  if (currentUser == null) {
                                    context.push('/login');
                                  } else {
                                    ref.read(userRepositoryProvider).toggleBookmark(currentUser.userId, story.storyId);
                                  }
                                },
                                color: isBookmarked ? theme.colorScheme.primary : const Color(0xFFA1A1A6),
                              );
                            }
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.ios_share_rounded),
                            onPressed: () {},
                            color: const Color(0xFFA1A1A6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (actualMedia.isNotEmpty) ...[
                            Text(
                              'Journey Media',
                              style: theme.textTheme.headlineLarge
                                  ?.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 24),
                            MilestoneMediaGallery(media: actualMedia),
                            const SizedBox(height: 64),
                          ],
                          Text(
                            'Comments',
                            style: theme.textTheme.headlineLarge
                                ?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 24),
                          CommentsThread(milestone: story),
                          const SizedBox(height: 40), // Normal padding
                        ],
                      ),
                    ),
                  ].asMap().entries.map((entry) => 
                    AnimationConfiguration.staggeredList(
                      position: entry.key,
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(
                        verticalOffset: 100.0,
                        child: FadeInAnimation(
                          child: entry.value,
                        ),
                      ),
                    )
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
    },
    );
  }
}

class _ExpandableTagsList extends StatefulWidget {
  final List<String> tags;

  const _ExpandableTagsList({Key? key, required this.tags}) : super(key: key);

  @override
  State<_ExpandableTagsList> createState() => _ExpandableTagsListState();
}

class _ExpandableTagsListState extends State<_ExpandableTagsList> {
  bool _isExpanded = false;
  // Determine how many tags to show initially. E.g., first 5 tags or all if there are <= 5.
  static const int _initialVisibleCount = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showToggle = widget.tags.length > _initialVisibleCount;
    final visibleTags = _isExpanded
        ? widget.tags
        : widget.tags.take(_initialVisibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: visibleTags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          }).toList(),
        ),
        if (showToggle) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Show less' : 'Show all ${widget.tags.length} tags',
              style: TextStyle(
                color: const Color(0xFFA1A1A6), // Titanium
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TaggedPeopleList extends ConsumerWidget {
  final List<String> taggedUserIds;
  const _TaggedPeopleList({Key? key, required this.taggedUserIds}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'With:',
          style: TextStyle(
            color: const Color(0xFFA1A1A6), // Titanium
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: taggedUserIds.map((userId) {
            final userAsync = ref.watch(userByIdProvider(userId));
            return userAsync.when(
              data: (user) {
                if (user == null) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    final currentUser = ref.read(currentUserProvider);
                    if (currentUser?.userId == user.userId) {
                      context.push('/profile');
                    } else {
                      context.push('/user/${user.userId}');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF333333),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage(
                            user.profilePicture ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=${user.userId}'
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '@${user.username ?? user.displayName}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          }).toList(),
        ),
      ],
    );
  }
}
