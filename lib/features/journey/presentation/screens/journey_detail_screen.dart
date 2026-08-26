import '../../data/models/journey_models.dart';
import 'package:healing_milestones/shared/widgets/qr_share_preview.dart';
import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/healing_error_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/shared/widgets/guest_auth_wall.dart';
import '../../data/providers/journey_providers.dart';
import '../../data/providers/paginated_journey_milestones_provider.dart';
import '../widgets/timeline_node.dart';
import '../widgets/log_milestone_overlay.dart';
import '../widgets/complete_journey_overlay.dart';
import '../widgets/reopen_journey_overlay.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

class JourneyDetailScreen extends ConsumerStatefulWidget {
  final String journeyId;
  final String title;
  final String? category;
  final MilestoneVisibility? visibility;
  final bool isMine;

  const JourneyDetailScreen({
    Key? key,
    required this.journeyId,
    required this.title,
    this.category,
    this.visibility,
    this.isMine = false,
  }) : super(key: key);

  @override
  ConsumerState<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends ConsumerState<JourneyDetailScreen> {
  MilestoneVisibility? _currentVisibility;
  bool _isUpdatingVisibility = false;

  @override
  void initState() {
    super.initState();
    _currentVisibility = widget.visibility;
  }

  IconData _getVisibilityIcon(MilestoneVisibility? vis) {
    switch (vis) {
      case MilestoneVisibility.public: return Icons.public;
      case MilestoneVisibility.private: return Icons.lock_outline;
      case MilestoneVisibility.anonymous: return Icons.masks;
      default: return Icons.public;
    }
  }
  
  String _getVisibilityText(MilestoneVisibility vis) {
    switch (vis) {
      case MilestoneVisibility.public: return 'Public';
      case MilestoneVisibility.private: return 'Private';
      case MilestoneVisibility.anonymous: return 'Anonymous';
    }
  }

  void _showVisibilityBottomSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Icon(Icons.visibility_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text('Journey Visibility', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final vis in MilestoneVisibility.values)
                  ListTile(
                    leading: Icon(_getVisibilityIcon(vis)),
                    title: Text(_getVisibilityText(vis)),
                    trailing: _currentVisibility == vis
                        ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                        : null,
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      if (_currentVisibility != vis) {
                        setState(() { _isUpdatingVisibility = true; });
                        try {
                          await ref.read(journeyRepositoryProvider).updateJourneyVisibility(widget.journeyId, vis);
                          if (mounted) {
                            setState(() { _currentVisibility = vis; });
                            ref.invalidate(userJourneysProvider);
                            ref.invalidate(myJourneysProvider);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update visibility')));
                          }
                        } finally {
                          if (mounted) {
                            setState(() { _isUpdatingVisibility = false; });
                          }
                        }
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            ref.read(paginatedJourneyMilestonesProvider(widget.journeyId).notifier).fetchNextPage();
          }
          return false;
        },
        child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor.withValues(
              alpha: 0.8,
            ),
            actions: [
              if (widget.isMine)
                _isUpdatingVisibility
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: Icon(_getVisibilityIcon(_currentVisibility)),
                        tooltip: 'Change Visibility',
                        onPressed: _showVisibilityBottomSheet,
                      ),
              if (_currentVisibility == MilestoneVisibility.public || _currentVisibility == MilestoneVisibility.anonymous)
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share Journey',
                  onPressed: () {
                    showJourneyShareOptions(context, widget.journeyId, widget.title);
                  },
                ),
              Consumer(
                builder: (context, ref, child) {
                  final milestonesAsync = ref.watch(paginatedJourneyMilestonesProvider(widget.journeyId));
                  final milestones = milestonesAsync.value?.items ?? [];
                  final isCompleted = milestones.isNotEmpty && milestones.first.isClosure;
                  if (isCompleted) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text('Healed', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return IconButton(
                    icon: Icon(Icons.check_circle_outline_rounded, color: theme.colorScheme.primary),
                    tooltip: 'Complete Journey',
                    onPressed: () {
                      if (milestones.length < 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'You need at least 3 check-ins before you can complete this journey!'),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        return;
                      }
                      CompleteJourneyOverlay.show(context, journeyId: widget.journeyId);
                    },
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (widget.category != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.secondary.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        widget.category!.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: theme.scaffoldBackgroundColor),
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Consumer(
            builder: (context, ref, child) {
              final milestonesAsync = ref.watch(
                paginatedJourneyMilestonesProvider(widget.journeyId),
              );
              return milestonesAsync.when(
                data: (state) {
                        final milestones = state.items;
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
                                'Your journey starts here.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to log your first step.',
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

                  // Backend already returns sorted newest first
                  final sortedMilestones = milestones;

                  return SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 8,
                      top: 24,
                      bottom: 100,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final milestone = sortedMilestones[index];
                        return TimelineNode(
                          milestone: milestone,
                          isReversed: true,
                          isHistoricalClosure: milestone.isClosure && index != 0,
                        );
                      }, childCount: sortedMilestones.length),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: AppLoader(),
                    ),
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: HealingErrorView(
                    error: err,
                    onRetry: () => ref.invalidate(paginatedJourneyMilestonesProvider(widget.journeyId)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final milestonesAsync = ref.watch(paginatedJourneyMilestonesProvider(widget.journeyId));
          final milestones = milestonesAsync.value?.items ?? [];
          final isCompleted = milestones.isNotEmpty && milestones.first.isClosure;
          
          if (isCompleted) {
            return FloatingActionButton.extended(
              onPressed: () {
                ReopenJourneyOverlay.show(context, journeyId: widget.journeyId);
              },
              elevation: 8,
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.primary,
              icon: const Icon(Icons.energy_savings_leaf_rounded),
              label: const Text(
                'Resume Journey',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            );
          }
          
          return FloatingActionButton.extended(
            onPressed: () {
              final authState = ref.read(authProvider).value;
              if (authState?.status != AuthStatus.authenticated) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const FractionallySizedBox(
                    heightFactor: 0.85,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      child: GuestAuthWallWidget(
                        title: 'Log a Step',
                        subtitle: 'Create an account to log milestones and track your journey.',
                      ),
                    ),
                  ),
                );
                return;
              }
              LogMilestoneOverlay.show(context, journeyId: widget.journeyId);
            },
            elevation: 8,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Log Step',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
