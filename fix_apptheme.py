import re
import sys

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. AppTheme.surface
    content = re.sub(r'AppTheme\.surface', r'Theme.of(context).colorScheme.surface', content)
    
    # 2. AppTheme.accentPrimary
    content = re.sub(r'AppTheme\.accentPrimary', r'Theme.of(context).colorScheme.primary', content)
    
    # 3. AppTheme.textSecondary
    content = re.sub(r'AppTheme\.textSecondary', r'(Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)', content)
    
    # 4. Colors.black.withOpacity(X) -> Theme.of(context).dividerColor
    content = re.sub(r'Colors\.black\.withValues\(alpha:\s*(.*?)\)', r'Theme.of(context).dividerColor', content)
    
    # 5. Colors.white -> Theme.of(context).colorScheme.onSurface
    content = re.sub(r'Colors\.white(?![a-zA-Z0-9_])', r'Theme.of(context).colorScheme.onSurface', content)
    
    # 6. Colors.white24 -> Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)
    content = re.sub(r'Colors\.white24', r'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)', content)
    
    # 7. Colors.black -> Theme.of(context).colorScheme.onSurface
    content = re.sub(r'Colors\.black(?![a-zA-Z0-9_])', r'Theme.of(context).colorScheme.onSurface', content)
    
    with open(filepath, 'w') as f:
        f.write(content)

if __name__ == '__main__':
    fix_file(sys.argv[1])
