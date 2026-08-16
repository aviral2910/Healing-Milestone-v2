import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/journey_providers.dart';
import '../../data/models/journey_models.dart';
import '../../../auth/data/auth_provider.dart';
import 'timeline_node.dart';

class PublicJourneyDetailOverlay extends ConsumerStatefulWidget {
  final String journeyId;
  final String title;
  final String? category;
  final String? authorName;
  final String? authorAvatar;
  final bool isMine;
  final MilestoneVisibility visibility;
  final bool initialIsFollowing;

  const PublicJourneyDetailOverlay({
    Key? key,
    required this.journeyId,
    required this.title,
    this.category,
    this.authorName,
    this.authorAvatar,
    required this.isMine,
    required this.visibility,
    this.initialIsFollowing = false,
  }) : super(key: key);

  @override
  ConsumerState<PublicJourneyDetailOverlay> createState() => _PublicJourneyDetailOverlayState();

  static Future<void> show(
    BuildContext context, {
    required String journeyId,
    required String title,
    String? category,
    String? authorName,
    String? authorAvatar,
    required bool isMine,
    required MilestoneVisibility visibility,
    bool initialIsFollowing = false,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PublicJourneyDetailOverlay(
          journeyId: journeyId,
          title: title,
          category: category,
          authorName: authorName,
          authorAvatar: authorAvatar,
          isMine: isMine,
          visibility: visibility,
          initialIsFollowing: initialIsFollowing,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
    );
  }
}

class _PublicJourneyDetailOverlayState extends ConsumerState<PublicJourneyDetailOverlay> {
  late bool _isFollowing;
  bool _isLoadingFollow = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialIsFollowing;
  }

  Future<void> _toggleFollow() async {
    if (_isLoadingFollow) return;
    setState(() => _isLoadingFollow = true);

    try {
      final repo = ref.read(journeyRepositoryProvider);
      if (_isFollowing) {
        await repo.unfollowJourney(widget.journeyId);
      } else {
        await repo.followJourney(widget.journeyId);
      }
      setState(() {
        _isFollowing = !_isFollowing;
        _isLoadingFollow = false;
      });
      // Optionally refresh the feed
      ref.invalidate(togetherFeedProvider);
    } catch (e) {
      setState(() => _isLoadingFollow = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final milestonesAsync = ref.watch(
      publicJourneyMilestonesProvider(widget.journeyId),
    );
    
    final bool isMyAnonymousJourney = widget.visibility == MilestoneVisibility.anonymous && widget.isMine;

    final String displayAuthor = widget.visibility == MilestoneVisibility.anonymous
        ? (isMyAnonymousJourney ? 'Anonymous (You)' : 'Anonymous')
        : (widget.authorName ?? 'Anonymous');

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Full screen glassmorphism background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
            ),
          ),

          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surface,
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 24),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isMyAnonymousJourney
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: 0.2,
                                        )
                                      : theme.colorScheme.surface.withValues(
                                          alpha: 0.5,
                                        ),
                                  border: Border.all(
                                    color: isMyAnonymousJourney
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.primary.withValues(
                                            alpha: 0.3,
                                          ),
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: isMyAnonymousJourney
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        )
                                      : theme.colorScheme.surface,
                                  backgroundImage:
                                      widget.authorAvatar != null &&
                                          widget.visibility ==
                                              MilestoneVisibility.public
                                      ? CachedNetworkImageProvider(widget.authorAvatar!, maxHeight: 200)
                                      : null,
                                  child:
                                      (widget.authorAvatar == null ||
                                          widget.visibility ==
                                              MilestoneVisibility.anonymous)
                                      ? Icon(
                                          widget.visibility ==
                                                  MilestoneVisibility.anonymous
                                              ? Icons.visibility_off_rounded
                                              : Icons.person_rounded,
                                          color: isMyAnonymousJourney
                                              ? theme.colorScheme.primary
                                              : theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          size: 20,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Journey by',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withValues(alpha: 0.8),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                    ),
                                    Text(
                                      displayAuthor,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.3,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (!widget.isMine)
                                SizedBox(
                                  height: 36,
                                  child: FilledButton.icon(
                                    onPressed: _isLoadingFollow ? null : _toggleFollow,
                                    icon: _isLoadingFollow
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Icon(
                                          _isFollowing ? Icons.directions_walk_rounded : Icons.directions_walk_rounded,
                                          size: 16,
                                        ),
                                    label: Text(
                                      _isFollowing ? 'Walking together' : 'Walk with them',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _isFollowing 
                                          ? theme.colorScheme.primaryContainer 
                                          : theme.colorScheme.primary,
                                      foregroundColor: _isFollowing 
                                          ? theme.colorScheme.onPrimaryContainer 
                                          : theme.colorScheme.onPrimary,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            widget.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (widget.category != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.folder_open_rounded,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.category!.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                milestonesAsync.when(
                  data: (milestones) {
                    if (milestones.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 48,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Journey is empty',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This user hasn\'t logged any public steps here yet.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // Sort newest first
                    final reversedMilestones = milestones.toList()
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    return SliverPadding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 8,
                        top: 24,
                        bottom: 100,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final milestone = reversedMilestones[index];
                          return TimelineNode(
                            milestone: milestone,
                            isReversed: true,
                          );
                        }, childCount: reversedMilestones.length),
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  error: (err, stack) => SliverToBoxAdapter(
                    child: Center(child: Text('Error: $err')),
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
