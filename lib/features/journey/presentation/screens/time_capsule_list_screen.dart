import 'package:healing_milestones/core/models/time_capsule_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/journey/presentation/widgets/create_time_capsule_overlay.dart';
import 'package:healing_milestones/features/journey/presentation/providers/time_capsule_provider.dart';
import 'package:healing_milestones/features/journey/presentation/widgets/time_capsule_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:healing_milestones/features/journey/presentation/widgets/audio_player_widget.dart';
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

                  showGeneralDialog(
                    context: context,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return FutureBuilder<TimeCapsuleModel>(
                        future: () async {
                          final notifier = ref.read(myTimeCapsulesProvider.notifier);
                          if (!capsule.isOpened) {
                            await notifier.openCapsule(capsule.id);
                          }
                          return notifier.fetchCapsule(capsule.id);
                        }(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Scaffold(
                              backgroundColor: theme.colorScheme.surface,
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                leading: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                              body: const Center(child: CircularProgressIndicator()),
                            );
                          }
                          
                          if (snapshot.hasError) {
                            return Scaffold(
                              backgroundColor: theme.colorScheme.surface,
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                leading: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                              body: const Center(child: Text("Failed to open time capsule.")),
                            );
                          }
                          
                          final capsuleToShow = snapshot.data!;
                          return Scaffold(
                        backgroundColor: theme.colorScheme.surface,
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
                                Icon(
                                  Icons.mark_email_read_rounded,
                                  size: 64,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  capsuleToShow.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Written on " +
                                      capsuleToShow.createdAt
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0],
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                                const SizedBox(height: 32),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        if (capsuleToShow.mediaUrl != null && capsuleToShow.mediaUrl!.isNotEmpty) ...[
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: CachedNetworkImage(
                                              imageUrl: capsuleToShow.mediaUrl!,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                height: 200,
                                                color: theme.colorScheme.surface,
                                                child: const Center(child: CircularProgressIndicator()),
                                              ),
                                              errorWidget: (context, url, error) => const Icon(Icons.error),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                        ],
                                        Text(
                                          capsuleToShow.content ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                height: 1.6,
                                                fontStyle: FontStyle.italic,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (capsuleToShow.audioUrl != null && capsuleToShow.audioUrl!.isNotEmpty) ...[
                                          const SizedBox(height: 32),
                                          AudioPlayerWidget(audioUrl: capsuleToShow.audioUrl!, isMini: false),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                        },
                      );
                    },
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
