import 'dart:ui';
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
              child: Text(
                'Walking With...',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 130,
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

    Color getGlowColor(String category) {
      return const Color(0xFFFFC107); // Amber/Yellow color matching screenshot
    }

    IconData getIconForCategory(String category) {
      return Icons.folder_rounded;
    }

    final glowColor = getGlowColor(journey.category);

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
        width: 190,
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.8,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: glowColor.withValues(alpha: 0.5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: glowColor.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundImage: journey.authorAvatar != null
                        ? NetworkImage(journey.authorAvatar!)
                        : null,
                    backgroundColor: glowColor.withValues(alpha: 0.1),
                    child: journey.authorAvatar == null
                        ? Icon(Icons.person_rounded, size: 14, color: glowColor)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    journey.authorName ?? 'Anonymous',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              journey.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  getIconForCategory(journey.category),
                  color: glowColor,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    journey.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: glowColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      fontSize: 9,
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
