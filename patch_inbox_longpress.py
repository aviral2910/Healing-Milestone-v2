with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

# 1. Update _ChatListTile class definition
old_tile_def = """  final VoidCallback onTap;
  final Widget? trailingAction;

  const _ChatListTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.isSentRequest,
    required this.leading,
    required this.onTap,
    this.trailingAction,
  });"""

new_tile_def = """  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? trailingAction;

  const _ChatListTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.isSentRequest,
    required this.leading,
    required this.onTap,
    this.onLongPress,
    this.trailingAction,
  });"""
content = content.replace(old_tile_def, new_tile_def)

# 2. Add onLongPress to InkWell
content = content.replace("onTap: onTap,\n      child: Padding(", "onTap: onTap,\n      onLongPress: onLongPress,\n      child: Padding(")

# 3. Replace Dismissible usage with just _ChatListTile with onLongPress
old_dismissible = """                return Dismissible(
                  key: Key(chat.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    color: Colors.redAccent,
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text("Delete Chat?"),
                          content: const Text("This will permanently delete the chat for you."),
                          actions: <Widget>[
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    ref.read(chatRepositoryProvider).deleteChatRoom(chat.id);
                  },
                  child: _ChatListTile(
                    title: otherUser.displayName,
                    subtitle: isSentRequest
                          ? 'Request sent · ${chat.lastMessageText.isEmpty ? "Say hi!" : chat.lastMessageText}'
                          : (chat.lastMessageText.isEmpty ? 'Say hi!' : chat.lastMessageText),
                    time: chat.lastMessageTime,
                    isUnread: isUnread,
                    isSentRequest: isSentRequest,
                    leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 28),
                    onTap: () => _navigateToChat(context, chat.id, chat.type),
                  ),
                );"""

new_tile_usage = """                return _ChatListTile(
                  title: otherUser.displayName,
                  subtitle: isSentRequest
                        ? 'Request sent · ${chat.lastMessageText.isEmpty ? "Say hi!" : chat.lastMessageText}'
                        : (chat.lastMessageText.isEmpty ? 'Say hi!' : chat.lastMessageText),
                  time: chat.lastMessageTime,
                  isUnread: isUnread,
                  isSentRequest: isSentRequest,
                  leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 28),
                  onTap: () => _navigateToChat(context, chat.id, chat.type),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text("Delete Chat?"),
                          content: const Text("This will permanently delete the chat for you."),
                          actions: <Widget>[
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                ref.read(chatRepositoryProvider).deleteChatRoom(chat.id);
                              },
                              child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );"""
content = content.replace(old_dismissible, new_tile_usage)

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
