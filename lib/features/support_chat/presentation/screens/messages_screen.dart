import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/support_chat/presentation/providers/chat_providers.dart';
import 'package:intl/intl.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final bool isActiveTab;

  const MessagesScreen({
    Key? key,
    required this.scrollController,
    required this.isActiveTab,
  }) : super(key: key);

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider).value;
    final isAuthenticated = authState?.status == AuthStatus.authenticated;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: true,
            centerTitle: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Inbox',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 28,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (!isAuthenticated)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.mark_chat_unread_outlined,
                            size: 48, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Join the Conversation',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Log in to message support and get the help you need.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFA1A1A6),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => context.push(AppRoutes.login),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                        ),
                        child: const Text(
                          'Log In or Sign Up',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, child) {
                    final chatIdAsync = ref.watch(supportChatIdProvider);

                    return chatIdAsync.when(
                      data: (chatId) {
                        final chatAsync = ref.watch(supportChatStreamProvider(chatId));

                        return chatAsync.when(
                          data: (chat) {
                            if (chat == null) return const SizedBox.shrink();

                            final currentUser = ref.watch(currentUserProvider);
                            final unreadCount = currentUser != null
                                ? (chat.unreadCount[currentUser.userId] ?? 0)
                                : 0;
                            final hasUnread = unreadCount > 0;
                            final String timeString = _formatTime(chat.lastUpdated);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: hasUnread 
                                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: hasUnread
                                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                      : theme.dividerColor.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                                boxShadow: hasUnread
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () => context.push(AppRoutes.supportChat),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Premium Avatar
                                        _buildAvatar(theme, hasUnread),
                                        const SizedBox(width: 16),
                                        // Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Healing Milestones Team',
                                                      style: theme.textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 16,
                                                        letterSpacing: -0.3,
                                                        color: theme.colorScheme.onSurface,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (timeString.isNotEmpty)
                                                    Text(
                                                      timeString,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: hasUnread 
                                                            ? theme.colorScheme.primary 
                                                            : const Color(0xFFA1A1A6),
                                                        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      chat.lastMessage.isNotEmpty
                                                          ? chat.lastMessage
                                                          : 'Tap to start a conversation with our support team.',
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        color: hasUnread
                                                            ? theme.colorScheme.onSurface
                                                            : const Color(0xFFA1A1A6),
                                                        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                                                        fontSize: 14,
                                                        height: 1.3,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (hasUnread)
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 12),
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme.primary,
                                                        borderRadius: BorderRadius.circular(12),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                                            blurRadius: 8,
                                                            offset: const Offset(0, 2),
                                                          )
                                                        ],
                                                      ),
                                                      child: Text(
                                                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (e, s) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Text(
                                'Could not load chat.\n$e',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFFA1A1A6)),
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const Center(
                          child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: const AppLoader.small(),
                      )),
                      error: (e, s) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Color(0xFFA1A1A6)),
                            const SizedBox(height: 16),
                            const Text('Failed to load messages', style: TextStyle(color: Color(0xFFA1A1A6))),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () => ref.invalidate(supportChatIdProvider),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, bool hasUnread) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: theme.scaffoldBackgroundColor,
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.support_agent_rounded,
              color: theme.colorScheme.onPrimary,
              size: 32,
            ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: hasUnread ? Colors.redAccent : Colors.greenAccent[400],
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.scaffoldBackgroundColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (hasUnread ? Colors.redAccent : Colors.greenAccent[400]!)
                      .withValues(alpha: 0.4),
                  blurRadius: 8,
                )
              ]
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (now.day != date.day) {
        return 'Yesterday';
      }
      return DateFormat.jm().format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date);
    } else {
      return DateFormat('MM/dd/yy').format(date);
    }
  }
}
