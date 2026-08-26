with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

old_tile_usage = """                return _ChatListTile(
                  title: otherUser.displayName,
                  subtitle: isSentRequest
                        ? 'Request sent · ${chat.lastMessageText.isEmpty ? "Say hi!" : chat.lastMessageText}'
                        : (chat.lastMessageText.isEmpty ? 'Say hi!' : chat.lastMessageText),
                  time: chat.lastMessageTime,
                  isUnread: isUnread,
                  isSentRequest: isSentRequest,
                  leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 28),
                  onTap: () => _navigateToChat(context, chat.id, chat.type),
                );"""

new_tile_usage = """                return Dismissible(
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

content = content.replace(old_tile_usage, new_tile_usage)
with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
