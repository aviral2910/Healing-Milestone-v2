import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/post_display_widget.dart';
import '../../../../core/models/milestone.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Milestone> verifiedMilestones = [
      Milestone(
        milestoneId: '1',
        authorId: 'a1',
        title: 'Beating the Odds',
        content: 'Every step was painful, but looking back, I would walk that path again.',
        templateStyle: 'minimalist',
        isVerified: true,
        createdAt: DateTime.now(),
      ),
      Milestone(
        milestoneId: '2',
        authorId: 'a2',
        title: 'New Beginnings',
        content: 'Healing is not linear. It is a journey of a thousand steps.',
        templateStyle: 'glassmorphism',
        isVerified: true,
        createdAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Healing Milestones', style: TextStyle(fontWeight: FontWeight.w800)),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF00F0FF).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final milestone = verifiedMilestones[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: GestureDetector(
                            onTap: () => context.push('/story/${milestone.milestoneId}'),
                            child: Hero(
                              tag: 'milestone-${milestone.milestoneId}',
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF141414),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Premium Header
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
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
                                                        const Icon(Icons.verified, color: Color(0xFF00F0FF), size: 16),
                                                      ]
                                                    ],
                                                  ),
                                                  const Text(
                                                    '2 hours ago • #Recovery',
                                                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
                                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
                                          child: Text(
                                            milestone.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),

                                      // The Immutable Post Widget Template
                                      ClipRRect(
                                        child: PostDisplayWidget(
                                          content: milestone.content,
                                          authorName: milestone.isAnonymous ? 'Anonymous' : 'Author ${milestone.authorId}',
                                          templateStyle: milestone.templateStyle,
                                          logoUrl: null,
                                        ),
                                      ),

                                      // Interaction Footer
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                        child: Row(
                                          children: [
                                            _InteractionButton(icon: Icons.favorite_border, label: '2.4k', color: const Color(0xFF00FF88)),
                                            const SizedBox(width: 24),
                                            _InteractionButton(icon: Icons.chat_bubble_outline, label: '142', color: Colors.grey),
                                            const Spacer(),
                                            _InteractionButton(icon: Icons.share_outlined, label: 'Share', color: Colors.grey),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: verifiedMilestones.length,
              ),
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

