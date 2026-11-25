import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/awareness_providers.dart';
import '../../data/awareness_readiness.dart';
import '../../data/awareness_strings.dart';
import '../../data/emergency_guides_data.dart';
import '../../domain/emergency_guide_model.dart';
import 'cpr_metronome_screen.dart';
import 'emergency_guide_detail_screen.dart';
import 'emergency_readiness_screen.dart';
import 'hands_free_guide_screen.dart';

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
    final s = AwarenessStrings(awarenessState.language);
    final guides = getEmergencyGuides(awarenessState.language);
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    final filteredGuides = guides.where((guide) {
      final q = searchQuery.value.trim().toLowerCase();
      if (q.isEmpty) return true;
      return guide.title.toLowerCase().contains(q) ||
          guide.subtitle.toLowerCase().contains(q) ||
          s.categoryLabel(guide.category).toLowerCase().contains(q);
    }).toList();

    return CustomScrollView(
      key: const PageStorageKey<String>('awareness_scroll_key'),
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        // 1. Top Row: Pill Search Bar + CPR Coach Button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (v) => searchQuery.value = v,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: s.searchHint,
                      hintStyle: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 14, right: 8),
                        child: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: primary.withValues(alpha: 0.85),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      suffixIcon: searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                searchController.clear();
                                searchQuery.value = '';
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.cardColor,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: primary),
                      ),
                    ),
                  ),
                ),
                if (searchQuery.value.trim().isEmpty) ...[
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.cardColor,
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: theme.dividerColor),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
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
                      label: Text(
                        s.cprCoach,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // 2b. Refined Readiness & Badges Card (hidden while searching)
        if (searchQuery.value.trim().isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmergencyReadinessScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      // Top Row: Tier Title + Circular Progress Ring
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  awarenessState.language ==
                                          AwarenessLanguage.hi
                                      ? 'आपातकालीन तैयारी'
                                      : 'EMERGENCY READINESS',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: primary,
                                    letterSpacing: 1.2,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  getReadinessTier(
                                    awarenessState.completedGuideIds.length,
                                    guides.length,
                                    awarenessState.language,
                                  ),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  awarenessState.language ==
                                          AwarenessLanguage.hi
                                      ? 'बैज देखने के लिए टैप करें'
                                      : 'Tap to view badges & progress',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: CircularProgressIndicator(
                                    value: guides.isNotEmpty
                                        ? awarenessState
                                                .completedGuideIds.length /
                                            guides.length
                                        : 0,
                                    strokeWidth: 4.5,
                                    backgroundColor: theme.dividerColor,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(primary),
                                  ),
                                ),
                                Text(
                                  '${awarenessState.completedGuideIds.length}/${guides.length}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: theme.dividerColor),
                      const SizedBox(height: 12),
                      // Bottom Row: 4 Evenly Spaced Mini Badge Medallions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: readinessBadges.map((badge) {
                          final done = badge
                              .completedCount(awarenessState.completedGuideIds);
                          final totalInBadge = badge.guideIds.length;
                          final unlocked = done == totalInBadge;
                          return Expanded(
                            child: Column(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: unlocked
                                        ? primary
                                        : theme.scaffoldBackgroundColor,
                                    border: Border.all(
                                      color: unlocked
                                          ? primary
                                          : theme.dividerColor,
                                      width: 1.3,
                                    ),
                                  ),
                                  child: Icon(
                                    badge.icon,
                                    size: 16,
                                    color: unlocked
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  unlocked ? '✓' : '$done/$totalInBadge',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: unlocked
                                        ? primary
                                        : theme.colorScheme.onSurface
                                            .withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Compact 1-line Guideline Note
        if (searchQuery.value.trim().isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      s.disclaimer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 3. First-Aid Guides Header + Language Toggle (EN | हिं)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    s.firstAidTitle,
                    style: theme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _LanguagePill(
                  current: awarenessState.language,
                  onSelected: (lang) =>
                      ref.read(awarenessProvider.notifier).setLanguage(lang),
                ),
              ],
            ),
          ),
        ),

        if (filteredGuides.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Center(
                child: Text(
                  s.noGuidesFound(searchQuery.value.trim()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final guide = filteredGuides[index];
                  final isPassed =
                      awarenessState.completedGuideIds.contains(guide.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _EmergencyGuideCard(
                      guide: guide,
                      categoryLabel: s.categoryLabel(guide.category),
                      isPassed: isPassed,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EmergencyGuideDetailScreen(guide: guide),
                          ),
                        );
                      },
                      onHandsFreeTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HandsFreeGuideScreen(guide: guide),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: filteredGuides.length,
              ),
            ),
          ),

        SliverToBoxAdapter(
          child: SizedBox(
            height: searchQuery.value.trim().isNotEmpty ? 24 : 100,
          ),
        ),
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  final AwarenessLanguage current;
  final ValueChanged<AwarenessLanguage> onSelected;

  const _LanguagePill({
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AwarenessLanguage.values.map((lang) {
          final selected = lang == current;
          return GestureDetector(
            onTap: () => onSelected(lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? primary.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                lang.shortLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmergencyGuideCard extends StatelessWidget {
  final EmergencyGuide guide;
  final String categoryLabel;
  final bool isPassed;
  final VoidCallback onTap;
  final VoidCallback onHandsFreeTap;

  const _EmergencyGuideCard({
    required this.guide,
    required this.categoryLabel,
    required this.isPassed,
    required this.onTap,
    required this.onHandsFreeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
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
                  Row(
                    children: [
                      Text(
                        categoryLabel.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: primary,
                          letterSpacing: 1.1,
                          fontSize: 10,
                        ),
                      ),
                      if (isPassed) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.verified, size: 13, color: primary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    guide.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Quick 1-tap Hands-Free Voice launch
            IconButton(
              tooltip: 'Start Hands-Free Voice Guide',
              style: IconButton.styleFrom(
                backgroundColor: primary.withValues(alpha: 0.10),
              ),
              onPressed: onHandsFreeTap,
              icon: Icon(
                Icons.volume_up_rounded,
                size: 19,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
