import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/milestone.dart';
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
              color: const Color(0xFF141414).withOpacity(0.8),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Reading Settings',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('Text Size', style: TextStyle(color: Colors.grey)),
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
                    style: TextStyle(color: Colors.grey)),
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Look up the specific milestone from the dummy provider
    final milestones = ref.watch(dummyMilestonesProvider);
    final milestoneIndex = milestones.indexWhere((m) => m.milestoneId == milestoneId);
    
    if (milestoneIndex == -1) {
      return const Scaffold(
        body: Center(child: Text('Milestone not found', style: TextStyle(color: Colors.white))),
      );
    }
    
    final milestone = milestones[milestoneIndex];

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_display),
                onPressed: () => _showAccessibilityBottomSheet(context, ref),
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clean, Editorial Typography Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.title,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF242424),
                            backgroundImage: NetworkImage(
                                'https://api.dicebear.com/7.x/avataaars/png?seed=${milestone.authorId}'),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    milestone.isAnonymous
                                        ? 'Anonymous'
                                        : 'Author ${milestone.authorId}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15),
                                  ),
                                  if (milestone.isVerified) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.verified,
                                        color: Theme.of(context).primaryColor, size: 14),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Published just now • 5 min read',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFF242424), thickness: 1, height: 1),
                
                // The Immutable Post Widget Template - FULL WIDTH for immersive reading
                milestone.templateStyle == 'imageCentric'
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
                    : PostDisplayWidget(
                        content: milestone.content,
                        authorName: milestone.isAnonymous
                            ? 'Anonymous'
                            : 'Author ${milestone.authorId}',
                        templateStyle: milestone.templateStyle,
                        logoUrl: null,
                      ),
                
                const Divider(color: Color(0xFF242424), thickness: 1, height: 1),
                const SizedBox(height: 48),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journey Media',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      MilestoneMediaGallery(media: dummyMedia),
                      const SizedBox(height: 48),
                      Text(
                        'Community Q&A',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      QnAThread(milestone: milestone),
                      const SizedBox(height: 100),
                    ],
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
