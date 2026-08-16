import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';

class UatScreen extends ConsumerWidget {
  const UatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUatMode = ref.watch(uatModeProvider);
    final isDevicePreview = ref.watch(devicePreviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UAT Menu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Developer Tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Enable UAT Features'),
              subtitle: const Text('Enables dummy data creation and other developer bypasses.'),
              value: isUatMode,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                ref.read(uatModeProvider.notifier).state = value;
              },
            ),
            Divider(color: Theme.of(context).dividerColor),
            SwitchListTile(
              title: const Text('Enable Device Preview'),
              subtitle: const Text('Simulate the app on different device sizes.'),
              value: isDevicePreview,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                ref.read(devicePreviewProvider.notifier).state = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
