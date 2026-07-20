import sys

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Colors
    content = content.replace('AppTheme.surfaceLight', 'Theme.of(context).cardColor')
    content = content.replace('AppTheme.surface', 'Theme.of(context).scaffoldBackgroundColor')
    content = content.replace('AppTheme.accentPrimary', 'Theme.of(context).colorScheme.primary')
    content = content.replace('AppTheme.textPrimary', '(Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white)')
    content = content.replace('AppTheme.textSecondary', '(Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)')

    # Edge cases with const
    content = content.replace('const TextStyle(color: (Theme.of(context)', 'TextStyle(color: (Theme.of(context)')
    content = content.replace('const BorderSide(color: Theme.of(context)', 'BorderSide(color: Theme.of(context)')
    content = content.replace('const IconThemeData(color: Theme.of(context)', 'IconThemeData(color: Theme.of(context)')

    # Some consts that might have wrapped around
    content = content.replace('const Icon(icon, color: Theme.of(context)', 'Icon(icon, color: Theme.of(context)')

    with open(filepath, 'w') as f:
        f.write(content)

process_file('/Users/aviraldixit/self/healing_milestones/lib/features/profile/presentation/screens/edit_profile_screen.dart')
process_file('/Users/aviraldixit/self/healing_milestones/lib/features/settings/presentation/screens/settings_screen.dart')
print("Done")
