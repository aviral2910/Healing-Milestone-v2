import 'package:flutter/material.dart';
import '../../core/models/story_model.dart';
import '../../core/presentation/widgets/user_badge.dart';
import '../../core/presentation/widgets/verified_story_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';
import 'package:healing_milestones/features/auth/data/repository_providers.dart';
import '../../features/auth/data/auth_provider.dart';

class StoryCard extends ConsumerStatefulWidget {
  final StoryModel story;
  final VoidCallback onTap;
  final String content;

  const StoryCard({
    Key? key,
    required this.story,
    required this.onTap,
    required this.content,
  }) : super(key: key);

  @override
  ConsumerState<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends ConsumerState<StoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userByIdProvider(widget.story.authorId));

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Editorial Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      backgroundImage: NetworkImage(
                        userAsync.valueOrNull?.profilePicture ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=${widget.story.authorId}'
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
                                  
                                  String authorText = 'Author ${widget.story.authorId}';
                                  if (!widget.story.displayAuthorName) {
                                    authorText = 'Anonymous';
                                  } else if (displayName != null && displayName.isNotEmpty) {
                                    authorText = displayName;
                                  } else if (username != null && username.isNotEmpty) {
                                    authorText = '@$username';
                                  }

                                  return Text(
                                    authorText,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                                loading: () => Text(
                                  !widget.story.displayAuthorName ? 'Anonymous' : 'Loading...',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                error: (_, __) => Text(
                                  !widget.story.displayAuthorName ? 'Anonymous' : 'Author',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              UserBadge(
                                role: userAsync.valueOrNull?.role ?? widget.story.authorRole,
                                isVerified: userAsync.valueOrNull?.isVerified ?? widget.story.isAuthorVerified,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(widget.story.publishedAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.story.isVerifiedStory)
                      const VerifiedStoryBadge(),
                  ],
                ),
              ),

              // The Title
              if (widget.story.heading.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 16.0),
                  child: Text(
                    widget.story.heading,
                    style:
                        theme.textTheme.headlineLarge?.copyWith(fontSize: 24),
                  ),
                ),

              // The Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.story.mainImage.isNotEmpty || widget.story.imageAssets.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.story.mainImage.isNotEmpty 
                            ? widget.story.mainImage 
                            : widget.story.imageAssets.first,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 250,
                              color: const Color(0xFF1E1E1E),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                  color: Colors.grey.withValues(alpha: 0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                      ),
                    ] else ...[
                      // Text-only treatment
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                              theme.colorScheme.primary.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          widget.content,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Read more',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    // Hashtags
                    if (widget.story.hashtagsList.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: widget.story.hashtagsList.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

            // Interaction Footer
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Consumer(
                  builder: (context, ref, child) {
                    return Row(
                      children: [
                        InteractionButton(
                          icon: widget.story.likesList.contains(ref.watch(currentUserProvider)?.userId) 
                              ? Icons.favorite 
                              : Icons.favorite_border,
                          label: widget.story.likesCount.toString(),
                          color: widget.story.likesList.contains(ref.watch(currentUserProvider)?.userId)
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary,
                          onTap: () {
                            final user = ref.read(currentUserProvider);
                            if (user == null) {
                              context.push('/login');
                            } else {
                              ref.read(storyRepositoryProvider).toggleLike(widget.story.storyId, user.userId);
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        InteractionButton(
                          icon: Icons.chat_bubble_outline,
                          label: widget.story.commentCount.toString(),
                          color: theme.textTheme.bodySmall!.color!,
                          onTap: () {
                            // Can navigate to story detail for comments
                            context.push('/story/${widget.story.storyId}');
                          },
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            final user = ref.read(currentUserProvider);
                            if (user == null) {
                              context.push('/login');
                            } else {
                              ref.read(userRepositoryProvider).toggleBookmark(user.userId, widget.story.storyId);
                            }
                          },
                          child: Icon(
                            ref.watch(currentUserProvider)?.bookmarkedStories.contains(widget.story.storyId) == true
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: ref.watch(currentUserProvider)?.bookmarkedStories.contains(widget.story.storyId) == true
                                ? theme.colorScheme.primary
                                : theme.textTheme.bodySmall!.color!,
                            size: 22,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const InteractionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
