import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../../core/models/educational_content_model.dart';
import '../../../../logo/healing_milestone_logo.dart';

class HealthAwarenessScreen extends ConsumerWidget {
  const HealthAwarenessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eduContent = ref.watch(dummyEduContentProvider);
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          centerTitle: false,
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          title: HealingMilestonesLogoWidget(),
          actions: const [
            SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 24.0, bottom: 24.0),
            child: Text(
              'Educational Resources',
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final content = eduContent[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _EduContentCard(content: content),
                );
              },
              childCount: eduContent.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _EduContentCard extends StatelessWidget {
  final EducationalContentModel content;

  const _EduContentCard({Key? key, required this.content}) : super(key: key);

  IconData _getIconForType() {
    switch (content.type) {
      case EducationalContentType.video:
        return Icons.play_circle_fill;
      case EducationalContentType.pdf:
        return Icons.picture_as_pdf;
      case EducationalContentType.webinar:
        return Icons.live_tv;
      case EducationalContentType.podcast:
        return Icons.podcasts;
      default:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
      ),
      child: Row(
        children: [
          // Thumbnail
          if (content.thumbnailUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                content.thumbnailUrl!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getIconForType(), size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        content.type.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFF5F5F7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.verified, color: theme.colorScheme.primary, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          content.doctorName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFA1A1A6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
