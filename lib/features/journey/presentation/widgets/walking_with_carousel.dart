import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/journey_providers.dart';
import '../../data/models/journey_models.dart';
import 'public_journey_detail_overlay.dart';

class WalkingWithCarousel extends ConsumerWidget {
  const WalkingWithCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingJourneysProvider);

    return followingAsync.when(
      data: (journeys) {
        if (journeys.isEmpty) {
          return const SizedBox.shrink(); // Hide if not following anyone
        }

        final theme = Theme.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Walking with...',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'View all',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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
                  return _WalkingWithItem(journey: journey);
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

class _WalkingWithItem extends StatelessWidget {
  final JourneyModel journey;

  const _WalkingWithItem({required this.journey});

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
          isMine: false,
          visibility: journey.visibility,
          initialIsFollowing: true,
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
                Container(
                  padding: const EdgeInsets.all(
                    3,
                  ), // Gap between outer ring and avatar
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.transparent,
                    backgroundImage: journey.authorAvatar != null
                        ? CachedNetworkImageProvider(
                            journey.authorAvatar!,
                            maxHeight: 100,
                          )
                        : null,
                    child: journey.authorAvatar == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: primaryColor,
                          )
                        : null,
                  ),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
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
