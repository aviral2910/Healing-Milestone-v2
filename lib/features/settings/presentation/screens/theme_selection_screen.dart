import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/core/theme/theme_provider.dart';
import 'package:healing_milestones/core/theme/theme_palette.dart';

class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final theme = Theme.of(context);

    final darkThemes = ThemePalette.allThemes.where((t) => t.isDark).toList();
    final lightThemes = ThemePalette.allThemes.where((t) => !t.isDark).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Theme & Appearance',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          _buildThemeGroupCard(
              context, ref, currentTheme, 'Dark Theme', darkThemes),
          const SizedBox(height: 24),
          _buildThemeGroupCard(
              context, ref, currentTheme, 'Light Theme', lightThemes),
        ],
      ),
    );
  }

  Widget _buildThemeGroupCard(BuildContext context, WidgetRef ref,
      ThemePalette currentTheme, String title, List<ThemePalette> themes) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 4, right: 4, bottom: 4, top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: _buildThemeRow(context, ref, currentTheme, themes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeRow(BuildContext context, WidgetRef ref,
      ThemePalette currentTheme, List<ThemePalette> themes) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 16,
      runSpacing: 16,
      children: themes.map((palette) {
        final isSelected = currentTheme.type == palette.type;

        // Extract a short name for display under the circle
        String shortName = palette.name;
        if (shortName.contains(' (Default)')) {
          shortName = shortName.replaceAll(' (Default)', '');
        }
        shortName = shortName.replaceAll(' Dark', '').replaceAll(' Light', '');

        return GestureDetector(
          onTap: () {
            ref.read(themeProvider.notifier).setTheme(palette);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.background,
                    border: Border.all(
                      color: isSelected
                          ? palette.accentPrimary
                          : Theme.of(context).dividerColor,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ]),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.accentPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                shortName,
                style: TextStyle(
                  color: isSelected
                      ? palette.accentPrimary
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}
