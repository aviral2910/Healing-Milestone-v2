with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

# I will just write a completely new, beautiful InboxScreen.
import os

new_inbox = """import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/chat/presentation/providers/chat_providers.dart';
import 'package:healing_milestones/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';
import 'package:timeago/timeago.dart' as timeago;

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_square),
              onPressed: () {
                // Future feature: start new chat
              },
            ),
          ],
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            tabs: const [
              Tab(text: 'Messages'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_ActiveChatsList(), _PendingRequestsList()],
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 16),
                const Text('No messages yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Send a message to start a conversation.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: chats.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final chat = chats[index];
            final currentUser = ref.watch(currentUserProvider);
            if (currentUser == null) return const SizedBox.shrink();

            final otherUserId = chat.participants.firstWhere(
              (id) => id != currentUser.userId,
              orElse: () => chat.participants.first,
            );

            if (chat.type == 'support') {
              return _ChatListTile(
                title: 'Healing Milestones Support',
                subtitle: chat.lastMessageText.isEmpty ? 'No messages yet' : chat.lastMessageText,
                time: chat.lastMessageTime,
                isUnread: false,
                isSentRequest: false,
                leading: const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.support_agent, color: Colors.white, size: 32),
                ),
                onTap: () => _navigateToChat(context, chat.id, chat.type),
              );
            }

            final otherUserAsync = ref.watch(userByIdProvider(otherUserId));

            return otherUserAsync.when(
              data: (otherUser) {
                if (otherUser == null) return const SizedBox.shrink();
                final isSentRequest = chat.status == 'pending' && chat.initiatorId == currentUser.userId;
                final isUnread = (chat.unreadCount[currentUser.userId] ?? 0) > 0;
                
                return _ChatListTile(
                  title: otherUser.displayName,
                  subtitle: isSentRequest
                        ? 'Request sent · ${chat.lastMessageText.isEmpty ? "Say hi!" : chat.lastMessageText}'
                        : (chat.lastMessageText.isEmpty ? 'Say hi!' : chat.lastMessageText),
                  time: chat.lastMessageTime,
                  isUnread: isUnread,
                  isSentRequest: isSentRequest,
                  leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 28),
                  onTap: () => _navigateToChat(context, chat.id, chat.type),
                );
              },
              loading: () => const ListTile(leading: AppLoader.small(), title: Text('Loading...')),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
        );
      },
      loading: () => const Center(child: AppLoader()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  void _navigateToChat(BuildContext context, String roomId, String roomType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(roomId: roomId, roomType: roomType),
      ),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_read_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: 16),
                const Text('No message requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: chats.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final chat = chats[index];
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
                
                return _ChatListTile(
                  title: otherUser.displayName,
                  subtitle: chat.lastMessageText.isEmpty ? 'Wants to message you' : chat.lastMessageText,
                  time: chat.lastMessageTime,
                  isUnread: true,
                  isSentRequest: false,
                  leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 28),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(roomId: chat.id, roomType: chat.type),
                      ),
                    );
                  },
                  trailingAction: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 28),
                        onPressed: () => ref.read(chatRepositoryProvider).declineChat(chat.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                        onPressed: () => ref.read(chatRepositoryProvider).acceptChat(chat.id),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const ListTile(leading: AppLoader.small(), title: Text('Loading...')),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
        );
      },
      loading: () => const Center(child: AppLoader()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime? time;
  final bool isUnread;
  final bool isSentRequest;
  final Widget leading;
  final VoidCallback onTap;
  final Widget? trailingAction;

  const _ChatListTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.isSentRequest,
    required this.leading,
    required this.onTap,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSentRequest ? Theme.of(context).colorScheme.onSurfaceVariant : (isUnread ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant),
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (time != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          '· ${timeago.format(time!, locale: 'en_short')}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (trailingAction != null) ...[
              const SizedBox(width: 8),
              trailingAction!,
            ] else if (isUnread) ...[
              const SizedBox(width: 12),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
"""

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(new_inbox)
