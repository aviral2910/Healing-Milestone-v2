import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# 1. Update BoxDecoration in _MessageBubble
old_box = """          decoration: BoxDecoration(
            color: isMe
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(22).copyWith("""

new_box = """          decoration: BoxDecoration(
            gradient: isMe
                ? const LinearGradient(
                    colors: [Color(0xFF007AFF), Color(0xFF0056FF)], // Sleek iOS/Messenger Blue
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  )
                : null,
            color: isMe
                ? null
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(22).copyWith("""
content = content.replace(old_box, new_box)

# 2. Ensure text colors contrast well with the gradient (White for isMe)
old_text_color = """                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),"""

new_text_color = """                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isMe
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),"""
content = content.replace(old_text_color, new_text_color)

# 3. Ensure timestamp text color also contrasts well
old_time_color = """                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isMe
                        ? theme.colorScheme.onPrimary.withOpacity(0.7)
                        : theme.colorScheme.onSurfaceVariant,
                  ),"""

new_time_color = """                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isMe
                        ? Colors.white70
                        : theme.colorScheme.onSurfaceVariant,
                  ),"""
content = content.replace(old_time_color, new_time_color)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
