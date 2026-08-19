import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/journey_providers.dart';
import '../widgets/public_journey_carousel.dart';
import '../../../../core/widgets/shared_headers.dart';

class PublicUserJourneysScreen extends ConsumerWidget {
  final String userId;
  final String userName;

  const PublicUserJourneysScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final journeysAsync = ref.watch(userJourneysProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text("${userName}'s Journeys"),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: journeysAsync.when(
        data: (journeys) {
          if (journeys.isEmpty) {
            return const Center(child: Text('No journeys available.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 170 / 140, // rough ratio of the card
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: journeys.length,
            itemBuilder: (context, index) {
              return PublicJourneyItem(journey: journeys[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading journeys')),
      ),
    );
  }
}
