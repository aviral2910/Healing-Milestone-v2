import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:healing_milestones/core/models/time_capsule_model.dart';
import 'package:healing_milestones/features/journey/presentation/providers/time_capsule_provider.dart';
import 'package:healing_milestones/features/journey/presentation/widgets/audio_player_widget.dart';

class TimeCapsuleDetailScreen extends ConsumerStatefulWidget {
  final TimeCapsuleModel capsule;

  const TimeCapsuleDetailScreen({Key? key, required this.capsule}) : super(key: key);

  @override
  ConsumerState<TimeCapsuleDetailScreen> createState() => _TimeCapsuleDetailScreenState();
}

class _TimeCapsuleDetailScreenState extends ConsumerState<TimeCapsuleDetailScreen> {
  late Future<TimeCapsuleModel> _capsuleFuture;

  @override
  void initState() {
    super.initState();
    _capsuleFuture = _fetchAndOpen();
  }

  Future<TimeCapsuleModel> _fetchAndOpen() async {
    final notifier = ref.read(myTimeCapsulesProvider.notifier);
    if (!widget.capsule.isOpened) {
      await notifier.openCapsule(widget.capsule.id);
    }
    return notifier.fetchCapsule(widget.capsule.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<TimeCapsuleModel>(
        future: _capsuleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to open time capsule."));
          }

          final capsuleToShow = snapshot.data!;

          return Center(
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
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Written on ${capsuleToShow.createdAt.toLocal().toString().split(' ')[0]}",
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
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
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          Text(
                            capsuleToShow.content ?? '',
                            style: theme.textTheme.bodyLarge?.copyWith(
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
          );
        },
      ),
    );
  }
}
