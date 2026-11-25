import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../data/awareness_providers.dart';
import '../../domain/emergency_guide_model.dart';
import 'cpr_metronome_screen.dart';

class HandsFreeGuideScreen extends ConsumerStatefulWidget {
  final EmergencyGuide guide;
  final int initialStepIndex;

  const HandsFreeGuideScreen({
    super.key,
    required this.guide,
    this.initialStepIndex = 0,
  });

  @override
  ConsumerState<HandsFreeGuideScreen> createState() =>
      _HandsFreeGuideScreenState();
}

class _HandsFreeGuideScreenState extends ConsumerState<HandsFreeGuideScreen> {
  final FlutterTts _tts = FlutterTts();
  late final PageController _pageController;
  Timer? _pauseTimer;
  late int _currentIndex;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialStepIndex;
    _pageController = PageController(
      initialPage: widget.initialStepIndex,
      viewportFraction: 0.86,
    );
    _initAndStart();
  }

  Future<void> _initAndStart() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.47);
    _tts.setCompletionHandler(() {
      if (!mounted || !_isPlaying) return;
      final next = _currentIndex + 1;
      if (next < widget.guide.steps.length) {
        _pauseTimer?.cancel();
        _pauseTimer = Timer(const Duration(milliseconds: 1200), () {
          if (!mounted || !_isPlaying) return;
          setState(() => _currentIndex = next);
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              next,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
          _speakCurrent();
        });
      } else {
        setState(() => _isPlaying = false);
      }
    });
    await _speakCurrent();
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _pageController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speakCurrent() async {
    if (!mounted) return;
    await _tts.speak(widget.guide.steps[_currentIndex].voicePrompt);
  }

  Future<void> _togglePlayPause() async {
    _pauseTimer?.cancel();
    if (_isPlaying) {
      await _tts.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _speakCurrent();
    }
  }

  Future<void> _goToStep(int index) async {
    if (index < 0 || index >= widget.guide.steps.length) return;
    _pauseTimer?.cancel();
    await _tts.stop();
    setState(() => _currentIndex = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
    if (_isPlaying) {
      await _speakCurrent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final guide = widget.guide;
    final step = guide.steps[_currentIndex];
    final total = guide.steps.length;
    final emergencyNumber = ref.watch(awarenessProvider).emergencyNumber;

    return Scaffold(
      appBar: AppBar(
        title: Text(guide.title),
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
              onPressed: () => launchEmergencyDialer(context, emergencyNumber),
              icon: const Icon(Icons.call_outlined, size: 16),
              label: Text(
                'SOS $emergencyNumber',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress & Voice Status
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STEP ${step.stepNumber} OF $total',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: primary,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            _isPlaying
                                ? Icons.graphic_eq_rounded
                                : Icons.pause_circle_outline,
                            size: 16,
                            color: _isPlaying
                                ? primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isPlaying ? 'Hands-Free Speaking' : 'Paused',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _isPlaying ? primary : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / total,
                      minHeight: 5,
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Full-width Swipeable Step Cards (adjacent cards visible)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: total,
                onPageChanged: (index) {
                  if (_currentIndex == index) return;
                  _pauseTimer?.cancel();
                  setState(() => _currentIndex = index);
                  if (_isPlaying) {
                    _tts.stop().then((_) => _speakCurrent());
                  }
                },
                itemBuilder: (context, index) {
                  final pageStep = guide.steps[index];
                  final isCurrent = index == _currentIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: (isCurrent && _isPlaying)
                              ? primary.withValues(alpha: 0.55)
                              : theme.dividerColor,
                          width: (isCurrent && _isPlaying) ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${pageStep.stepNumber}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            pageStep.title,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 25,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                pageStep.instruction,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 18,
                                  height: 1.65,
                                ),
                              ),
                            ),
                          ),
                          if (pageStep.criticalNote != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline,
                                      color: primary, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      pageStep.criticalNote!,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  if (guide.hasMetronome) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(color: theme.dividerColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          _pauseTimer?.cancel();
                          _tts.stop();
                          setState(() => _isPlaying = false);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CprMetronomeScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.favorite_outline,
                            color: primary, size: 18),
                        label: const Text(
                          'Switch to 110 BPM CPR Coach',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Large Thumb-Friendly Controls: Previous | Play/Pause | Next
                  Row(
                    children: [
                      SizedBox(
                        height: 56,
                        width: 64,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: BorderSide(color: theme.dividerColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _currentIndex > 0
                              ? () => _goToStep(_currentIndex - 1)
                              : null,
                          child: const Icon(Icons.skip_previous_rounded,
                              size: 26),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  _isPlaying ? theme.cardColor : primary,
                              foregroundColor: _isPlaying
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onPrimary,
                              side: _isPlaying
                                  ? BorderSide(color: primary)
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _togglePlayPause,
                            icon: Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 24,
                            ),
                            label: Text(
                              _isPlaying ? 'Pause Voice' : 'Resume Voice',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 56,
                        width: 64,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: BorderSide(color: theme.dividerColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _currentIndex < total - 1
                              ? () => _goToStep(_currentIndex + 1)
                              : null,
                          child: const Icon(Icons.skip_next_rounded, size: 26),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
