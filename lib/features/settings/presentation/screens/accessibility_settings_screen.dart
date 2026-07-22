import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/accessibility/data/accessibility_providers.dart';

class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Text & Accessibility',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        children: [

            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(accessibilityProvider);
                  return SwitchListTile(
                    title: const Text('Show Reading Mode Floating Icon'),
                    subtitle: const Text('Displays a draggable button when reading mode is active'),
                    activeColor: theme.colorScheme.primary,
                    value: state.showGreyscaleFloatingIcon,
                    onChanged: (val) {
                      ref.read(accessibilityProvider.notifier).toggleFloatingIcon(val);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style:
                        theme.textTheme.titleSmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This is how your text will look throughout the app. Adjust the sliders above to find a comfortable reading size and contrast level.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
