import re

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

old_build = """  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChatsAsync = ref.watch(activeChatsProvider);
    final theme = Theme.of(context);

    return activeChatsAsync.when(
      data: (chats) {
        if (chats.isEmpty) {"""

new_build = """  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeChatsAsync = ref.watch(activeChatsProvider);
    final theme = Theme.of(context);

    return activeChatsAsync.when(
      data: (chats) {
        return CustomScrollView(
          slivers: [
            // Sleek Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(Icons.search, size: 20, color: theme.colorScheme.onSurfaceVariant),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
            ),
            
            if (chats.isEmpty)
              SliverFillRemaining(
                child: Center(
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
                      Text('No Messages Yet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Send private messages to friends.', 
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {"""

content = content.replace(old_build, new_build)

old_list_end = """          },
        );
      },
      loading: () => const Center(child: AppLoader()),"""

new_list_end = """                  },
                  childCount: chats.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
      loading: () => const Center(child: AppLoader()),"""

content = content.replace(old_list_end, new_list_end)


# Now update the long-press to use a premium Bottom Sheet instead of AlertDialog!
old_dialog = """                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text("Delete Chat?"),
                          content: const Text("This will permanently delete the chat for you."),
                          actions: <Widget>[
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                ref.read(chatRepositoryProvider).deleteChatRoom(chat.id);
                              },
                              child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        );
                      },
                    );
                  },"""

new_dialog = """                  onLongPress: () {
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
                  },"""

content = content.replace(old_dialog, new_dialog)

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
