import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../data/awareness_providers.dart';
import '../../domain/emergency_guide_model.dart';
import 'cpr_metronome_screen.dart';
import 'emergency_quiz_screen.dart';

class EmergencyGuideDetailScreen extends ConsumerStatefulWidget {
  final EmergencyGuide guide;

  const EmergencyGuideDetailScreen({super.key, required this.guide});

  @override
  ConsumerState<EmergencyGuideDetailScreen> createState() =>
      _EmergencyGuideDetailScreenState();
}

class _EmergencyGuideDetailScreenState
    extends ConsumerState<EmergencyGuideDetailScreen> {
  final FlutterTts _tts = FlutterTts();
  Timer? _pauseTimer;
  int _activeStepIndex = 0;
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
    _tts.setCompletionHandler(() {
      if (!mounted || !_isAutoPlaying) return;
      final nextIndex = _activeStepIndex + 1;
      if (nextIndex < widget.guide.steps.length) {
        _pauseTimer?.cancel();
        _pauseTimer = Timer(const Duration(milliseconds: 1100), () {
          if (!mounted || !_isAutoPlaying) return;
          setState(() => _activeStepIndex = nextIndex);
          _speakStep(nextIndex);
        });
      } else {
        setState(() => _isAutoPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speakStep(int index) async {
    if (index < 0 || index >= widget.guide.steps.length) return;
    await _tts.speak(widget.guide.steps[index].voicePrompt);
  }

  Future<void> _toggleAutoPlay() async {
    if (_isAutoPlaying) {
      _pauseTimer?.cancel();
      await _tts.stop();
      setState(() => _isAutoPlaying = false);
      return;
    }
    setState(() => _isAutoPlaying = true);
    await _speakStep(_activeStepIndex);
  }

  Future<void> _jumpToStep(int index) async {
    _pauseTimer?.cancel();
    await _tts.stop();
    setState(() {
      _activeStepIndex = index;
      _isAutoPlaying = true;
    });
    await _speakStep(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final guide = widget.guide;
    final awarenessState = ref.watch(awarenessProvider);
    final isCompleted = awarenessState.completedGuideIds.contains(guide.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(guide.category.label),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () =>
                  launchEmergencyDialer(context, awarenessState.emergencyNumber),
              icon: const Icon(Icons.call_outlined, size: 16),
              label: Text('SOS ${awarenessState.emergencyNumber}'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
        children: [
          // Editorial Hero Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(guide.category.icon, color: primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(guide.title, style: theme.textTheme.titleLarge),
                          const SizedBox(height: 2),
                          Text(
                            '${guide.steps.length} steps • Hands-free voice ready',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.emergency_outlined, color: primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          guide.whenToCallEmergency,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Primary Hands-Free Voice Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _isAutoPlaying ? theme.scaffoldBackgroundColor : primary,
                      foregroundColor: _isAutoPlaying
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onPrimary,
                      side: _isAutoPlaying
                          ? BorderSide(color: primary)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _toggleAutoPlay,
                    icon: Icon(
                      _isAutoPlaying
                          ? Icons.stop_rounded
                          : Icons.volume_up_rounded,
                      size: 20,
                    ),
                    label: Text(
                      _isAutoPlaying
                          ? 'Stop Hands-Free Voice'
                          : 'Listen Hands-Free (All Steps)',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                if (guide.hasMetronome) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
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
                      icon: Icon(Icons.favorite_outline, color: primary, size: 18),
                      label: const Text(
                        'Open 110 BPM CPR Coach',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Connected Vertical Timeline (no card boxes per step)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Step-by-Step Guide', style: theme.textTheme.titleLarge),
              Text(
                'Tap step to listen',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...List.generate(guide.steps.length, (index) {
            final step = guide.steps[index];
            final isActive = index == _activeStepIndex && _isAutoPlaying;
            final isLast = index == guide.steps.length - 1;

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _jumpToStep(index),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left timeline column: circle + connecting vertical line
                    SizedBox(
                      width: 32,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? primary
                                  : theme.cardColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isActive ? primary : theme.dividerColor,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              '${step.stepNumber}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isActive
                                    ? theme.colorScheme.onPrimary
                                    : primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 1.5,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                color: isActive
                                    ? primary.withValues(alpha: 0.5)
                                    : theme.dividerColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Right step content directly on page background
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 8 : 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    step.title,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: isActive
                                          ? primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isActive
                                      ? Icons.graphic_eq_rounded
                                      : Icons.volume_up_outlined,
                                  size: 17,
                                  color: isActive
                                      ? primary
                                      : theme.colorScheme.onSurface
                                          .withValues(alpha: 0.35),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.instruction,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                            if (step.criticalNote != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: primary,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      step.criticalNote!,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // What NOT to Do — Distinct Caution Block
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.35),
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
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AVOID THESE MISTAKES',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...guide.doNots.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: theme.colorScheme.error,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(item, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Separate Test Yourself Entry
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted ? Icons.verified : Icons.quiz_outlined,
                    color: primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompleted ? 'Test Passed' : 'Test Yourself',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${guide.quizzes.length} questions • 100% required to pass',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EmergencyQuizScreen(guide: guide),
                      ),
                    );
                  },
                  child: Text(isCompleted ? 'Retake' : 'Start'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
