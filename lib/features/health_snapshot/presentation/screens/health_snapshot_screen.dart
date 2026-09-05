import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/medical_vault/presentation/providers/medical_vault_providers.dart';

class HealthSnapshotScreen extends ConsumerWidget {
  final String snapshotId;

  const HealthSnapshotScreen({
    super.key,
    required this.snapshotId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mixViewsAsync = ref.watch(mixViewsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Snapshot'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/medical-vault'),
        ),
      ),
      body: mixViewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (views) {
          final view = views.firstWhere(
            (v) => v.id == snapshotId,
            orElse: () => throw Exception('Snapshot not found'),
          );

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timeline_rounded, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  view.name,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Journeys: ${view.journeyIds.length} | Reports: ${view.selectedReportIds.length}',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement Share functionality
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share Public Link'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
