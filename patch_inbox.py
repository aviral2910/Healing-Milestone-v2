import re

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

old_logic = """                        final isSentRequest = chat.status == 'pending' && chat.initiatorId == currentUser.userId;
                        final isUnread = (chat.unreadCount[currentUser.userId] ?? 0) > 0;
                        
                        return _ChatListTile(
                          title: otherUser.displayName,
                          subtitle: isSentRequest
                                ? 'Request sent · ${chat.lastMessageText.isEmpty ? "Say hi!" : chat.lastMessageText}'
                                : (chat.lastMessageText.isEmpty ? 'Say hi!' : chat.lastMessageText),
                          time: chat.lastMessageTime,
                          isUnread: isUnread,
                          isSentRequest: isSentRequest,
                          leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 28),"""

new_logic = """                        final isSentRequest = chat.status == 'pending' && chat.initiatorId == currentUser.userId;
                        final isUnread = (chat.unreadCount[currentUser.userId] ?? 0) > 0;
                        final isMine = chat.lastMessageSenderId == currentUser.userId;
                        
                        String displaySubtitle = chat.lastMessageText;
                        if (displaySubtitle.isEmpty) {
                          displaySubtitle = isMine ? 'Sent a message' : 'Say hi!';
                        }
                        
                        if (isSentRequest) {
                          displaySubtitle = 'Request sent · $displaySubtitle';
                        } else if (isMine) {
                          displaySubtitle = 'Sent · $displaySubtitle';
                        }

                        return _ChatListTile(
                          title: otherUser.displayName,
                          subtitle: displaySubtitle,
                          time: chat.lastMessageTime,
                          isUnread: isUnread && !isMine,
                          isSentRequest: isSentRequest,
                          isMine: isMine,
                          leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 28),"""

content = content.replace(old_logic, new_logic)


old_tile_constructor = """class _ChatListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime? time;
  final bool isUnread;
  final bool isSentRequest;
  final Widget leading;
  final VoidCallback onTap;
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

new_tile_constructor = """class _ChatListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime? time;
  final bool isUnread;
  final bool isSentRequest;
  final bool isMine;
  final Widget leading;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? trailingAction;

  const _ChatListTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.isSentRequest,
    this.isMine = false,
    required this.leading,
    required this.onTap,
    this.onLongPress,
    this.trailingAction,
  });"""

content = content.replace(old_tile_constructor, new_tile_constructor)


old_tile_fonts = """                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSentRequest 
                                ? theme.colorScheme.onSurfaceVariant 
                                : (isUnread ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant),
                            fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),"""

new_tile_fonts = """                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: (isSentRequest || isMine)
                                ? theme.colorScheme.onSurfaceVariant 
                                : (isUnread ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant),
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),"""

content = content.replace(old_tile_fonts, new_tile_fonts)

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
