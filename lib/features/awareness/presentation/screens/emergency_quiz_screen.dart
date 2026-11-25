import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/awareness_providers.dart';
import '../../domain/emergency_guide_model.dart';

class EmergencyQuizScreen extends ConsumerStatefulWidget {
  final EmergencyGuide guide;

  const EmergencyQuizScreen({super.key, required this.guide});

  @override
  ConsumerState<EmergencyQuizScreen> createState() =>
      _EmergencyQuizScreenState();
}

class _EmergencyQuizScreenState extends ConsumerState<EmergencyQuizScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  int _correctCount = 0;
  bool _isFinished = false;

  void _selectOption(int index) {
    if (_selectedOption != null) return;
    final question = widget.guide.quizzes[_currentIndex];
    setState(() {
      _selectedOption = index;
      if (index == question.correctIndex) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.guide.quizzes.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
    } else {
      final passedAll = _correctCount == widget.guide.quizzes.length;
      if (passedAll) {
        ref
            .read(awarenessProvider.notifier)
            .markGuideCompleted(widget.guide.id);
      }
      setState(() => _isFinished = true);
    }
  }

  void _retryQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOption = null;
      _correctCount = 0;
      _isFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final total = widget.guide.quizzes.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Test: ${widget.guide.title}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: _isFinished
              ? _buildResultView(theme, primary, total)
              : _buildQuestionView(theme, primary, total),
        ),
      ),
    );
  }

  Widget _buildQuestionView(ThemeData theme, Color primary, int total) {
    final question = widget.guide.quizzes[_currentIndex];
    final hasAnswered = _selectedOption != null;
    final isLast = _currentIndex == total - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'QUESTION ${_currentIndex + 1} OF $total',
              style: theme.textTheme.labelSmall?.copyWith(
                color: primary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Score: $_correctCount/$total',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / total,
            minHeight: 4,
            backgroundColor: theme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(primary),
          ),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                ...List.generate(question.options.length, (index) {
                  final isSelected = _selectedOption == index;
                  final isCorrect = index == question.correctIndex;
                  final letter = String.fromCharCode(65 + index);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _selectOption(index),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (hasAnswered && isCorrect)
                              ? primary.withValues(alpha: 0.14)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: (hasAnswered && isCorrect)
                                ? primary
                                : (hasAnswered && isSelected)
                                    ? theme.colorScheme.error
                                    : theme.dividerColor,
                            width: (hasAnswered && (isCorrect || isSelected))
                                ? 1.5
                                : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: (hasAnswered && isCorrect)
                                    ? primary
                                    : primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                letter,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: (hasAnswered && isCorrect)
                                      ? theme.colorScheme.onPrimary
                                      : primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            if (hasAnswered && isCorrect)
                              Icon(Icons.check_circle, color: primary, size: 20)
                            else if (hasAnswered && isSelected)
                              Icon(
                                Icons.cancel_outlined,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (hasAnswered) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Text(
                      question.explanation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.85),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: hasAnswered ? _nextQuestion : null,
            child: Text(
              isLast ? 'See Results' : 'Next Question',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView(ThemeData theme, Color primary, int total) {
    final passedAll = _correctCount == total;

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: passedAll ? primary : theme.dividerColor,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passedAll ? Icons.verified_rounded : Icons.replay_circle_filled,
              size: 56,
              color: passedAll ? primary : theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              passedAll ? 'Test Passed!' : 'Almost There',
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 26),
            ),
            const SizedBox(height: 8),
            Text(
              'You answered $_correctCount of $total questions correctly.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              passedAll
                  ? 'Great job! This emergency guide is now marked as practiced.'
                  : 'All $total questions must be answered correctly to pass this guide.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: passedAll ? () => Navigator.pop(context) : _retryQuiz,
                child: Text(
                  passedAll ? 'Done' : 'Retry Test',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            if (!passedAll) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Review Steps Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
