import re

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

old_logic = """                        if (displaySubtitle.isEmpty) {
                          displaySubtitle = isMine ? 'Sent a message' : 'Say hi!';
                        }
                        
                        if (isMine) {
                          displaySubtitle = 'Sent · $displaySubtitle';
                        }"""

new_logic = """                        if (displaySubtitle.isEmpty) {
                          displaySubtitle = isMine ? 'Sent a message' : 'Say hi!';
                        }
                        
                        if (isSentRequest) {
                          displaySubtitle = 'Request sent';
                        } else if (isMine) {
                          displaySubtitle = 'Sent · $displaySubtitle';
                        }"""

content = content.replace(old_logic, new_logic)

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
