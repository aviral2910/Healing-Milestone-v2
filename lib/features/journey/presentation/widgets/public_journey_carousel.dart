import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/journey_providers.dart';
import '../../data/models/journey_models.dart';
import 'public_journey_detail_overlay.dart';

class PublicJourneyCarousel extends ConsumerWidget {
  final String userId;
  final String userName;
  
  const PublicJourneyCarousel({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journeysAsync = ref.watch(userJourneysProvider(userId));

    return journeysAsync.when(
      data: (journeys) {
        if (journeys.isEmpty) {
          return const SizedBox.shrink(); // Hide if no journeys
        }

        final theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Journeys',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 136,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: journeys.length,
                itemBuilder: (context, index) {
                  final journey = journeys[index];
                  return _PublicJourneyItem(journey: journey);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _PublicJourneyItem extends StatelessWidget {
  final JourneyModel journey;

  const _PublicJourneyItem({required this.journey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        PublicJourneyDetailOverlay.show(
          context,
          journeyId: journey.id,
          title: journey.title,
          category: journey.category,
          authorName: journey.authorName,
          authorAvatar: journey.authorAvatar,
          authorId: journey.authorUid,
          isMine: false,
          visibility: journey.visibility,
          initialIsFollowing: journey.isFollowing,
        );
      },
      child: Container(
        width: 170, // Slightly wider for the content
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616), // Very dark background matching image
          borderRadius: BorderRadius.circular(24), // Highly rounded corners
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.4), // Golden border
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Avatar & Name ---
            Row(
              children: [
                AppAvatar(
                  imageUrl: journey.authorAvatar,
                  radius: 12,
                  role: journey.authorRole,
                  isAnonymous: journey.authorAvatar == null,
                  showRing: true,
                  ringColor: primaryColor.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    journey.authorName ?? 'Anonymous',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // --- 2. Journey Title ---
            Text(
              journey.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 12),

            // --- 3. Category ---
            Row(
              children: [
                Icon(
                  Icons.folder_rounded,
                  size: 14,
                  color: primaryColor,
                ), // Filled folder
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    journey.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
