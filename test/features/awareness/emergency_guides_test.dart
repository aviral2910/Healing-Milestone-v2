import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healing_milestones/features/awareness/data/emergency_guides_data.dart';
import 'package:healing_milestones/features/awareness/presentation/screens/health_awareness_screen.dart';

void main() {
  test('All emergency guides have valid steps, doNots, and quiz', () {
    expect(emergencyGuidesData.length, greaterThanOrEqualTo(8));
    for (final guide in emergencyGuidesData) {
      expect(guide.id, isNotEmpty);
      expect(guide.title, isNotEmpty);
      expect(guide.steps, isNotEmpty);
      expect(guide.doNots, isNotEmpty);
      expect(guide.quiz.options.length, greaterThanOrEqualTo(2));
      expect(
        guide.quiz.correctIndex,
        inInclusiveRange(0, guide.quiz.options.length - 1),
      );
    }
  });

  testWidgets(
      'HealthAwarenessScreen renders SOS region selector, first-aid guides, and educational resources',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: HealthAwarenessScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SOS 112'), findsOneWidget);
    expect(find.text('IN / EU'), findsOneWidget);
    expect(find.text('CPR Coach'), findsOneWidget);
    expect(find.text('First-Aid & Emergency'), findsOneWidget);
    expect(find.text('Adult CPR & AED'), findsOneWidget);
  });
}
