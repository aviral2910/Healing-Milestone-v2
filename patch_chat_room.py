import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# Make sure imports are there
if "import 'package:healing_milestones/shared/widgets/app_avatar.dart';" not in content:
    content = "import 'package:healing_milestones/shared/widgets/app_avatar.dart';\n" + content

if "import 'package:healing_milestones/shared/widgets/app_loader.dart';" not in content:
    content = "import 'package:healing_milestones/shared/widgets/app_loader.dart';\n" + content


old_appbar = """      appBar: AppBar(
        title: Text(widget.roomType == 'support' ? 'Support Chat' : 'Chat'),
      ),"""

new_appbar = """      appBar: AppBar(
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

content = content.replace(old_appbar, new_appbar)

# Fix loading indicator
content = content.replace('const Center(child: CircularProgressIndicator())', 'const Center(child: AppLoader())')

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
