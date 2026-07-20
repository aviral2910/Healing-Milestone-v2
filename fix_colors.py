import sys

def process_edit_profile():
    filepath = '/Users/aviraldixit/self/healing_milestones/lib/features/profile/presentation/screens/edit_profile_screen.dart'
    with open(filepath, 'r') as f:
        content = f.read()

    # Pass context to helper functions
    content = content.replace('InputDecoration _buildInputDecoration(String hint', 'InputDecoration _buildInputDecoration(BuildContext context, String hint')
    content = content.replace('_buildInputDecoration(\'', '_buildInputDecoration(context, \'')
    content = content.replace('_buildInputDecoration("', '_buildInputDecoration(context, "')
    
    content = content.replace('Widget _buildLinkButton({', 'Widget _buildLinkButton(BuildContext context, {')
    content = content.replace('_buildLinkButton(', '_buildLinkButton(context, ')
    
    content = content.replace('Widget _buildSocialLink({', 'Widget _buildSocialLink(BuildContext context, {')
    content = content.replace('_buildSocialLink(', '_buildSocialLink(context, ')
    
    content = content.replace('Widget _buildPrivacyToggle({', 'Widget _buildPrivacyToggle(BuildContext context, {')
    content = content.replace('_buildPrivacyToggle(', '_buildPrivacyToggle(context, ')

    content = content.replace('Widget _buildStatCard(', 'Widget _buildStatCard(BuildContext context, ')
    content = content.replace('_buildStatCard(', '_buildStatCard(context, ')
    
    content = content.replace('Widget _buildEmptyState(', 'Widget _buildEmptyState(BuildContext context, ')
    content = content.replace('_buildEmptyState(', '_buildEmptyState(context, ')

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

    with open(filepath, 'w') as f:
        f.write(content)

def process_settings():
    filepath = '/Users/aviraldixit/self/healing_milestones/lib/features/settings/presentation/screens/settings_screen.dart'
    with open(filepath, 'r') as f:
        content = f.read()

    content = content.replace('AppTheme.surfaceLight', 'Theme.of(context).cardColor')
    content = content.replace('AppTheme.surface', 'Theme.of(context).scaffoldBackgroundColor')
    content = content.replace('AppTheme.accentPrimary', 'Theme.of(context).colorScheme.primary')
    content = content.replace('AppTheme.textPrimary', '(Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white)')
    content = content.replace('AppTheme.textSecondary', '(Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)')

    content = content.replace('const TextStyle(color: (Theme.of(context)', 'TextStyle(color: (Theme.of(context)')
    content = content.replace('const BorderSide(color: Theme.of(context)', 'BorderSide(color: Theme.of(context)')
    content = content.replace('const IconThemeData(color: Theme.of(context)', 'IconThemeData(color: Theme.of(context)')

    with open(filepath, 'w') as f:
        f.write(content)

process_edit_profile()
process_settings()
print("Done")
