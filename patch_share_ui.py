import re

with open('lib/shared/widgets/direct_share_sheet.dart', 'r') as f:
    content = f.read()

# Replace the SliverList with a SliverGrid
old_list = """                                    return SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final room = validRooms[index];
                                          final otherUserId = room.participants.firstWhere(
                                            (id) => id != currentUser.userId,
                                            orElse: () => '',
                                          );
                                          if (otherUserId.isEmpty) return const SizedBox.shrink();
          
                                          final otherUserAsync = ref.watch(userByIdProvider(otherUserId));
          
                                          return otherUserAsync.when(
                                            data: (user) {
                                              if (user == null) return const SizedBox.shrink();
          
                                              if (_searchQuery.isNotEmpty &&
                                                  !user.displayName.toLowerCase().contains(_searchQuery) &&
                                                  !(user.username?.toLowerCase().contains(_searchQuery) ?? false)) {
                                                return const SizedBox.shrink();
                                              }
          
                                              final isSelected = _selectedUserIds.contains(otherUserId);
                                              final isSent = _sentUserIds.contains(otherUserId);
          
                                              return InkWell(
                                                onTap: () => _toggleSelection(otherUserId),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                                  child: Row(
                                                    children: [
                                                      AppAvatar(imageUrl: user.profilePicture, radius: 24),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              user.displayName,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: theme.textTheme.titleMedium?.copyWith(
                                                                fontWeight: FontWeight.w600,
                                                                color: isSent ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                                                              ),
                                                            ),
                                                            if (user.username != null) ...[
                                                              const SizedBox(height: 2),
                                                              Text(
                                                                '@${user.username}',
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: theme.textTheme.bodySmall?.copyWith(
                                                                  color: theme.colorScheme.onSurfaceVariant,
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      
                                                      // Selection Indicator
                                                      if (isSent)
                                                        Container(
                                                          padding: const EdgeInsets.all(4),
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: theme.colorScheme.surfaceContainerHighest,
                                                          ),
                                                          child: Icon(Icons.send_rounded, size: 16, color: theme.colorScheme.onSurface),
                                                        )
                                                      else
                                                        Container(
                                                          width: 24,
                                                          height: 24,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.5),
                                                              width: isSelected ? 0 : 1.5,
                                                            ),
                                                            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                                          ),
                                                          child: isSelected
                                                              ? Icon(Icons.check, size: 16, color: theme.colorScheme.onPrimary)
                                                              : null,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: AppLoader.small())),
                                            error: (_, __) => const SizedBox.shrink(),
                                          );
                                        },
                                        childCount: validRooms.length,
                                      ),
                                    );"""

new_grid = """                                    return SliverPadding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      sliver: SliverGrid(
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          mainAxisSpacing: 24,
                                          crossAxisSpacing: 12,
                                          childAspectRatio: 0.7, 
                                        ),
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            final room = validRooms[index];
                                            final otherUserId = room.participants.firstWhere(
                                              (id) => id != currentUser.userId,
                                              orElse: () => '',
                                            );
                                            if (otherUserId.isEmpty) return const SizedBox.shrink();
            
                                            final otherUserAsync = ref.watch(userByIdProvider(otherUserId));
            
                                            return otherUserAsync.when(
                                              data: (user) {
                                                if (user == null) return const SizedBox.shrink();
            
                                                if (_searchQuery.isNotEmpty &&
                                                    !user.displayName.toLowerCase().contains(_searchQuery) &&
                                                    !(user.username?.toLowerCase().contains(_searchQuery) ?? false)) {
                                                  return const SizedBox.shrink();
                                                }
            
                                                final isSelected = _selectedUserIds.contains(otherUserId);
                                                final isSent = _sentUserIds.contains(otherUserId);
            
                                                return GestureDetector(
                                                  onTap: () => _toggleSelection(otherUserId),
                                                  behavior: HitTestBehavior.opaque,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Stack(
                                                        alignment: Alignment.bottomRight,
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2.5) : null,
                                                            ),
                                                            padding: EdgeInsets.all(isSelected ? 3 : 0),
                                                            child: Opacity(
                                                              opacity: isSent ? 0.4 : 1.0,
                                                              child: AppAvatar(imageUrl: user.profilePicture, radius: 28),
                                                            ),
                                                          ),
                                                          if (isSelected)
                                                            Container(
                                                              margin: const EdgeInsets.only(bottom: 2, right: 2),
                                                              decoration: BoxDecoration(
                                                                color: theme.colorScheme.primary,
                                                                shape: BoxShape.circle,
                                                                border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                                                              ),
                                                              padding: const EdgeInsets.all(3),
                                                              child: Icon(Icons.check, size: 14, color: theme.colorScheme.onPrimary),
                                                            ),
                                                          if (isSent)
                                                            Container(
                                                              margin: const EdgeInsets.only(bottom: 2, right: 2),
                                                              decoration: BoxDecoration(
                                                                color: theme.colorScheme.surfaceContainerHighest,
                                                                shape: BoxShape.circle,
                                                                border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                                                              ),
                                                              padding: const EdgeInsets.all(3),
                                                              child: Icon(Icons.send_rounded, size: 12, color: theme.colorScheme.onSurface),
                                                            ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        user.displayName.split(' ').first,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        textAlign: TextAlign.center,
                                                        style: theme.textTheme.titleSmall?.copyWith(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: isSent ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: AppLoader.small())),
                                              error: (_, __) => const SizedBox.shrink(),
                                            );
                                          },
                                          childCount: validRooms.length,
                                        ),
                                      ),
                                    );"""

content = content.replace(old_list, new_grid)

with open('lib/shared/widgets/direct_share_sheet.dart', 'w') as f:
    f.write(content)
