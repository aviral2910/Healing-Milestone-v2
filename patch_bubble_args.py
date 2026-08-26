with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# Pass roomId
content = content.replace(
    'return _MessageBubble(msg: msg, isMe: isMe);',
    'return _MessageBubble(msg: msg, isMe: isMe, roomId: widget.roomId);'
)

# Update constructor
old_bubble_class = """class _MessageBubble extends ConsumerWidget {
  final ChatMessage msg;
  final bool isMe;

  const _MessageBubble({required this.msg, required this.isMe});"""

new_bubble_class = """class _MessageBubble extends ConsumerWidget {
  final ChatMessage msg;
  final bool isMe;
  final String roomId;

  const _MessageBubble({required this.msg, required this.isMe, required this.roomId});"""

content = content.replace(old_bubble_class, new_bubble_class)

# Update deleteMessage call
content = content.replace(
    'if (msg.roomId != null) {\n                    ref.read(chatRepositoryProvider).deleteMessage(msg.roomId!, msg.id);\n                  }',
    'ref.read(chatRepositoryProvider).deleteMessage(roomId, msg.id);'
)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
