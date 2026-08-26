import re

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

old_subtitle = """                  subtitle: Text(
                    chat.lastMessageText.isEmpty
                        ? 'Say hi!'
                        : chat.lastMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          (chat.unreadCount[currentUser.userId] ?? 0) > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),"""

new_subtitle = """                  subtitle: Text(
                    (chat.status == 'pending' && chat.initiatorId == currentUser.userId)
                        ? 'Request sent · ${chat.lastMessageText.isEmpty ? "Say hi!" : chat.lastMessageText}'
                        : (chat.lastMessageText.isEmpty ? 'Say hi!' : chat.lastMessageText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: (chat.status == 'pending' && chat.initiatorId == currentUser.userId) ? Colors.grey : null,
                      fontWeight:
                          (chat.unreadCount[currentUser.userId] ?? 0) > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),"""

content = content.replace(old_subtitle, new_subtitle)

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
