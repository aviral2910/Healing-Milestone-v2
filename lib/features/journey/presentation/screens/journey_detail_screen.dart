import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/journey_providers.dart';
import '../widgets/timeline_node.dart';
import '../widgets/log_milestone_overlay.dart';

class JourneyDetailScreen extends ConsumerWidget {
  final String journeyId;
  final String title;
  final String? category;

  const JourneyDetailScreen({
    Key? key,
    required this.journeyId,
    required this.title,
    this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final milestonesAsync = ref.watch(journeyMilestonesProvider(journeyId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (category != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 0.5),
                      ),
                      child: Text(
                        category!.toUpperCase(),
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
                  Container(
                    color: theme.scaffoldBackgroundColor,
                  ),
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
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
              
              // Sort newest first (reverse chronological)
              final reversedMilestones = milestones.toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                
              return SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 8, top: 24, bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final milestone = reversedMilestones[index];
                      return TimelineNode(
                        milestone: milestone,
                        isReversed: true,
                      );
                    },
                    childCount: reversedMilestones.length,
                  ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          LogMilestoneOverlay.show(context, journeyId: journeyId);
        },
        elevation: 8,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Step', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ),
    );
  }
}
