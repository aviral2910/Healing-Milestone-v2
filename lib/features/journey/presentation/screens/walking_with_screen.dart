import 'journey_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/journey_models.dart';
import '../../data/providers/journey_providers.dart';
import '../widgets/public_journey_detail_overlay.dart';

class WalkingWithScreen extends ConsumerWidget {
  const WalkingWithScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final followingAsync = ref.watch(followingJourneysProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Walking With',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withValues(alpha: 0.1),
            height: 1.0,
          ),
        ),
      ),
      body: followingAsync.when(
        data: (journeys) {
          if (journeys.isEmpty) {
            return Center(
              child: Text(
                'Not walking with anyone yet.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: journeys.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _WalkingWithListItem(journey: journeys[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error loading journeys.',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }
}

class _WalkingWithListItem extends StatelessWidget {
  final JourneyModel journey;
  const _WalkingWithListItem({required this.journey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        if (journey.authorUid != null && journey.authorUid == FirebaseAuth.instance.currentUser?.uid) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JourneyDetailScreen(
                journeyId: journey.id,
                title: journey.title,
                category: journey.category,
              ),
            ),
          );
        } else {
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
            initialIsFollowing: true,
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161616), // Match feed aesthetic
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            AppAvatar(
              imageUrl: journey.authorAvatar,
              radius: 24,
              role: journey.authorRole,
              isAnonymous: journey.authorAvatar == null,
              showRing: true,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    journey.authorName ?? 'Anonymous',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.folder_rounded,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          journey.title,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.dividerColor,
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
