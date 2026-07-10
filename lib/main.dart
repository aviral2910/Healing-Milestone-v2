import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/accessibility/data/accessibility_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Initialize Firebase here once config is ready
  
  runApp(
    const ProviderScope(
      child: HealingMilestonesApp(),
    ),
  );
}

class HealingMilestonesApp extends ConsumerWidget {
  const HealingMilestonesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final accessibilityState = ref.watch(accessibilityProvider);

    // Apply accessibility scaling to the base dark theme
    ThemeData baseTheme = AppTheme.darkTheme;
    TextTheme scaledTextTheme = baseTheme.textTheme.apply(
      fontSizeFactor: accessibilityState.textSizeFactor,
      bodyColor: AppTheme.textPrimary.withOpacity(accessibilityState.textOpacity),
      displayColor: AppTheme.textPrimary.withOpacity(accessibilityState.textOpacity),
    );

    return MaterialApp.router(
      title: 'Healing Milestones',
      theme: baseTheme.copyWith(textTheme: scaledTextTheme),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
