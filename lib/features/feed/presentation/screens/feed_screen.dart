import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/logo/healing_milestone_logo.dart';
import '../widgets/post_display_widget.dart';
import '../../../../core/data/dummy_milestones.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({Key? key}) : super(key: key);

  String _truncateContent(String text, int length) {
    if (text.length <= length) return text;
    int end = text.lastIndexOf(' ', length);
    if (end == -1) end = length;
    return '${text.substring(0, end)}...';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMilestones = ref.watch(dummyMilestonesProvider);
    final theme = Theme.of(context);

    // Dummy logic to split into categories
    final trending = allMilestones.take(4).toList();
    final miracles = allMilestones.reversed.take(4).toList();
    final allStories = allMilestones;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor:
                theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
            elevation: 0,
            title: const HealingMilestonesLogoWidget(),
            centerTitle: true,
          ),

          // Horizontal Category 1
          SliverToBoxAdapter(
            child: _HorizontalCategorySection(
              title: 'Trending Stories',
              milestones: trending,
              truncateContent: _truncateContent,
            ),
          ),

          // Horizontal Category 2
          SliverToBoxAdapter(
            child: _HorizontalCategorySection(
              title: 'Miracle Recoveries',
              milestones: miracles,
              truncateContent: _truncateContent,
            ),
          ),

          // Divider for the main feed
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, top: 64.0, bottom: 24.0),
              child: Text(
                'All Stories',
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
              ),
            ),
          ),

          // Infinite Vertical Scrolling Feed
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final milestone = allStories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: _FeedCard(
                      milestone: milestone,
                      onTap: () =>
                          context.push('/story/${milestone.milestoneId}'),
                      content: _truncateContent(milestone.content, 150),
                    ),
                  );
                },
                childCount: allStories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
    );
  }
}

class _HorizontalCategorySection extends StatelessWidget {
  final String title;
  final List<dynamic> milestones;
  final String Function(String, int) truncateContent;

  const _HorizontalCategorySection({
    Key? key,
    required this.title,
    required this.milestones,
    required this.truncateContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 56.0, bottom: 24.0),
          child: Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
          ),
        ),
        SizedBox(
          height:
              350, // Height accommodates 180px image + title + 2 line description
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: milestones.length,
            itemBuilder: (context, index) {
              final milestone = milestones[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 340, // Increased width for horizontal cards
                  child: _HorizontalFeedCard(
                    milestone: milestone,
                    onTap: () =>
                        context.push('/story/${milestone.milestoneId}'),
                    content: truncateContent(milestone.content, 100),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HorizontalFeedCard extends StatefulWidget {
  final dynamic milestone;
  final VoidCallback onTap;
  final String content;

  const _HorizontalFeedCard({
    Key? key,
    required this.milestone,
    required this.onTap,
    required this.content,
  }) : super(key: key);

  @override
  State<_HorizontalFeedCard> createState() => _HorizontalFeedCardState();
}

class _HorizontalFeedCardState extends State<_HorizontalFeedCard>
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            color: const Color(
                0xFF151515), // Slightly lighter than pure black for depth
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E1E), Color(0xFF0F0F0F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Header (Top of the card)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  'https://picsum.photos/seed/${widget.milestone.authorId}/400/200',
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),

              // Author Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      backgroundImage: NetworkImage(
                          'https://api.dicebear.com/7.x/avataaars/png?seed=${widget.milestone.authorId}'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.milestone.isAnonymous
                                  ? 'Anonymous'
                                  : 'Author ${widget.milestone.authorId}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 13,
                                color: const Color(0xFFA1A1A6), // Titanium
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.milestone.isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified,
                                color: theme.colorScheme.primary,
                                size: 14), // Golden
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Title Header
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.milestone.title.isNotEmpty
                            ? widget.milestone.title
                            : 'A Healing Journey',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 20,
                          color: const Color(0xFFF5F5F7), // Frost white
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: const Color(0xFFA1A1A6), // Titanium
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Interaction Footer
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    _InteractionButton(
                        icon: Icons.favorite_border,
                        label: '2.4k',
                        color: theme.colorScheme.primary), // Golden
                    const SizedBox(width: 16),
                    _InteractionButton(
                        icon: Icons.chat_bubble_outline,
                        label: '142',
                        color: const Color(0xFFA1A1A6)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// The original massive vertical _FeedCard remains unchanged below
// -------------------------------------------------------------

class _FeedCard extends StatefulWidget {
  final dynamic milestone;
  final VoidCallback onTap;
  final String content;

  const _FeedCard({
    Key? key,
    required this.milestone,
    required this.onTap,
    required this.content,
  }) : super(key: key);

  @override
  State<_FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<_FeedCard>
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
                          'https://api.dicebear.com/7.x/avataaars/png?seed=${widget.milestone.authorId}'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.milestone.isAnonymous
                                    ? 'Anonymous'
                                    : 'Author ${widget.milestone.authorId}',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontSize: 16),
                              ),
                              if (widget.milestone.isVerified) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.verified,
                                    color: theme.colorScheme.primary, size: 18),
                              ]
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '2 hours ago • #Recovery',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // The Title
              if (widget.milestone.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 16.0),
                  child: Text(
                    widget.milestone.title,
                    style:
                        theme.textTheme.headlineLarge?.copyWith(fontSize: 24),
                  ),
                ),

              // The Immutable Post Widget Template (Truncated for feed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.milestone.templateStyle == 'imageCentric'
                      ? AspectRatio(
                          aspectRatio: 1.0,
                          child: PostDisplayWidget(
                            content: widget.content,
                            authorName: widget.milestone.isAnonymous
                                ? 'Anonymous'
                                : 'Author ${widget.milestone.authorId}',
                            templateStyle: widget.milestone.templateStyle,
                            logoUrl: null,
                          ),
                        )
                      : PostDisplayWidget(
                          content: widget.content,
                          authorName: widget.milestone.isAnonymous
                              ? 'Anonymous'
                              : 'Author ${widget.milestone.authorId}',
                          templateStyle: widget.milestone.templateStyle,
                          logoUrl: null,
                        ),
                ),
              ),

              // Interaction Footer
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    _InteractionButton(
                        icon: Icons.favorite_border,
                        label: '2.4k',
                        color: theme.colorScheme.secondary),
                    const SizedBox(width: 24),
                    _InteractionButton(
                        icon: Icons.chat_bubble_outline,
                        label: '142',
                        color: theme.textTheme.bodySmall!.color!),
                    const Spacer(),
                    Icon(Icons.bookmark_border,
                        color: theme.textTheme.bodySmall!.color!, size: 22),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    );
  }
}
