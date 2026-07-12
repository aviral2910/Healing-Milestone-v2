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
import '../widgets/qna_thread.dart';
import '../../../accessibility/data/accessibility_providers.dart';

import '../../../../core/data/dummy_data.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
    final stories = ref.watch(dummyStoriesProvider);
    final storyIndex = stories.indexWhere((s) => s.storyId == milestoneId);

    if (storyIndex == -1) {
      return const Scaffold(
        body: Center(child: Text('Story not found')),
      );
    }

    final story = stories[storyIndex];
    final theme = Theme.of(context);

    final List<MediaAttachment> dummyMedia = [
      MediaAttachment(
        mediaId: 'm1',
        url:
            'https://images.unsplash.com/photo-1498637841888-108c6b723fcb?q=80&w=3456&auto=format&fit=crop',
        title: 'Morning Light',
        description: 'First day outside.',
        isSensitive: false,
        uploadedAt: DateTime.now(),
      ),
      MediaAttachment(
        mediaId: 'm2',
        url:
            'https://images.unsplash.com/photo-1518182170546-076616fd4625?q=80&w=3540&auto=format&fit=crop',
        title: 'Scar Progress',
        description: 'Scar healing well.',
        isSensitive: true,
        uploadedAt: DateTime.now(),
      ),
    ];

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
                          Row(
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
                                      'https://api.dicebear.com/7.x/avataaars/png?seed=${story.authorId}'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          !story.displayAuthorName
                                              ? 'Anonymous'
                                              : 'Author ${story.authorId}',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFF5F5F7),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        UserBadge(
                                          role: story.authorRole,
                                          isVerified: story.isAuthorVerified,
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
                        ],
                      ),
                    ),
                    // Hashtags
                    if (story.hashtagsList.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: story.hashtagsList.map((tag) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () {},
                            color: const Color(0xFFA1A1A6),
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
                          Text(
                            'Journey Media',
                            style: theme.textTheme.headlineLarge
                                ?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 24),
                          MilestoneMediaGallery(media: dummyMedia),
                          const SizedBox(height: 64),
                          Text(
                            'Comments',
                            style: theme.textTheme.headlineLarge
                                ?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 24),
                          QnAThread(milestone: story),
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
  }
}
