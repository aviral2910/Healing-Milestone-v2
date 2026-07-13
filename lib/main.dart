import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/accessibility/data/accessibility_providers.dart';

// UAT Mode provider
final uatModeProvider = StateProvider<bool>((ref) => false);

// Selected Tag Provider for Post Screen
final selectedTagProvider = StateProvider<String>((ref) => 'All');

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
    final isUatMode = ref.watch(uatModeProvider);

    // Apply accessibility scaling to the base dark theme
    ThemeData baseTheme = AppTheme.darkTheme;
    TextTheme scaledTextTheme = baseTheme.textTheme.apply(
      fontSizeFactor: accessibilityState.textSizeFactor,
      bodyColor: AppTheme.textPrimary.withValues(alpha: accessibilityState.textOpacity),
      displayColor: AppTheme.textPrimary.withValues(alpha: accessibilityState.textOpacity),
    );

    return DevicePreview(
      enabled: isUatMode,
      builder: (context) => MaterialApp.router(
        title: 'Healing Milestones',
        theme: baseTheme.copyWith(textTheme: scaledTextTheme),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
      ),
    );
  }
}
