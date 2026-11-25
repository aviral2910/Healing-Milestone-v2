import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/awareness_providers.dart';
import '../../data/awareness_strings.dart';
import '../../data/emergency_guides_data.dart';
import '../../domain/emergency_guide_model.dart';
import 'cpr_metronome_screen.dart';
import 'emergency_guide_detail_screen.dart';
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
        // 1. Sleek Pill Search Bar at the very top
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: TextField(
              controller: searchController,
              onChanged: (v) => searchQuery.value = v,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: s.searchHint,
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
        ),

        // 2. Unified Quick Emergency Card (hidden while searching)
        if (searchQuery.value.trim().isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(14),
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
                                          size: 17,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'SOS ${awarenessState.emergencyNumber}',
                                          style: TextStyle(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 22,
                                color: theme.colorScheme.onPrimary
                                    .withValues(alpha: 0.25),
                              ),
                              InkWell(
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(14),
                                ),
                                onTap: () => _showRegionPickerSheet(
                                  context,
                                  ref,
                                  awarenessState,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
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
                                        size: 17,
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
                          height: 46,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: theme.scaffoldBackgroundColor,
                              foregroundColor: theme.colorScheme.onSurface,
                              side: BorderSide(color: theme.dividerColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
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
                              size: 17,
                            ),
                            label: Text(
                              s.cprCoach,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s.disclaimer,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. First-Aid Guides Header + Language Toggle (EN | हिं)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final guide = filteredGuides[index];
                  final isPassed =
                      awarenessState.completedGuideIds.contains(guide.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
