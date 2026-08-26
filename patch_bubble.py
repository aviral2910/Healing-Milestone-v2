with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

old_bubble_build = """  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),"""

new_bubble_build = """  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onLongPress: isMe ? () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Unsend Message?'),
            content: const Text('This will permanently delete the message for everyone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (msg.roomId != null) {
                    ref.read(chatRepositoryProvider).deleteMessage(msg.roomId!, msg.id);
                  }
                },
                child: const Text('Unsend', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      } : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),"""
content = content.replace(old_bubble_build, new_bubble_build)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
