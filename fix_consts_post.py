import re
import sys

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Generic removal of const for common widgets when they contain Theme.of
    content = re.sub(r'const\s+(Text\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(Icon\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(TextStyle\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(BoxDecoration\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(Row\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(Column\([^)]*Theme\.of)', r'\1', content)

    # Let's just remove `const` before `Text` and `Icon` across the board if it fails again
    # But for now, we know the lines. Let's use sed for lines if we can, or just strip const blindly for Text, Icon, TextStyle, etc.
    
    with open(filepath, 'w') as f:
        f.write(content)

if __name__ == '__main__':
    fix_file(sys.argv[1])
