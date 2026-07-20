import re
import sys

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Remove const preceding CircularProgressIndicator, Row, Column, Padding, Center
    content = re.sub(r'const\s+(CircularProgressIndicator\()', r'\1', content)
    content = re.sub(r'const\s+(Row\()', r'\1', content)
    content = re.sub(r'const\s+(Column\()', r'\1', content)
    content = re.sub(r'const\s+(Padding\()', r'\1', content)
    content = re.sub(r'const\s+(Center\()', r'\1', content)
    content = re.sub(r'const\s+(Text\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(Icon\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(TextStyle\([^)]*Theme\.of)', r'\1', content)
    content = re.sub(r'const\s+(BoxDecoration\([^)]*Theme\.of)', r'\1', content)

    # Remove unused AppTheme imports
    content = re.sub(r"import\s+['\"].*?app_theme\.dart['\"];\n", '', content)

    with open(filepath, 'w') as f:
        f.write(content)

if __name__ == '__main__':
    for filepath in sys.argv[1:]:
        fix_file(filepath)
