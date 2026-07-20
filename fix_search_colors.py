import re
import sys

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    content = re.sub(r'Colors\.white', r'Theme.of(context).colorScheme.onSurface', content)
    content = re.sub(r'Color\(0xFF7A7A7A\)', r'(Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)', content)
    content = re.sub(r'Color\(0xFFA1A1A6\)', r'(Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)', content)
    
    # Generic removal of const for common widgets when they contain Theme.of
    content = re.sub(r'const\s+(Text\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(Icon\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(TextStyle\([^)]*Theme\.of)', r'\1', content)

    with open(filepath, 'w') as f:
        f.write(content)

if __name__ == '__main__':
    fix_file(sys.argv[1])
