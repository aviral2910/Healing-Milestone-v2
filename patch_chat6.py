import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# 1. Update the color definitions at the start of _MessageBubble.build
old_build_start = """  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector("""

new_build_start = """  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Sleek monochrome palette
    final sentColor = isDark 
        ? Colors.white.withValues(alpha: 0.2) 
        : const Color(0xFF1C1C1E); 
        
    final receivedColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF1F1F1);

    final sentTextColor = Colors.white;
    final receivedTextColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector("""
content = content.replace(old_build_start, new_build_start)

# 2. Update BoxDecoration
old_box = """          decoration: BoxDecoration(
            gradient: isMe
                ? const LinearGradient(
                    colors: [Color(0xFF007AFF), Color(0xFF0056FF)], // Sleek iOS/Messenger Blue
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  )
                : null,
            color: isMe
                ? null
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),"""

new_box = """          decoration: BoxDecoration(
            color: isMe ? sentColor : receivedColor,"""
content = content.replace(old_box, new_box)

# 3. Update Text Colors
old_text_color = """                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isMe
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),"""

new_text_color = """                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isMe ? sentTextColor : receivedTextColor,
                  ),"""
content = content.replace(old_text_color, new_text_color)

old_time_color = """                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isMe
                        ? Colors.white70
                        : theme.colorScheme.onSurfaceVariant,
                  ),"""

new_time_color = """                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isMe 
                        ? sentTextColor.withValues(alpha: 0.6) 
                        : receivedTextColor.withValues(alpha: 0.6),
                  ),"""
content = content.replace(old_time_color, new_time_color)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
