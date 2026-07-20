import re
import sys

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Colors.white -> Theme.of(context).colorScheme.onSurface
    content = re.sub(r'Colors\.white', r'Theme.of(context).colorScheme.onSurface', content)
    
    # Color(0xFFF5F5F7) -> Theme.of(context).colorScheme.onSurface
    content = re.sub(r'const Color\(0xFFF5F5F7\)', r'Theme.of(context).colorScheme.onSurface', content)
    content = re.sub(r'Color\(0xFFF5F5F7\)', r'Theme.of(context).colorScheme.onSurface', content)
    
    # Color(0xFFA1A1A6) -> (Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)
    content = re.sub(r'const Color\(0xFFA1A1A6\)', r'(Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)', content)
    content = re.sub(r'Color\(0xFFA1A1A6\)', r'(Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)', content)

    # Color(0xFF1E1E1E) -> Theme.of(context).colorScheme.surfaceContainerHighest (or similar for background)
    content = re.sub(r'const Color\(0xFF1E1E1E\)', r'Theme.of(context).colorScheme.surfaceContainerHighest', content)
    content = re.sub(r'Color\(0xFF1E1E1E\)', r'Theme.of(context).colorScheme.surfaceContainerHighest', content)

    # Remove generic consts from Text / TextStyle / Icon that now contain Theme.of
    content = re.sub(r'const\s+(Text\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(TextStyle\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(Icon\([^)]*Theme\.of)', r'\1', content)

    with open(filepath, 'w') as f:
        f.write(content)

if __name__ == '__main__':
    fix_file(sys.argv[1])
