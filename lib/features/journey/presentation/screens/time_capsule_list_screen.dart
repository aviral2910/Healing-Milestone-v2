import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/journey/presentation/widgets/create_time_capsule_overlay.dart';
import 'package:healing_milestones/features/journey/presentation/providers/time_capsule_provider.dart';
import 'package:healing_milestones/features/journey/presentation/screens/time_capsule_detail_screen.dart';
import 'package:healing_milestones/features/journey/presentation/widgets/time_capsule_card.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

class TimeCapsuleListScreen extends ConsumerWidget {
  const TimeCapsuleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final capsulesAsync = ref.watch(myTimeCapsulesProvider);
    final baseColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Time Capsule Vault',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => CreateTimeCapsuleOverlay.show(context),
          ),
        ],
      ),
      body: capsulesAsync.when(
        data: (capsules) {
          if (capsules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_clock_rounded,
                    size: 64,
                    color: baseColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your vault is empty.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: baseColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => CreateTimeCapsuleOverlay.show(context),
                    icon: Icon(
                      Icons.edit_note,
                      color: theme.colorScheme.onPrimary,
                    ),
                    label: Text(
                      'Seal a Memory',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(backgroundColor: baseColor),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: capsules.length,
            padding: const EdgeInsets.only(bottom: 32),
            itemBuilder: (context, index) {
              final capsule = capsules[index];
              return TimeCapsuleCard(
                activeCapsule: capsule,
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Destroy Capsule?'),
                      content: const Text(
                        'Are you sure? This message from your past will be lost forever.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(myTimeCapsulesProvider.notifier)
                                .deleteCapsule(capsule.id);
                            Navigator.pop(dialogContext);
                          },
                          child: Text(
                            'Destroy',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onOpen: () {
                  if (capsule.isLocked && !capsule.isOpened) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Patience! Your future self isn't ready yet."),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimeCapsuleDetailScreen(capsule: capsule),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: const AppLoader()),
        error: (error, stack) =>
            Center(child: Text('Error loading capsules: $error')),
      ),
    );
  }
}
