import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/awareness_providers.dart';
import '../../data/awareness_strings.dart';
import '../../data/emergency_guides_data.dart';
import '../../data/emergency_science_data.dart';
import '../../domain/emergency_guide_model.dart';

class EmergencyScienceScreen extends ConsumerWidget {
  final EmergencyGuide guide;

  const EmergencyScienceScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final awarenessState = ref.watch(awarenessProvider);
    final s = AwarenessStrings(awarenessState.language);
    final localizedGuide = getEmergencyGuides(awarenessState.language)
        .firstWhere((g) => g.id == guide.id, orElse: () => guide);
    final science = getEmergencyScience(
      guide.id,
      awarenessState.language,
      depth: awarenessState.scienceDepth,
    );
    final clinicalRef = getEmergencyScience(
      guide.id,
      awarenessState.language,
      depth: ScienceDepth.clinical,
    )?.reference;

    if (science == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.whyItWorks)),
        body: const SizedBox.shrink(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizedGuide.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: AwarenessLanguage.values.map((lang) {
                  final selected = lang == awarenessState.language;
                  return GestureDetector(
                    onTap: () =>
                        ref.read(awarenessProvider.notifier).setLanguage(lang),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // Simple | Clinical Depth Toggle
          SegmentedButton<ScienceDepth>(
            style: SegmentedButton.styleFrom(
              backgroundColor: theme.cardColor,
              foregroundColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.7),
              selectedBackgroundColor: primary.withValues(alpha: 0.16),
              selectedForegroundColor: primary,
              side: BorderSide(color: theme.dividerColor),
            ),
            segments: [
              ButtonSegment(
                value: ScienceDepth.simple,
                label: Text(s.simpleMode),
                icon: const Icon(Icons.auto_stories_outlined, size: 17),
              ),
              ButtonSegment(
                value: ScienceDepth.clinical,
                label: Text(s.clinicalMode),
                icon: const Icon(Icons.biotech_outlined, size: 17),
              ),
            ],
            selected: {awarenessState.scienceDepth},
            onSelectionChanged: (val) => ref
                .read(awarenessProvider.notifier)
                .setScienceDepth(val.first),
          ),
          const SizedBox(height: 16),

          // What's Happening in the Body
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.biotech_outlined, color: primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      s.whatsHappeningInBody,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  science.bodyMechanism,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Text(s.whyEachStepWorks, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),

          ...science.facts.map(
            (fact) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.science_outlined, color: primary, size: 17),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fact.action,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fact.reason,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.85),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Myth Buster
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: theme.colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.mythBuster,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  science.mythBuster,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),

          // Guidelines & References Footer
          if (clinicalRef != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.guidelinesRef,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          clinicalRef,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
