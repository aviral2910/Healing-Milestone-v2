import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/journey/presentation/providers/time_capsule_provider.dart';
import 'package:healing_milestones/features/journey/presentation/widgets/time_capsule_card.dart';

class TimeCapsuleListScreen extends ConsumerWidget {
  const TimeCapsuleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final capsulesAsync = ref.watch(myTimeCapsulesProvider);
    final baseColor = const Color(0xFFFFC107);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Capsule Vault', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/create-time-capsule'),
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
                  Icon(Icons.lock_clock_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Your vault is empty.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push('/create-time-capsule'),
                    icon: const Icon(Icons.edit_note, color: Colors.black87),
                    label: const Text('Seal a Memory', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
                showDelete: true,
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
                  
                  ref.read(myTimeCapsulesProvider.notifier).openCapsule(capsule.id);
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return Scaffold(
                        backgroundColor: const Color(0xFFFFC107).withOpacity(0.1),
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        body: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.mark_email_read_rounded, size: 64, color: Color(0xFFFFC107)),
                                const SizedBox(height: 24),
                                Text(
                                  capsule.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Written on " + capsule.createdAt.toLocal().toString().split(' ')[0],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                ),
                                const SizedBox(height: 32),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      capsule.content,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        height: 1.6,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error loading capsules: $error')),
      ),
    );
  }
}
