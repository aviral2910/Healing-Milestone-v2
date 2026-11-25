import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/awareness_providers.dart';
import '../../data/awareness_strings.dart';
import '../../data/emergency_science_quizzes.dart';
import '../../domain/emergency_guide_model.dart';
import 'cpr_metronome_screen.dart';
import 'emergency_quiz_screen.dart';
import 'emergency_science_screen.dart';
import 'hands_free_guide_screen.dart';

class EmergencyGuideDetailScreen extends ConsumerWidget {
  final EmergencyGuide guide;

  const EmergencyGuideDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final awarenessState = ref.watch(awarenessProvider);
    final s = AwarenessStrings(awarenessState.language);
    final isCompleted = awarenessState.completedGuideIds.contains(guide.id);
    final totalQuizCount = guide.quizzes.length +
        getScienceQuizzes(guide.id, awarenessState.language).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.categoryLabel(guide.category)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: primary.withValues(alpha: 0.12),
                foregroundColor: primary,
                side: BorderSide(color: primary.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () =>
                  launchEmergencyDialer(context, awarenessState.emergencyNumber),
              icon: const Icon(Icons.call_outlined, size: 16),
              label: Text(
                'SOS ${awarenessState.emergencyNumber}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
        children: [
          // 1. Title & Full "When to Call Emergency" (never collapsed)
          Text(
            guide.title,
            style: theme.textTheme.headlineLarge?.copyWith(fontSize: 26),
          ),
          const SizedBox(height: 6),
          Text(
            s.stepsSubtitle(guide.steps.length),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.emergency_outlined, color: primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    guide.whenToCallEmergency,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 2. Main Guided Steps CTA (+ CPR Coach if applicable)
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HandsFreeGuideScreen(guide: guide),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          s.startHandsFree,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        if (!guide.hasMetronome) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onPrimary
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${guide.steps.length}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (guide.hasMetronome) ...[
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.cardColor,
                        foregroundColor: theme.colorScheme.onSurface,
                        side: BorderSide(color: theme.dividerColor),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      icon: Icon(Icons.favorite_outline,
                          color: primary, size: 18),
                      label: Text(
                        s.cprCoach,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // 3. Avoid These Mistakes (clean, scannable)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.avoidMistakes,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...guide.doNots.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: theme.colorScheme.error,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.85),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Compact 2-Column Footer: Why It Works + Test Yourself
          Row(
            children: [
              Expanded(
                child: _FooterActionTile(
                  icon: Icons.biotech_outlined,
                  title: s.whyItWorks,
                  subtitle: s.learnWhy,
                  highlighted: false,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EmergencyScienceScreen(guide: guide),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FooterActionTile(
                  icon: isCompleted
                      ? Icons.verified_rounded
                      : Icons.quiz_outlined,
                  title: isCompleted ? s.testPassed : s.testYourself,
                  subtitle: isCompleted
                      ? s.retake
                      : '$totalQuizCount ${awarenessState.language == AwarenessLanguage.hi ? 'प्रश्न' : 'questions'}',
                  highlighted: isCompleted,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EmergencyQuizScreen(guide: guide),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;
  final VoidCallback onTap;

  const _FooterActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: highlighted
              ? primary.withValues(alpha: 0.10)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: highlighted
                ? primary.withValues(alpha: 0.45)
                : theme.dividerColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primary, size: 22),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 14,
                color: highlighted ? primary : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
