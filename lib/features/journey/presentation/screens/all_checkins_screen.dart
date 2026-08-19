import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/journey_providers.dart';
import '../widgets/timeline_node.dart';
import '../../../../core/presentation/widgets/healing_error_view.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

class AllCheckinsScreen extends ConsumerStatefulWidget {
  const AllCheckinsScreen({super.key});

  @override
  ConsumerState<AllCheckinsScreen> createState() => _AllCheckinsScreenState();
}

class _AllCheckinsScreenState extends ConsumerState<AllCheckinsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkinsAsync = ref.watch(allCheckinsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'All Check-Ins',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withValues(alpha: 0.1),
            height: 1.0,
          ),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            ref.read(allCheckinsProvider.notifier).fetchNextPage();
          }
          return false;
        },
        child: checkinsAsync.when(
          data: (state) {
            final checkins = state.items;
            if (checkins.isEmpty) {
              return Center(
                child: Text(
                  'No check-ins available.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.only(top: 24, bottom: 100, left: 24, right: 24),
              itemCount: checkins.length + (state.isEnd ? 0 : 1),
              itemBuilder: (context, index) {
                if (index == checkins.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: AppLoader.small()),
                  );
                }
                
                final milestone = checkins[index];
                final isFirst = index == 0;
                final isLast = index == checkins.length - 1 && state.isEnd;

                return TimelineNode(
                  milestone: milestone,
                  
                  isReversed: true,
                );
              },
            );
          },
          loading: () => const Center(child: AppLoader()),
          error: (err, stack) => HealingErrorView(
            error: err,
            onRetry: () => ref.invalidate(allCheckinsProvider),
          ),
        ),
      ),
    );
  }
}
