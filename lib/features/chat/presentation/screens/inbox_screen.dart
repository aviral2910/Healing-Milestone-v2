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
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
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
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                  ),
                  child: Icon(Icons.maps_ugc_rounded, size: 48, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 24),
                Text('No Messages', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Start a conversation.', 
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: chats.length,
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
                        final isMine = chat.lastMessageSenderId == currentUser.userId;
                        
                        String displaySubtitle = chat.lastMessageText;
                        if (displaySubtitle.isEmpty) {
                          displaySubtitle = isMine ? 'Sent a message' : 'Say hi!';
                        }
                        
                        if (isSentRequest) {
                          displaySubtitle = 'Request sent · $displaySubtitle';
                        } else if (isMine) {
                          displaySubtitle = 'Sent · $displaySubtitle';
                        }

                        return _ChatListTile(
                          title: otherUser.displayName,
                          subtitle: displaySubtitle,
                          time: chat.lastMessageTime,
                          isUnread: isUnread && !isMine,
                          isSentRequest: isSentRequest,
                          isMine: isMine,
                          leading: AppAvatar(imageUrl: otherUser.profilePicture, radius: 28),
                          onTap: () => _navigateToChat(context, chat.id, chat.type),
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) {
                                return Container(
                                  margin: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 12),
                                      Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      AppAvatar(imageUrl: otherUser.profilePicture, radius: 32),
                                      const SizedBox(height: 12),
                                      Text(
                                        otherUser.displayName,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 24),
                                      Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(ctx).pop();
                                          ref.read(chatRepositoryProvider).deleteChatRoom(chat.id);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.delete_outline, color: Colors.redAccent),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Delete Chat',
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  color: Colors.redAccent,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
                                      InkWell(
                                        onTap: () => Navigator.of(ctx).pop(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Cancel',
                                                style: theme.textTheme.titleMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                                    ],
                                  ),
                                );
                              }
                            );
                          },
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
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                  ),
                  child: Icon(Icons.mark_email_read_rounded, size: 48, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 24),
                Text('No Message Requests', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
  final bool isMine;
  final Widget leading;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget? trailingAction;

  const _ChatListTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
    required this.isSentRequest,
    this.isMine = false,
    required this.leading,
    required this.onTap,
    this.onLongPress,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
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
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                      letterSpacing: -0.3,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: (isSentRequest || isMine)
                                ? theme.colorScheme.onSurfaceVariant 
                                : (isUnread ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant),
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (time != null)
                        Text(
                          ' · ${timeago.format(time!, locale: 'en_short')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
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
