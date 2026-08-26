with open('lib/features/profile/presentation/screens/public_profile_screen.dart', 'r') as f:
    content = f.read()

import_statement = "import 'package:healing_milestones/features/chat/presentation/screens/chat_room_screen.dart';\n"
if import_statement not in content:
    content = import_statement + content

with open('lib/features/profile/presentation/screens/public_profile_screen.dart', 'w') as f:
    f.write(content)
