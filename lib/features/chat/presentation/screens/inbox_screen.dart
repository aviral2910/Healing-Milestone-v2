import 'package:healing_milestones/features/auth/data/auth_provider.dart';
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
    final theme = Theme.of(context);
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Messages', 
            style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_square),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: theme.textTheme.titleMedium,
            unselectedLabelStyle: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            tabs: const [
              Tab(text: 'Primary'),
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
    final theme = Theme.of(context);

    return activeChatsAsync.when(
      data: (chats) {
        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Icon(Icons.send_rounded, size: 48, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 24),
                Text('Your Messages', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Send private messages to friends.', 
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: chats.length,
          padding: const EdgeInsets.only(top: 8, bottom: 24),
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
                title: 'Support',
                subtitle: chat.lastMessageText.isEmpty ? 'No messages yet' : chat.lastMessageText,
                time: chat.lastMessageTime,
                isUnread: false,
                isSentRequest: false,
                leading: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.support_agent, color: theme.colorScheme.onPrimary, size: 28),
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
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(children: [AppLoader.small(), SizedBox(width: 16), Text('Loading...')]),
              ),
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
    final theme = Theme.of(context);

    return pendingRequestsAsync.when(
      data: (chats) {
        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Icon(Icons.mark_email_read_outlined, size: 48, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 24),
                Text('No message requests', style: theme.textTheme.titleLarge),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: chats.length,
          padding: const EdgeInsets.only(top: 8, bottom: 24),
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
                        icon: Icon(Icons.cancel, color: theme.colorScheme.onSurfaceVariant, size: 28),
                        onPressed: () => ref.read(chatRepositoryProvider).declineChat(chat.id),
                      ),
                      IconButton(
                        icon: Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 28),
                        onPressed: () => ref.read(chatRepositoryProvider).acceptChat(chat.id),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(children: [AppLoader.small(), SizedBox(width: 16), Text('Loading...')]),
              ),
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
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSentRequest 
                                ? theme.colorScheme.onSurfaceVariant 
                                : (isUnread ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant),
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (time != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '· ${timeago.format(time!, locale: 'en_short')}',
                          style: theme.textTheme.bodySmall,
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
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
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
