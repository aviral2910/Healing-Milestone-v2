import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/media_attachment.dart';
import '../../../feed/presentation/widgets/post_display_widget.dart';
import '../widgets/milestone_media_gallery.dart';
import '../widgets/qna_thread.dart';
import '../../../accessibility/data/accessibility_providers.dart';

import '../../../../core/data/dummy_milestones.dart';

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
                const Text('Text Size', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
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
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
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
    final milestones = ref.watch(dummyMilestonesProvider);
    final milestoneIndex = milestones.indexWhere((m) => m.milestoneId == milestoneId);
    
    if (milestoneIndex == -1) {
      return const Scaffold(
        body: Center(child: Text('Milestone not found')),
      );
    }
    
    final milestone = milestones[milestoneIndex];
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
          CustomScrollView(
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
                    onPressed: () => _showAccessibilityBottomSheet(context, ref),
                  )
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Massive Editorial Typography Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone.title,
                            style: theme.textTheme.headlineLarge?.copyWith(
                                  fontSize: 40,
                                  height: 1.1,
                                ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: theme.colorScheme.surface,
                                backgroundImage: NetworkImage(
                                    'https://api.dicebear.com/7.x/avataaars/png?seed=${milestone.authorId}'),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        milestone.isAnonymous
                                            ? 'Anonymous'
                                            : 'Author ${milestone.authorId}',
                                        style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                                      ),
                                      if (milestone.isVerified) ...[
                                        const SizedBox(width: 6),
                                        Icon(Icons.verified,
                                            color: theme.colorScheme.primary, size: 18),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Published just now • 5 min read',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // The Immutable Post Widget Template - NO DIVIDERS
                    // Encased in a beautiful midnight matte if it's minimal
                    Container(
                      color: theme.colorScheme.surface,
                      width: double.infinity,
                      child: milestone.templateStyle == 'imageCentric'
                        ? AspectRatio(
                            aspectRatio: 1.0,
                            child: PostDisplayWidget(
                              content: milestone.content,
                              authorName: milestone.isAnonymous
                                  ? 'Anonymous'
                                  : 'Author ${milestone.authorId}',
                              templateStyle: milestone.templateStyle,
                              logoUrl: null,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 8.0),
                            child: PostDisplayWidget(
                                content: milestone.content,
                                authorName: milestone.isAnonymous
                                    ? 'Anonymous'
                                    : 'Author ${milestone.authorId}',
                                templateStyle: milestone.templateStyle,
                                logoUrl: null,
                              ),
                        ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Journey Media',
                            style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 24),
                          MilestoneMediaGallery(media: dummyMedia),
                          const SizedBox(height: 64),
                          Text(
                            'Community Q&A',
                            style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 24),
                          QnAThread(milestone: milestone),
                          const SizedBox(height: 120), // Padding for sticky bottom bar
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Sticky Bottom Action Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                child: Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.7),
                    border: const Border(top: BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                  padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _BottomAction(icon: Icons.favorite_border, label: '2.4k', color: theme.colorScheme.secondary),
                      const SizedBox(width: 32),
                      _BottomAction(icon: Icons.chat_bubble_outline, label: '142', color: theme.textTheme.bodySmall!.color!),
                      const Spacer(),
                      _BottomAction(icon: Icons.share_outlined, label: 'Share', color: theme.textTheme.bodySmall!.color!),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _BottomAction({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
