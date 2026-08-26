with open('lib/shared/widgets/direct_share_sheet.dart', 'r') as f:
    content = f.read()

content = content.replace('color: Colors.white,', 'color: Theme.of(context).colorScheme.surface,')
content = content.replace('color: Colors.grey[300]', 'color: Theme.of(context).dividerColor')
content = content.replace('color: Colors.grey[100]', 'color: Theme.of(context).colorScheme.surfaceContainerHighest')
content = content.replace('color: Colors.grey', 'color: Theme.of(context).colorScheme.onSurfaceVariant')

with open('lib/shared/widgets/direct_share_sheet.dart', 'w') as f:
    f.write(content)
