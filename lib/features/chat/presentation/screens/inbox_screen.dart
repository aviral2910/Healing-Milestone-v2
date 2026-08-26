import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/chat/presentation/providers/chat_providers.dart';
import 'package:healing_milestones/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ActiveChatsList(),
            _PendingRequestsList(),
          ],
        ),
      ),
    );
  }
}

class _ActiveChatsList extends ConsumerWidget {
  const _ActiveChatsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChatsAsync = ref.watch(activeChatsProvider);

    return activeChatsAsync.when(
      data: (chats) {
        if (chats.isEmpty) {
          return const Center(child: Text('No active chats.'));
        }
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
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
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _PendingRequestsList extends ConsumerWidget {
  const _PendingRequestsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingRequestsAsync = ref.watch(pendingRequestsProvider);

    return pendingRequestsAsync.when(
      data: (chats) {
        if (chats.isEmpty) {
          return const Center(child: Text('No message requests.'));
        }
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_add)),
              title: const Text('Message Request'),
              subtitle: const Text('Someone wants to chat with you.'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      ref.read(chatRepositoryProvider).declineChat(chat.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      ref.read(chatRepositoryProvider).acceptChat(chat.id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
