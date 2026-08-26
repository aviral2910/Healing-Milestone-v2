import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# Replace AppBar
old_appbar = """      appBar: AppBar(
        titleSpacing: 0,
        title: Builder(
          builder: (context) {
            if (widget.roomType == 'support') {
              return Row(
                children: [
                  const CircleAvatar(radius: 18, backgroundColor: Colors.blue, child: Icon(Icons.support_agent, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  const Text('Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              );
            }

            String? otherUserId;
            if (widget.roomId.startsWith('chat_') && currentUser != null) {
              final parts = widget.roomId.split('_');
              if (parts.length == 3) {
                if (parts[1] == currentUser.userId) otherUserId = parts[2];
                else if (parts[2] == currentUser.userId) otherUserId = parts[1];
              }
            }

            if (otherUserId == null) return const Text('Chat');

            final otherUserAsync = ref.watch(userByIdProvider(otherUserId));
            return otherUserAsync.when(
              data: (user) {
                if (user == null) return const Text('User');
                return Row(
                  children: [
                    AppAvatar(imageUrl: user.profilePicture, radius: 18),
                    const SizedBox(width: 12),
                    Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                );
              },
              loading: () => const Text('Loading...'),
              error: (_, __) => const Text('Chat'),
            );
          },
        ),
      ),"""

new_appbar = """      appBar: AppBar(
        titleSpacing: 0,
        title: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            
            if (widget.roomType == 'support') {
              return Row(
                children: [
                  CircleAvatar(radius: 18, backgroundColor: theme.colorScheme.primary, child: Icon(Icons.support_agent, color: theme.colorScheme.onPrimary, size: 20)),
                  const SizedBox(width: 12),
                  Text('Healing Milestones Support', style: theme.textTheme.titleMedium),
                ],
              );
            }

            String? otherUserId;
            if (widget.roomId.startsWith('chat_') && currentUser != null) {
              final parts = widget.roomId.split('_');
              if (parts.length == 3) {
                if (parts[1] == currentUser.userId) otherUserId = parts[2];
                else if (parts[2] == currentUser.userId) otherUserId = parts[1];
              }
            }

            if (otherUserId == null) return Text('Chat', style: theme.textTheme.titleMedium);

            final otherUserAsync = ref.watch(userByIdProvider(otherUserId));
            return otherUserAsync.when(
              data: (user) {
                if (user == null) return Text('User', style: theme.textTheme.titleMedium);
                return Row(
                  children: [
                    AppAvatar(imageUrl: user.profilePicture, radius: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(user.displayName, style: theme.textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                );
              },
              loading: () => Text('Loading...', style: theme.textTheme.titleMedium),
              error: (_, __) => Text('Chat', style: theme.textTheme.titleMedium),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {}, // Future profile view
          ),
        ],
      ),"""
content = content.replace(old_appbar, new_appbar)

# Replace Input Area
old_input = """  Widget _buildInputArea(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined),
              onPressed: _isSending ? null : _pickAndSendImage,
            ),
            // TODO: Add attachment icon for Journeys/Stories
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendTextMessage(),
              ),
            ),
            const SizedBox(width: 8),
            if (_isSending)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              IconButton(
                icon: const Icon(Icons.send_rounded),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _sendTextMessage,
              ),
          ],
        ),
      ),
    );
  }"""

new_input = """  Widget _buildInputArea(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12.0, top: 8.0),
        color: theme.scaffoldBackgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              padding: const EdgeInsets.all(12),
              icon: Icon(Icons.camera_alt_outlined, color: theme.colorScheme.onSurface),
              onPressed: _isSending ? null : _pickAndSendImage,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: theme.textTheme.bodyLarge,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendTextMessage(),
                      ),
                    ),
                    if (_isSending)
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.send_rounded, color: theme.colorScheme.primary),
                        onPressed: _sendTextMessage,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }"""
content = content.replace(old_input, new_input)


# Replace MessageBubble Text
old_bubble_text = """            if (msg.text != null && msg.text!.isNotEmpty)
              Text(
                msg.text!,
                style: TextStyle(
                  color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
            const SizedBox(height: 4),
            if (msg.createdAt != null)
              Text(
                timeago.format(msg.createdAt!),
                style: TextStyle(
                  fontSize: 10,
                  color: isMe ? theme.colorScheme.onPrimary.withValues(alpha: 0.7) : theme.colorScheme.onSurfaceVariant,
                ),
              ),"""

new_bubble_text = """            if (msg.text != null && msg.text!.isNotEmpty)
              Text(
                msg.text!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
            const SizedBox(height: 4),
            if (msg.createdAt != null)
              Text(
                timeago.format(msg.createdAt!),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: isMe ? theme.colorScheme.onPrimary.withOpacity(0.7) : theme.colorScheme.onSurfaceVariant,
                ),
              ),"""
content = content.replace(old_bubble_text, new_bubble_text)


with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
