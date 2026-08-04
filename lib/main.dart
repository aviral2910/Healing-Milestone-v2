import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/theme_palette.dart';
import 'features/accessibility/data/accessibility_providers.dart';
import 'features/accessibility/presentation/widgets/greyscale_floating_overlay.dart';

// UAT Mode providers
final uatModeProvider = StateProvider<bool>((ref) => false);
final devicePreviewProvider = StateProvider<bool>((ref) => false);

// Selected Tag Provider for Post Screen
final selectedTagProvider = StateProvider<String>((ref) => 'All');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize App Check with Debug provider
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const HealingMilestonesApp(),
    ),
  );
}

class HealingMilestonesApp extends ConsumerWidget {
  const HealingMilestonesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final accessibilityState = ref.watch(accessibilityProvider);
    final isDevicePreview = ref.watch(devicePreviewProvider);
    final themePalette = ref.watch(themeProvider);

    // Select the optimal eye-care palette if Reading Mode (Greyscale) is active
    ThemePalette activePalette = themePalette;
    if (accessibilityState.isGreyscaleMode) {
      activePalette = themePalette.isDark 
          ? ThemePalette.eyeCareDark 
          : ThemePalette.eyeCareLight;
    }

    // Apply accessibility scaling to the base dark theme
    ThemeData baseTheme = AppTheme.getThemeData(activePalette);


    return DevicePreview(
      enabled: isDevicePreview,
      builder: (context) => MaterialApp.router(
        title: 'Healing Milestones',
        theme: baseTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: (context, child) {
          final widget = DevicePreview.appBuilder(context, child);
          final data = MediaQuery.of(context);
          Widget appContent = widget;

          if (accessibilityState.isGreyscaleMode) {
            const greyscaleMatrix = <double>[
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ];
            appContent = ColorFiltered(
              colorFilter: const ColorFilter.matrix(greyscaleMatrix),
              child: appContent,
            );
          }

          return GreyscaleFloatingOverlay(child: appContent);
        },
      ),
    );
  }
}
