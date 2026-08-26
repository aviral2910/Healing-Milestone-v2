with open('lib/shared/widgets/direct_share_sheet.dart', 'r') as f:
    content = f.read()

content = content.replace(
    'if (_searchQuery.isNotEmpty && !user.displayName.toLowerCase().contains(_searchQuery)) {',
    'if (user == null) return const SizedBox.shrink();\n                                  if (_searchQuery.isNotEmpty && !user.displayName.toLowerCase().contains(_searchQuery)) {'
)

content = content.replace(
    'AppTheme.primaryColor',
    'Theme.of(context).colorScheme.primary'
)

content = content.replace(
    'name: user.displayName,',
    ''
)

content = content.replace(
    'Share.share',
    '// ignore: deprecated_member_use\n                    Share.share'
)

with open('lib/shared/widgets/direct_share_sheet.dart', 'w') as f:
    f.write(content)
