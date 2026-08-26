with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

imports = """import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'package:healing_milestones/core/widgets/app_loader.dart';
"""
if "import 'package:healing_milestones/shared/widgets/app_avatar.dart';" not in content:
    content = imports + content

old_active_list = """          itemBuilder: (context, index) {
            final chat = chats[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('Chat with ${chat.type == "support" ? "Support" : "User"}'),
              subtitle: Text(
                chat.lastMessageText.isEmpty ? 'No messages yet' : chat.lastMessageText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: chat.lastMessageTime != null
                  ? Text(timeago.format(chat.lastMessageTime!))
                  : null,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatRoomScreen(
                      roomId: chat.id,
                      roomType: chat.type,
                    ),
                  ),
                );
              },
            );
          },"""

new_active_list = """          itemBuilder: (context, index) {
            final chat = chats[index];
            final currentUser = ref.watch(currentUserProvider);
            if (currentUser == null) return const SizedBox.shrink();
            
            final otherUserId = chat.participants.firstWhere(
              (id) => id != currentUser.userId,
              orElse: () => chat.participants.first,
            );

            if (chat.type == 'support') {
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.support_agent, color: Colors.white), backgroundColor: Colors.blue),
                title: const Text('Healing Milestones Support', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  chat.lastMessageText.isEmpty ? 'No messages yet' : chat.lastMessageText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: chat.lastMessageTime != null
                    ? Text(timeago.format(chat.lastMessageTime!))
                    : null,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatRoomScreen(
                        roomId: chat.id,
                        roomType: chat.type,
                      ),
                    ),
                  );
                },
              );
            }

            final otherUserAsync = ref.watch(userByIdProvider(otherUserId));

            return otherUserAsync.when(
              data: (otherUser) {
                if (otherUser == null) return const SizedBox.shrink();
                return ListTile(
                  leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 24),
                  title: Text(otherUser.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    chat.lastMessageText.isEmpty ? 'Say hi!' : chat.lastMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: (chat.unreadCount[currentUser.userId] ?? 0) > 0 
                          ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: chat.lastMessageTime != null
                      ? Text(timeago.format(chat.lastMessageTime!))
                      : null,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          roomId: chat.id,
                          roomType: chat.type,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const ListTile(leading: AppLoader.small(), title: Text('Loading...')),
              error: (_, __) => const SizedBox.shrink(),
            );
          },"""
content = content.replace(old_active_list, new_active_list)

old_pending_list = """          itemBuilder: (context, index) {
            final chat = requests[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Chat Request'),
              subtitle: const Text('Someone wants to message you.'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      ref.read(chatRepositoryProvider).acceptChat(chat.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      ref.read(chatRepositoryProvider).declineChat(chat.id);
                    },
                  ),
                ],
              ),
            );
          },"""

new_pending_list = """          itemBuilder: (context, index) {
            final chat = requests[index];
            final currentUser = ref.watch(currentUserProvider);
            if (currentUser == null) return const SizedBox.shrink();
            
            final otherUserId = chat.participants.firstWhere(
              (id) => id != currentUser.userId,
              orElse: () => chat.participants.first,
            );

            final otherUserAsync = ref.watch(userByIdProvider(otherUserId));

            return otherUserAsync.when(
              data: (otherUser) {
                if (otherUser == null) return const SizedBox.shrink();
                return ListTile(
                  leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 24),
                  title: Text(otherUser.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    chat.lastMessageText.isEmpty ? 'Wants to message you' : chat.lastMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                        onPressed: () {
                          ref.read(chatRepositoryProvider).acceptChat(chat.id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                        onPressed: () {
                          ref.read(chatRepositoryProvider).declineChat(chat.id);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // You can let them read the message before accepting, like Insta
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          roomId: chat.id,
                          roomType: chat.type,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const ListTile(leading: AppLoader.small(), title: Text('Loading...')),
              error: (_, __) => const SizedBox.shrink(),
            );
          },"""

content = content.replace(old_pending_list, new_pending_list)

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
