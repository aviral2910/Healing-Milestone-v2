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
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
            child: Text(
              'Select a Theme',
              style: theme.textTheme.titleLarge,
            ),
          ),
          ...ThemePalette.allThemes.map((palette) {
            final isSelected = currentTheme.type == palette.type;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildThemeCard(
                context: context,
                ref: ref,
                palette: palette,
                isSelected: isSelected,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required WidgetRef ref,
    required ThemePalette palette,
    required bool isSelected,
  }) {
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: isSelected ? 4 : 0,
      child: InkWell(
        onTap: () {
          ref.read(themeProvider.notifier).setTheme(palette);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? palette.accentPrimary : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Color preview circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.background,
                  border: Border.all(color: palette.accentPrimary, width: 3),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.accentSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      palette.name,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      palette.isDark ? 'Dark Mode' : 'Light Mode',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: palette.accentPrimary,
                  size: 28,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: palette.textSecondary.withOpacity(0.5),
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
