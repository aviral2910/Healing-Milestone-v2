import re

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

# 1. Fix the AppBar title to be sleek
old_appbar = """        appBar: AppBar(
          title: Text(
            'Messages', 
            style: theme.textTheme.headlineLarge?.copyWith(fontSize: 28),
          ),"""

new_appbar = """        appBar: AppBar(
          title: Text(
            'Messages', 
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),"""

content = content.replace(old_appbar, new_appbar)

# 2. Fix the ActiveChatsList to remove search bar and use normal ListView
old_active_list = """    return activeChatsAsync.when(
      data: (chats) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Search Bar
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
            
            // Empty State
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

new_active_list = """    return activeChatsAsync.when(
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
          itemBuilder: (context, index) {"""

content = content.replace(old_active_list, new_active_list)


# 3. Fix the bottom of the ActiveChatsList
old_active_end = """                  },
                  childCount: chats.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
      loading: () => const Center(child: AppLoader()),"""

new_active_end = """          },
        );
      },
      loading: () => const Center(child: AppLoader()),"""

content = content.replace(old_active_end, new_active_end)

# 4. Fix fonts in _ChatListTile
old_tile_fonts = """                  Text(
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
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),"""

new_tile_fonts = """                  Text(
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
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSentRequest 
                                ? theme.colorScheme.onSurfaceVariant 
                                : (isUnread ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant),
                            fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (time != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '· ${timeago.format(time!, locale: 'en_short')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),"""

content = content.replace(old_tile_fonts, new_tile_fonts)

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
