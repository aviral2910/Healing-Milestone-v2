import re

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

# 1. Update _ChatListTile constructor and fields
old_tile_def = """class _ChatListTile extends StatelessWidget {
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

new_tile_def = """class _ChatListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime? time;
  final bool isUnread;
  final int unreadCount;
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
    this.unreadCount = 0,
    required this.isSentRequest,
    this.isMine = false,
    required this.leading,
    required this.onTap,
    this.onLongPress,
    this.trailingAction,
  });"""

content = content.replace(old_tile_def, new_tile_def)


# 2. Update text styles (opacity)
old_text_styles = """                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: (isSentRequest || isMine)
                                ? theme.colorScheme.onSurfaceVariant 
                                : (isUnread ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant),
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 13,
                          ),"""

new_text_styles = """                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isUnread 
                                ? theme.colorScheme.onSurface 
                                : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 13,
                          ),"""
content = content.replace(old_text_styles, new_text_styles)

# Update Time opacity
old_time_style = """                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),"""
new_time_style = """                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                            fontSize: 13,
                          ),"""
content = content.replace(old_time_style, new_time_style)

# 3. Update the trailing action to show a badge with number!
old_trailing = """            if (trailingAction != null) ...[
              const SizedBox(width: 8),
              trailingAction!,
            ] else if (isUnread) ...[
              const SizedBox(width: 12),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],"""

new_trailing = """            if (trailingAction != null) ...[
              const SizedBox(width: 8),
              trailingAction!,
            ] else if (unreadCount > 0) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ] else if (isUnread) ...[
              const SizedBox(width: 12),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],"""
content = content.replace(old_trailing, new_trailing)


# 4. Provide unreadCount in ActiveChatsList
old_active_call = """                        return _ChatListTile(
                          title: otherUser.displayName,
                          subtitle: displaySubtitle,
                          time: chat.lastMessageTime,
                          isUnread: isUnread && !isMine,
                          isSentRequest: isSentRequest,
                          isMine: isMine,
                          leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 28),"""

new_active_call = """                        return _ChatListTile(
                          title: otherUser.displayName,
                          subtitle: displaySubtitle,
                          time: chat.lastMessageTime,
                          isUnread: isUnread && !isMine,
                          unreadCount: (!isMine) ? (chat.unreadCount[currentUser.userId] ?? 0) : 0,
                          isSentRequest: isSentRequest,
                          isMine: isMine,
                          leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 28),"""
content = content.replace(old_active_call, new_active_call)

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
