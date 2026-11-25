import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../../core/models/educational_content_model.dart';
import '../../data/awareness_providers.dart';
import '../../data/emergency_guides_data.dart';
import '../../domain/emergency_guide_model.dart';
import 'cpr_metronome_screen.dart';
import 'emergency_guide_detail_screen.dart';

class HealthAwarenessScreen extends HookConsumerWidget {
  final ScrollController? scrollController;
  final bool isActiveTab;
  final VoidCallback? onSearchTapped;

  const HealthAwarenessScreen({
    super.key,
    this.scrollController,
    this.isActiveTab = true,
    this.onSearchTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useAutomaticKeepAlive();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final awarenessState = ref.watch(awarenessProvider);
    final eduContent = ref.watch(dummyEduContentProvider);

    return CustomScrollView(
      key: const PageStorageKey<String>('awareness_scroll_key'),
      controller: scrollController,
      slivers: [
        // Top Emergency Action Row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(16),
                            ),
                            onTap: () => launchEmergencyDialer(
                              context,
                              awarenessState.emergencyNumber,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.call_outlined,
                                    size: 18,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'SOS ${awarenessState.emergencyNumber}',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.25),
                        ),
                        InkWell(
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(16),
                          ),
                          onTap: () => _showRegionPickerSheet(
                            context,
                            ref,
                            awarenessState,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  awarenessState.emergencyRegionCode,
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.cardColor,
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: theme.dividerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CprMetronomeScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.favorite_outline,
                        color: primary,
                        size: 18,
                      ),
                      label: const Text(
                        'CPR Coach',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // First-Aid Guides Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'First-Aid & Emergency',
              style: theme.textTheme.titleLarge,
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final guide = emergencyGuidesData[index];
                final isPassed =
                    awarenessState.completedGuideIds.contains(guide.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EmergencyGuideCard(
                    guide: guide,
                    isPassed: isPassed,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              EmergencyGuideDetailScreen(guide: guide),
                        ),
                      );
                    },
                  ),
                );
              },
              childCount: emergencyGuidesData.length,
            ),
          ),
        ),

        // Educational Resources Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Educational Resources',
              style: theme.textTheme.titleLarge,
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final content = eduContent[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EduContentCard(
                    content: content,
                    onTap: () => _showEduContentSheet(context, content),
                  ),
                );
              },
              childCount: eduContent.length,
            ),
          ),
        ),

        // Subtle Disclaimer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            child: Text(
              'For educational & emergency reference only. Not a substitute for professional medical care.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showRegionPickerSheet(
    BuildContext context,
    WidgetRef ref,
    AwarenessState state,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final customController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Emergency Number & Region',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Choose the local emergency number for your area.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              ...emergencyRegions.map((opt) {
                final selected = state.emergencyNumber == opt.number &&
                    state.emergencyRegionCode == opt.code;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      ref
                          .read(awarenessProvider.notifier)
                          .setEmergencyRegion(opt.number, opt.code);
                      Navigator.pop(sheetCtx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? primary.withValues(alpha: 0.12)
                            : theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? primary : theme.dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              opt.number,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opt.region,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle, color: primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: customController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Or enter custom number...',
                        isDense: true,
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () {
                      final num = customController.text.trim();
                      if (num.isNotEmpty) {
                        ref
                            .read(awarenessProvider.notifier)
                            .setEmergencyRegion(num, 'CUSTOM');
                        Navigator.pop(sheetCtx);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEduContentSheet(
    BuildContext context,
    EducationalContentModel content,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.type.name.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(content.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.verified, color: primary, size: 15),
                const SizedBox(width: 6),
                Text(content.doctorName, style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            Text(content.description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(sheetCtx);
                  final uri = Uri.tryParse(content.url);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open Resource'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyGuideCard extends StatelessWidget {
  final EmergencyGuide guide;
  final bool isPassed;
  final VoidCallback onTap;

  const _EmergencyGuideCard({
    required this.guide,
    required this.isPassed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Icon(guide.category.icon, color: primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.category.label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: primary,
                      letterSpacing: 1.1,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guide.title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    guide.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isPassed ? Icons.verified : Icons.arrow_forward_ios_rounded,
              size: isPassed ? 18 : 15,
              color: isPassed
                  ? primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _EduContentCard extends StatelessWidget {
  final EducationalContentModel content;
  final VoidCallback onTap;

  const _EduContentCard({
    required this.content,
    required this.onTap,
  });

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
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            if (content.thumbnailUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(18)),
                child: CachedNetworkImage(
                  imageUrl: content.thumbnailUrl!,
                  width: 108,
                  height: 108,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_getIconForType(), size: 15, color: primary),
                        const SizedBox(width: 6),
                        Text(
                          content.type.name.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: primary,
                            letterSpacing: 1.1,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      content.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.verified, color: primary, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            content.doctorName,
                            style: theme.textTheme.bodySmall,
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
      ),
    );
  }
}
