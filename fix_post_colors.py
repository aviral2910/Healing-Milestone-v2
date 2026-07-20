import re
import sys

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Color(0xFF0F0F0F) -> Theme.of(context).scaffoldBackgroundColor
    content = re.sub(r'const Color\(0xFF0F0F0F\)', r'Theme.of(context).scaffoldBackgroundColor', content)
    content = re.sub(r'Color\(0xFF0F0F0F\)', r'Theme.of(context).scaffoldBackgroundColor', content)
    
    # 2. Color(0xFF161616) -> Theme.of(context).cardColor
    content = re.sub(r'const Color\(0xFF161616\)', r'Theme.of(context).cardColor', content)
    content = re.sub(r'Color\(0xFF161616\)', r'Theme.of(context).cardColor', content)
    
    # 3. Color(0xFF1A1A1A) -> Theme.of(context).colorScheme.surface
    content = re.sub(r'const Color\(0xFF1A1A1A\)', r'Theme.of(context).colorScheme.surface', content)
    content = re.sub(r'Color\(0xFF1A1A1A\)', r'Theme.of(context).colorScheme.surface', content)
    
    # 4. Color(0xFF222222) -> Theme.of(context).colorScheme.secondaryContainer
    content = re.sub(r'const Color\(0xFF222222\)', r'Theme.of(context).colorScheme.secondaryContainer', content)
    content = re.sub(r'Color\(0xFF222222\)', r'Theme.of(context).colorScheme.secondaryContainer', content)
    
    # 5. Color(0xFF333333) -> Theme.of(context).dividerColor
    content = re.sub(r'const Color\(0xFF333333\)', r'Theme.of(context).dividerColor', content)
    content = re.sub(r'Color\(0xFF333333\)', r'Theme.of(context).dividerColor', content)
    
    # 6. Color(0xFFA0A0A0) -> Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey
    content = re.sub(r'const Color\(0xFFA0A0A0\)', r'(Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)', content)
    content = re.sub(r'Color\(0xFFA0A0A0\)', r'(Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)', content)
    
    # 7. Color(0xFFE0E0E0) -> Theme.of(context).colorScheme.onSurface
    content = re.sub(r'const Color\(0xFFE0E0E0\)', r'Theme.of(context).colorScheme.onSurface', content)
    content = re.sub(r'Color\(0xFFE0E0E0\)', r'Theme.of(context).colorScheme.onSurface', content)

    # Clean up any leftover 'const' preceding these widgets if they are now dynamic
    content = re.sub(r'const\s+(BoxDecoration\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(TextStyle\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(Container\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(Icon\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(CircleAvatar\([^)]*Theme\.of)', r'\1', content)

    with open(filepath, 'w') as f:
        f.write(content)

if __name__ == '__main__':
    fix_file(sys.argv[1])
