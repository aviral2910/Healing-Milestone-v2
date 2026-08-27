import re

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

old_logic = """                        if (isSentRequest) {
                          displaySubtitle = 'Request sent · $displaySubtitle';
                        } else if (isMine) {
                          displaySubtitle = 'Sent · $displaySubtitle';
                        }"""

new_logic = """                        if (isMine) {
                          displaySubtitle = 'Sent · $displaySubtitle';
                        }"""

content = content.replace(old_logic, new_logic)

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
