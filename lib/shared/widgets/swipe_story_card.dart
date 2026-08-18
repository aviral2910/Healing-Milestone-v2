import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/core/models/user_model.dart';
import 'package:healing_milestones/core/presentation/widgets/user_badge.dart';
import 'package:healing_milestones/core/presentation/widgets/verified_story_badge.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/shared/widgets/interaction_section.dart';
import 'package:intl/intl.dart';

class SwipeStoryCard extends ConsumerStatefulWidget {
  final StoryModel story;
  final String content;
  final VoidCallback onTap;

  const SwipeStoryCard({
    super.key,
    required this.story,
    required this.content,
    required this.onTap,
  });

  @override
  ConsumerState<SwipeStoryCard> createState() => _SwipeStoryCardState();
}

class _SwipeStoryCardState extends ConsumerState<SwipeStoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  List<Color> _getConstantGradient() {
    return [
      const Color(0xFF1c1c1e), // Very dark grey/black iOS style
      const Color(0xFF000000), // Pure black
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userAsync = widget.story.author != null
        ? AsyncData<UserModel?>(widget.story.author)
        : ref.watch(userByIdProvider(widget.story.authorId));

    final hasImage = (widget.story.mainImage.isNotEmpty &&
            widget.story.mainImage.startsWith('http')) ||
        (widget.story.imageAssets.isNotEmpty &&
            widget.story.imageAssets.first.startsWith('http'));

    final String? backgroundImageUrl = (widget.story.mainImage.isNotEmpty &&
            widget.story.mainImage.startsWith('http'))
        ? widget.story.mainImage
        : ((widget.story.imageAssets.isNotEmpty &&
                widget.story.imageAssets.first.startsWith('http'))
            ? widget.story.imageAssets.first
            : null);

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
          color: Colors.black, // Dark base for immersive feel
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background (Image or Gradient)
              if (hasImage && backgroundImageUrl != null)
                CachedNetworkImage(imageUrl: backgroundImageUrl, memCacheWidth: 800, fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: theme.colorScheme.surface),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getConstantGradient(),
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),)
              else
                Container(
                  color: Colors.black, // Pure black for text-only
                ),

              // 2. Dark bottom gradient for perfect text readability (only really needed for images, but good for consistency)
              if (hasImage)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

              // 3. Central Layout for Text-Only Stories (NO SCROLLING)
              if (!hasImage)
                Positioned.fill(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20, // Let text go edge-to-edge
                        top: 24,
                        bottom: 150, // Keep text firmly above the bottom anchor
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Title
                          if (widget.story.heading.isNotEmpty) ...[
                            Text(
                              widget.story.heading,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                          ],

                          // 2. Verified Story Badge below title, right-aligned for text-only
                          if (widget.story.isVerifiedStory) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: const VerifiedStoryBadge(),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 3. Description (Expands to fill space, justified, lower opacity)
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final textStyle = theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75), // Lower opacity
                                  fontWeight: FontWeight.w400,
                                  height: 1.6, // Better line height
                                  fontSize: 16,
                                );
                                final lineHeight = (textStyle?.fontSize ?? 16) * (textStyle?.height ?? 1.6);
                                final availableHeight = constraints.maxHeight - 40; // Safe space for "Read more"
                                final maxLines = (availableHeight / lineHeight).floor();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.story.description,
                                      style: textStyle,
                                      textAlign: TextAlign.justify, // Fixes the "right padding" jagged edge look
                                      maxLines: maxLines > 0 ? maxLines : 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    // 4. Read more text
                                    GestureDetector(
                                      onTap: widget.onTap,
                                      child: Text(
                                        'Read more',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: const Color(0xFFFFD700), // Golden color
                                          fontWeight: FontWeight.w600,
                                        ),
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
                ),

              // 4. Right Vertical Interaction Bar
              Positioned(
                right: 0,
                bottom: 24,
                child: InteractionSection(
                  story: widget.story,
                  showLabels: false,
                  isVertical: true, // Classic TikTok/Reels right-side bar
                ),
              ),

              // 5. Bottom-Left Anchor (Unified for BOTH image and text stories)
              Positioned(
                left: 16,
                right: 72,
                bottom: 24,
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Author Row
                      _buildAuthorRow(context, theme, userAsync, hasImage),
                      const SizedBox(height: 12),

                      // Title (ONLY for image stories)
                      if (hasImage && widget.story.heading.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            widget.story.heading,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Description Snippet (ONLY for image stories)
                      if (hasImage && widget.content.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            widget.content,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 15,
                              height: 1.4,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  blurRadius: 6,
                                )
                              ],
                            ),
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          behavior: HitTestBehavior.deferToChild,
                          child: Text(
                            'Read more',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFFFD700), // Golden
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Hashtags (Golden Theme)
                      if (widget.story.hashtagsList.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: widget.story.hashtagsList.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFFD700)
                                        .withValues(alpha: 0.15),
                                    const Color(0xFFB8860B)
                                        .withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: const Color(0xFFFFD700)
                                      .withValues(alpha: 0.4),
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#$tag',
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorRow(BuildContext context, ThemeData theme,
      AsyncValue<UserModel?> userAsync, bool hasImage) {
    return Row(
      children: [
        AppAvatar(
          imageUrl: userAsync.value?.profilePicture,
          radius: 18,
          role: userAsync.value?.role ?? widget.story.authorRole,
          isAnonymous: !widget.story.displayAuthorName,
          showRing: true,
          ringColor: Colors.white.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 10),
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
                      } else if (displayName != null &&
                          displayName.isNotEmpty) {
                        authorText = displayName;
                      } else if (username != null && username.isNotEmpty) {
                        authorText = '@$username';
                      }

                      return Flexible(
                        child: Text(
                          authorText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                    loading: () => Text(
                      !widget.story.displayAuthorName ? 'Anonymous' : 'Loading...',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                    error: (_, __) => Text(
                      !widget.story.displayAuthorName ? 'Anonymous' : 'Author',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  UserBadge(
                    role: userAsync.value?.role ?? widget.story.authorRole,
                    isVerified: userAsync.value?.isVerified ??
                        widget.story.isAuthorVerified,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(widget.story.publishedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 4,
                        )
                      ],
                    ),
                  ),
                  if (hasImage && widget.story.isVerifiedStory)
                    const VerifiedStoryBadge(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
