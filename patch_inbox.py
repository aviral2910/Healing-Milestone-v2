import re

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

old_badge = """                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),"""

new_badge = """                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),"""

content = content.replace(old_badge, new_badge)

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
