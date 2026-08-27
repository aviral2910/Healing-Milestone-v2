import re

def add_import(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    if "package:healing_milestones/shared/utils/share_utils.dart" not in content:
        # Find first import
        match = re.search(r'^import .*;', content, re.MULTILINE)
        if match:
            insert_pos = match.end()
            content = content[:insert_pos] + "\nimport 'package:healing_milestones/shared/utils/share_utils.dart';" + content[insert_pos:]
            with open(filepath, 'w') as f:
                f.write(content)

add_import('lib/features/journey/presentation/screens/journey_detail_screen.dart')
add_import('lib/features/journey/presentation/widgets/public_journey_detail_overlay.dart')
