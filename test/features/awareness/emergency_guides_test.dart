import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healing_milestones/features/awareness/data/awareness_providers.dart';
import 'package:healing_milestones/features/awareness/data/emergency_guides_data.dart';
import 'package:healing_milestones/features/awareness/data/emergency_guides_data_hi.dart';
import 'package:healing_milestones/features/awareness/data/emergency_science_data.dart';
import 'package:healing_milestones/features/awareness/presentation/screens/emergency_quiz_screen.dart';
import 'package:healing_milestones/features/awareness/presentation/screens/health_awareness_screen.dart';

void main() {
  test('Every English and Hindi emergency guide has one quiz question per step',
      () {
    expect(emergencyGuidesData.length, equals(13));
    expect(emergencyGuidesDataHi.length, equals(emergencyGuidesData.length));
    for (int i = 0; i < emergencyGuidesData.length; i++) {
      final en = emergencyGuidesData[i];
      final hi = emergencyGuidesDataHi[i];
      expect(hi.id, equals(en.id));
      expect(hi.steps.length, equals(en.steps.length));
      final sciEn = getEmergencyScience(en.id, AwarenessLanguage.en);
      final sciHi = getEmergencyScience(en.id, AwarenessLanguage.hi);
      expect(sciEn, isNotNull);
      expect(sciHi, isNotNull);
      expect(sciEn!.facts, isNotEmpty);
      expect(sciHi!.facts, isNotEmpty);
      for (final guide in [en, hi]) {
        expect(guide.id, isNotEmpty);
        expect(guide.title, isNotEmpty);
        expect(guide.steps, isNotEmpty);
        expect(guide.doNots, isNotEmpty);
        expect(guide.quizzes.length, equals(guide.steps.length));
        for (final q in guide.quizzes) {
          expect(q.options.length, greaterThanOrEqualTo(2));
          expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
        }
      }
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

    // Search filters guides offline and hides quick emergency card
    await tester.enterText(find.byType(TextField), 'snake');
    await tester.pumpAndSettle();

    expect(find.text('SOS 112'), findsNothing);
    expect(find.text('Snake Bite First Aid'), findsOneWidget);
    expect(find.text('Adult CPR & AED'), findsNothing);

    // Clear search and switch to Hindi
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('हिं'));
    await tester.pumpAndSettle();

    expect(find.text('प्राथमिक चिकित्सा और आपातकाल'), findsOneWidget);
    expect(find.text('वयस्क CPR और AED'), findsOneWidget);
  });

  testWidgets('EmergencyQuizScreen requires 100% correct to pass',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final guide = emergencyGuidesData.firstWhere((g) => g.id == 'burns_scalds');
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(
              home: EmergencyQuizScreen(guide: guide),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Answer Q1 wrong, Q2 & Q3 right -> should fail
    for (int i = 0; i < guide.quizzes.length; i++) {
      final q = guide.quizzes[i];
      final pickIndex = i == 0 ? (q.correctIndex + 1) % q.options.length : q.correctIndex;
      await tester.tap(find.text(q.options[pickIndex]));
      await tester.pumpAndSettle();
      await tester.tap(find.text(i == guide.quizzes.length - 1 ? 'See Results' : 'Next Question'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Almost There'), findsOneWidget);
    expect(container.read(awarenessProvider).completedGuideIds, isNot(contains(guide.id)));

    // Retry and answer all correctly -> should pass
    await tester.tap(find.text('Retry Test'));
    await tester.pumpAndSettle();

    for (int i = 0; i < guide.quizzes.length; i++) {
      final q = guide.quizzes[i];
      await tester.tap(find.text(q.options[q.correctIndex]));
      await tester.pumpAndSettle();
      await tester.tap(find.text(i == guide.quizzes.length - 1 ? 'See Results' : 'Next Question'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Test Passed!'), findsOneWidget);
    expect(container.read(awarenessProvider).completedGuideIds, contains(guide.id));
  });
}
