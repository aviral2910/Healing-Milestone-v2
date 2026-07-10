import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/milestone.dart';
import '../../../../core/models/media_attachment.dart';
import '../../../feed/presentation/widgets/post_display_widget.dart';
import '../widgets/milestone_media_gallery.dart';
import '../widgets/qna_thread.dart';
import '../../../accessibility/data/accessibility_providers.dart';

class StoryDetailScreen extends ConsumerWidget {
  final String milestoneId;

  const StoryDetailScreen({Key? key, required this.milestoneId}) : super(key: key);

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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                const Text('Reading Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('Text Size', style: TextStyle(color: Colors.grey)),
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(accessibilityProvider);
                    return Slider(
                      value: state.textSizeFactor,
                      min: 0.8,
                      max: 2.0,
                      activeColor: const Color(0xFF00F0FF),
                      onChanged: (val) => ref.read(accessibilityProvider.notifier).updateTextSizeFactor(val),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('Contrast/Opacity', style: TextStyle(color: Colors.grey)),
                Consumer(
                  builder: (context, ref, child) {
                    final state = ref.watch(accessibilityProvider);
                    return Slider(
                      value: state.textOpacity,
                      min: 0.5,
                      max: 1.0,
                      activeColor: const Color(0xFF00FF88),
                      onChanged: (val) => ref.read(accessibilityProvider.notifier).updateTextOpacity(val),
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
    // Dummy Data
    final milestone = Milestone(
      milestoneId: milestoneId,
      authorId: 'a1',
      title: 'Beating the Odds',
      content: 'Every step was painful, but looking back, I would walk that path again. The journey taught me resilience I never knew I possessed. There were days I wanted to give up entirely, but the community lifted me up.',
      templateStyle: 'minimalist',
      isVerified: true,
      createdAt: DateTime.now(),
    );

    final List<MediaAttachment> dummyMedia = [
      MediaAttachment(
        mediaId: 'm1',
        url: 'https://images.unsplash.com/photo-1498637841888-108c6b723fcb?q=80&w=3456&auto=format&fit=crop',
        title: 'Morning Light',
        description: 'First day outside.',
        isSensitive: false,
        uploadedAt: DateTime.now(),
      ),
      MediaAttachment(
        mediaId: 'm2',
        url: 'https://images.unsplash.com/photo-1518182170546-076616fd4625?q=80&w=3540&auto=format&fit=crop',
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
            title: const Text('Milestone Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_display),
                onPressed: () => _showAccessibilityBottomSheet(context, ref),
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Heading
                  Text(
                    milestone.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Author Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF242424),
                        backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=${milestone.authorId}'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        milestone.isAnonymous ? 'Anonymous' : 'Author ${milestone.authorId}',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      if (milestone.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified, color: Theme.of(context).primaryColor, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Content Heading
                  Text(
                    'The Story',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // The Immutable Post Widget Template
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: PostDisplayWidget(
                      content: milestone.content,
                      authorName: milestone.isAnonymous ? 'Anonymous' : 'Author ${milestone.authorId}',
                      templateStyle: milestone.templateStyle,
                      logoUrl: null,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Journey Media',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  MilestoneMediaGallery(media: dummyMedia),
                  const SizedBox(height: 48),
                  Text(
                    'Community Q&A',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  QnAThread(milestone: milestone),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
