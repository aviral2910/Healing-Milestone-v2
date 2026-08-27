import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

old_code = """        // Once popped, mark as viewed!
        // wait, we need the roomId. We don't have roomId in _MessageBubble easily.
        // Actually, we do if we pass it, or we can just access it.
      },"""

new_code = """        // Once popped, mark as viewed!
        ref.read(chatRepositoryProvider).markMessageAsViewed(roomId, msg.id);
      },"""

content = content.replace(old_code, new_code)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
