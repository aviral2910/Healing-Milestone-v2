import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# Fix colors in _buildSharedCard
old_card_colors = """  Widget _buildSharedCard({
    required BuildContext context,
    required WidgetRef ref,
    required String id,
    required bool isJourney,
    required bool isMe,
  }) {
    final mediaState = ref.watch(batchMediaProvider);
    final fgColor = isMe ? Colors.white : Colors.black87;
    final bgColor = isMe
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.05);"""

new_card_colors = """  Widget _buildSharedCard({
    required BuildContext context,
    required WidgetRef ref,
    required String id,
    required bool isJourney,
    required bool isMe,
  }) {
    final theme = Theme.of(context);
    final mediaState = ref.watch(batchMediaProvider);
    final fgColor = isMe ? Colors.white : theme.colorScheme.onSurface;
    final bgColor = isMe
        ? Colors.white.withValues(alpha: 0.2)
        : theme.colorScheme.onSurface.withValues(alpha: 0.08);"""
content = content.replace(old_card_colors, new_card_colors)

# Fix colors in _buildSharedProfileCard
old_profile_colors = """  Widget _buildSharedProfileCard({
    required BuildContext context,
    required WidgetRef ref,
    required String profileId,
    required bool isMe,
  }) {
    final fgColor = isMe ? Colors.white : Colors.black87;
    final bgColor = isMe
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.05);"""

new_profile_colors = """  Widget _buildSharedProfileCard({
    required BuildContext context,
    required WidgetRef ref,
    required String profileId,
    required bool isMe,
  }) {
    final theme = Theme.of(context);
    final fgColor = isMe ? Colors.white : theme.colorScheme.onSurface;
    final bgColor = isMe
        ? Colors.white.withValues(alpha: 0.2)
        : theme.colorScheme.onSurface.withValues(alpha: 0.08);"""
content = content.replace(old_profile_colors, new_profile_colors)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
