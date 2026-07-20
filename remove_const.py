import sys
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Remove `const ` when it precedes `Text(`, `Icon(`, `Center(`, `CircleAvatar(`, `TextStyle(`
    content = re.sub(r'const\s+Text\(', r'Text(', content)
    content = re.sub(r'const\s+Icon\(', r'Icon(', content)
    content = re.sub(r'const\s+Center\(', r'Center(', content)
    content = re.sub(r'const\s+CircleAvatar\(', r'CircleAvatar(', content)
    content = re.sub(r'const\s+TextStyle\(', r'TextStyle(', content)
    content = re.sub(r'const\s+BorderSide\(', r'BorderSide(', content)
    content = re.sub(r'const\s+IconThemeData\(', r'IconThemeData(', content)

    with open(filepath, 'w') as f:
        f.write(content)

process_file('/Users/aviraldixit/self/healing_milestones/lib/features/profile/presentation/screens/edit_profile_screen.dart')
print("Done")
