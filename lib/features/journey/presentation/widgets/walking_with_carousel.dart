import '../screens/journey_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/journey_providers.dart';
import '../../data/models/journey_models.dart';
import 'public_journey_detail_overlay.dart';
import '../screens/walking_with_screen.dart';

class WalkingWithCarousel extends ConsumerWidget {
  final dynamic provider;
  final String title;
  
  const WalkingWithCarousel({
    super.key, 
    required this.provider, 
    this.title = 'Following',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<JourneyModel>> followingAsync = ref.watch(provider);

    return followingAsync.when(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => WalkingWithScreen(
                            provider: provider,
                            title: title,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: Text(
                        'View all',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                  return _WalkingWithItem(journey: journey, isFollowing: journey.isFollowing);
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
  final bool isFollowing;
  final JourneyModel journey;

  const _WalkingWithItem({required this.journey, this.isFollowing = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        if (journey.authorUid != null &&
            journey.authorUid == FirebaseAuth.instance.currentUser?.uid) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JourneyDetailScreen(
                journeyId: journey.id,
                title: journey.title,
                categories: journey.categories,
                visibility: journey.visibility,
              ),
            ),
          );
        } else {
          PublicJourneyDetailOverlay.show(
            context,
            journeyId: journey.id,
            title: journey.title,
            categories: journey.categories,
            authorName: journey.authorName,
            authorAvatar: journey.authorAvatar,
            authorId: journey.authorUid,
            isMine: false,
            visibility: journey.visibility,
            initialIsFollowing: isFollowing,
          );
        }
      },
      child: Container(
        width: 170, // Slightly wider for the content
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(
            0xFF161616,
          ).withValues(alpha: 0.4), // Very dark background matching image
          borderRadius: BorderRadius.circular(24), // Highly rounded corners
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.2), // Golden border
            width: .5,
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
                  isAnonymous:
                      journey.visibility == MilestoneVisibility.anonymous,
                  showRing: true,
                  // ringColor: primaryColor.withValues(alpha: 0.4),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: (journey.categories.isNotEmpty ? journey.categories : ['General']).map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Text(
                      '#${cat.toUpperCase()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        fontSize: 8,
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
