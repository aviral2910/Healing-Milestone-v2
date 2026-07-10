import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/post_display_widget.dart';
import '../../../../core/models/milestone.dart';

import '../../../../core/data/dummy_milestones.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({Key? key}) : super(key: key);

  String _truncateContent(String text) {
    if (text.length <= 150) return text;
    // Find the last space before 150 characters to avoid cutting words in half
    int end = text.lastIndexOf(' ', 150);
    if (end == -1) end = 150;
    return '${text.substring(0, end)}...';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifiedMilestones = ref.watch(dummyMilestonesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: const Text('Healing Milestones', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: const Color(0xFF242424),
                height: 1.0,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final milestone = verifiedMilestones[index];
                return GestureDetector(
                  onTap: () => context.push('/story/${milestone.milestoneId}'),
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Clean Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFF242424),
                                backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=${milestone.authorId}'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          milestone.isAnonymous ? 'Anonymous' : 'Author ${milestone.authorId}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                        ),
                                        if (milestone.isVerified) ...[
                                          const SizedBox(width: 4),
                                          Icon(Icons.verified, color: Theme.of(context).primaryColor, size: 16),
                                        ]
                                      ],
                                    ),
                                    const Text(
                                      '2 hours ago • #Recovery',
                                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_horiz, color: Colors.grey),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        
                        // The Title
                        if (milestone.title.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                            child: Text(
                              milestone.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        // The Immutable Post Widget Template (Truncated for feed)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: milestone.templateStyle == 'imageCentric'
                                ? AspectRatio(
                                    aspectRatio: 1.0, // Bound height for Expanded widgets
                                    child: PostDisplayWidget(
                                      content: _truncateContent(milestone.content),
                                      authorName: milestone.isAnonymous ? 'Anonymous' : 'Author ${milestone.authorId}',
                                      templateStyle: milestone.templateStyle,
                                      logoUrl: null,
                                    ),
                                  )
                                : PostDisplayWidget(
                                    content: _truncateContent(milestone.content),
                                    authorName: milestone.isAnonymous ? 'Anonymous' : 'Author ${milestone.authorId}',
                                    templateStyle: milestone.templateStyle,
                                    logoUrl: null,
                                  ),
                          ),
                        ),

                        // Interaction Footer
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              _InteractionButton(icon: Icons.favorite_border, label: '2.4k', color: Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 24),
                              _InteractionButton(icon: Icons.chat_bubble_outline, label: '142', color: Colors.grey),
                              const Spacer(),
                              _InteractionButton(icon: Icons.share_outlined, label: 'Share', color: Colors.grey),
                            ],
                          ),
                        ),
                        
                        // Thick modern divider to clearly separate posts
                        const SizedBox(height: 8),
                        Container(height: 8, color: Colors.black),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
              childCount: verifiedMilestones.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create'),
        icon: const Icon(Icons.add),
        label: const Text('Share Journey'),
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InteractionButton({
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
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

