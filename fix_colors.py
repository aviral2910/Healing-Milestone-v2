import re
import sys

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Replace specific const widgets that will become dynamic
    # e.g., const Text('...', style: TextStyle(color: Colors.white)) -> Text('...', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))
    
    # 1. Remove const from specific widgets that have Colors.white/black
    content = re.sub(r'const\s+(Text\([^)]*Colors\.(white|black).*?\))', r'\1', content, flags=re.DOTALL)
    content = re.sub(r'const\s+(Icon\([^)]*Colors\.(white|black).*?\))', r'\1', content, flags=re.DOTALL)
    content = re.sub(r'const\s+(TextStyle\([^)]*Colors\.(white|black).*?\))', r'\1', content, flags=re.DOTALL)
    
    # 2. Colors.white.withOpacity(X) -> Theme.of(context).colorScheme.onSurface.withValues(alpha: X)
    content = re.sub(r'Colors\.white\.withOpacity\((.*?)\)', r'Theme.of(context).colorScheme.onSurface.withValues(alpha: \1)', content)
    content = re.sub(r'Colors\.white\.withValues\(alpha:\s*(.*?)\)', r'Theme.of(context).colorScheme.onSurface.withValues(alpha: \1)', content)
    
    # 3. Colors.black.withOpacity(X) -> Theme.of(context).colorScheme.onSurface.withValues(alpha: X)
    content = re.sub(r'Colors\.black\.withOpacity\((.*?)\)', r'Theme.of(context).colorScheme.onSurface.withValues(alpha: \1)', content)
    content = re.sub(r'Colors\.black\.withValues\(alpha:\s*(.*?)\)', r'Theme.of(context).colorScheme.onSurface.withValues(alpha: \1)', content)
    
    # 4. Colors.white70 -> Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
    content = re.sub(r'Colors\.white70', r'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)', content)
    content = re.sub(r'Colors\.white54', r'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)', content)
    content = re.sub(r'Colors\.black54', r'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)', content)
    
    # 5. Colors.white -> Theme.of(context).colorScheme.onSurface
    content = re.sub(r'Colors\.white(?![a-zA-Z0-9_])', r'Theme.of(context).colorScheme.onSurface', content)
    
    # 6. Colors.black -> Theme.of(context).colorScheme.onSurface
    content = re.sub(r'Colors\.black(?![a-zA-Z0-9_])', r'Theme.of(context).colorScheme.onSurface', content)
    
    # Now fix invalid const structures that might be left over:
    # const Padding(child: Text(..., Theme.of(context)...))
    # It's better to just run the flutter analyze and manually fix the consts, but we can try to strip obvious ones.
    content = re.sub(r'const\s+(Padding\([^)]*Theme\.of\(context\).*?\))', r'\1', content, flags=re.DOTALL)
    content = re.sub(r'const\s+(Center\([^)]*Theme\.of\(context\).*?\))', r'\1', content, flags=re.DOTALL)
    content = re.sub(r'const\s+(SizedBox\([^)]*Theme\.of\(context\).*?\))', r'\1', content, flags=re.DOTALL)
    
    with open(filepath, 'w') as f:
        f.write(content)

if __name__ == '__main__':
    fix_file(sys.argv[1])
