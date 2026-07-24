import 'package:flutter/material.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/core/presentation/widgets/user_badge.dart';
import 'package:healing_milestones/core/presentation/widgets/verified_story_badge.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:healing_milestones/features/auth/data/repository_providers.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/shared/widgets/interaction_section.dart';
import 'package:shimmer/shimmer.dart';

class SwipeStoryCard extends ConsumerStatefulWidget {
  final StoryModel story;
  final VoidCallback onTap;
  final String content;

  const SwipeStoryCard({
    Key? key,
    required this.story,
    required this.onTap,
    required this.content,
  }) : super(key: key);

  @override
  ConsumerState<SwipeStoryCard> createState() => _SwipeStoryCardState();
}

class _SwipeStoryCardState extends ConsumerState<SwipeStoryCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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

    final hasImage = widget.story.mainImage.isNotEmpty || widget.story.imageAssets.isNotEmpty;
    final String? backgroundImageUrl = widget.story.mainImage.isNotEmpty
        ? widget.story.mainImage
        : (widget.story.imageAssets.isNotEmpty ? widget.story.imageAssets.first : null);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Editorial Header (Same as StoryCard)
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 12.0),
                child: Row(
                  children: [
                    !widget.story.displayAuthorName
                        ? CircleAvatar(
                            radius: 24,
                            backgroundColor: theme.colorScheme.surface,
                            child: Icon(Icons.person, color: theme.colorScheme.onSurface),
                          )
                        : ClipOval(
                            child: Image.network(
                              userAsync.valueOrNull?.profilePicture ??
                                  'https://api.dicebear.com/7.x/avataaars/png?seed=${widget.story.authorId}',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                radius: 24,
                                backgroundColor: theme.scaffoldBackgroundColor,
                                child: Icon(Icons.person, color: theme.colorScheme.onSurface),
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

                                  String authorText = 'Author ${widget.story.authorId}';
                                  if (!widget.story.displayAuthorName) {
                                    authorText = 'Anonymous';
                                  } else if (displayName != null && displayName.isNotEmpty) {
                                    authorText = displayName;
                                  } else if (username != null && username.isNotEmpty) {
                                    authorText = '@$username';
                                  }

                                  return Flexible(
                                    child: Text(
                                      authorText,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                                loading: () => Text(
                                  !widget.story.displayAuthorName ? 'Anonymous' : 'Loading...',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                error: (_, __) => Text(
                                  !widget.story.displayAuthorName ? 'Anonymous' : 'Author',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 4),
                              UserBadge(
                                role: userAsync.valueOrNull?.role ?? widget.story.authorRole,
                                isVerified: userAsync.valueOrNull?.isVerified ?? widget.story.isAuthorVerified,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              userAsync.maybeWhen(
                                data: (user) {
                                  if (widget.story.displayAuthorName &&
                                      user != null &&
                                      (user.username?.isNotEmpty ?? false) &&
                                      (user.displayName?.isNotEmpty ?? false)) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0, right: 5.0),
                                      child: Text(
                                        '@${user.username}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                orElse: () => const SizedBox.shrink(),
                              ),
                              Text(
                                _formatDate(widget.story.publishedAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              if (widget.story.heading.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 12.0),
                  child: Text(
                    widget.story.heading,
                    style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20, letterSpacing: 1.1),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              if (widget.story.isVerifiedStory)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 20.0, left: 20.0, bottom: 12),
                      child: VerifiedStoryBadge(),
                    ),
                  ],
                ),

              // Dynamic Content Area (Expanded to fill space)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasImage && backgroundImageUrl != null) ...[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              backgroundImageUrl,
                              fit: BoxFit.cover,
                              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded || frame != null) return child;
                                return Shimmer.fromColors(
                                  baseColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  highlightColor: theme.colorScheme.primary.withValues(alpha: 0.25),
                                  child: Container(color: Colors.white),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
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
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.9),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else ...[
                        // Text-only treatment (Expanded)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
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
                            child: SingleChildScrollView(
                              child: Text(
                                widget.content,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Interaction Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Divider(height: 32),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: InteractionSection(
                  story: widget.story,
                  showLabels: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
