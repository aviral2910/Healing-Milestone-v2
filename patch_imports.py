import re

def add_import(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    if "package:healing_milestones/shared/utils/share_utils.dart" not in content:
        match = re.search(r'^import .*;', content, re.MULTILINE)
        if match:
            insert_pos = match.end()
            content = content[:insert_pos] + "\nimport 'package:healing_milestones/shared/utils/share_utils.dart';" + content[insert_pos:]
            with open(filepath, 'w') as f:
                f.write(content)

add_import('lib/features/profile/presentation/screens/profile_screen.dart')
add_import('lib/features/profile/presentation/screens/public_profile_screen.dart')
add_import('lib/shared/widgets/interaction_section.dart')
