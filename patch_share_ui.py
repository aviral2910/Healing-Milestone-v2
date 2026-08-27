import re

with open('lib/shared/widgets/direct_share_sheet.dart', 'r') as f:
    content = f.read()

# Add _selectedUserIds back to state
content = content.replace(
    "final Set<String> _sentUserIds = {};",
    "final Set<String> _selectedUserIds = {};\n  final Set<String> _sentUserIds = {};"
)

# Modify _sendToUser to _sendToSelected
old_send_logic = """  void _sendToUser(String targetUserId, List<dynamic> rooms) async {
    if (_sentUserIds.contains(targetUserId) || _sendingUserIds.contains(targetUserId)) return;

    setState(() {
      _sendingUserIds.add(targetUserId);
    });

    try {
      final repo = ref.read(chatRepositoryProvider);
      final currentUid = FirebaseAuth.instance.currentUser!.uid;

      // Find existing room or request one
      String? roomId;
      try {
        final existingRoom = rooms.firstWhere(
          (r) => r.participants.contains(targetUserId) && r.participants.contains(currentUid),
        );
        roomId = existingRoom.id;
      } catch (_) {
        roomId = await repo.requestChat(targetUserId, isMutual: false);
      }

      if (roomId != null) {
        await repo.sendMessage(
          roomId: roomId,
          senderId: currentUid,
          text: widget.journeyId != null
              ? "Check out this Journey!"
              : widget.storyId != null ? "Check out this Story!" : "Check out this profile!",
          sharedJourneyId: widget.journeyId,
          sharedStoryId: widget.storyId,
        );
      }

      if (mounted) {
        setState(() {
          _sentUserIds.add(targetUserId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sendingUserIds.remove(targetUserId);
        });
      }
    }
  }"""

new_send_logic = """  bool _isSending = false;

  void _sendToSelected(List<dynamic> rooms) async {
    if (_selectedUserIds.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final repo = ref.read(chatRepositoryProvider);
      final currentUid = FirebaseAuth.instance.currentUser!.uid;

      for (final targetUserId in _selectedUserIds) {
        String? roomId;
        try {
          final existingRoom = rooms.firstWhere(
            (r) => r.participants.contains(targetUserId) && r.participants.contains(currentUid),
          );
          roomId = existingRoom.id;
        } catch (_) {
          roomId = await repo.requestChat(targetUserId, isMutual: false);
        }

        if (roomId != null) {
          await repo.sendMessage(
            roomId: roomId,
            senderId: currentUid,
            text: widget.journeyId != null
                ? "Check out this Journey!"
                : widget.storyId != null ? "Check out this Story!" : "Check out this profile!",
            sharedJourneyId: widget.journeyId,
            sharedStoryId: widget.storyId,
          );
        }
      }

      if (mounted) {
        setState(() {
          _sentUserIds.addAll(_selectedUserIds);
          _selectedUserIds.clear();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sent successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _toggleSelection(String userId) {
    if (_sentUserIds.contains(userId)) return;
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }"""

content = content.replace(old_send_logic, new_send_logic)

# Replace the row UI to handle selection instead of inline send
old_row = """                                              final isSent = _sentUserIds.contains(otherUserId);
                                              final isSending = _sendingUserIds.contains(otherUserId);
      
                                              return Padding(
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
                                                    
                                                    // Inline Send Button
                                                    GestureDetector(
                                                      onTap: isSent || isSending ? null : () => _sendToUser(otherUserId, rooms),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                        decoration: BoxDecoration(
                                                          color: isSent 
                                                              ? theme.colorScheme.surface
                                                              : theme.colorScheme.primary,
                                                          border: isSent ? Border.all(color: theme.dividerColor.withValues(alpha: 0.3)) : null,
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        child: isSending
                                                            ? SizedBox(
                                                                width: 16, height: 16,
                                                                child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                                                              )
                                                            : Text(
                                                                isSent ? 'Sent' : 'Send',
                                                                style: theme.textTheme.titleSmall?.copyWith(
                                                                  color: isSent ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );"""

new_row = """                                              final isSelected = _selectedUserIds.contains(otherUserId);
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
                                              );"""

content = content.replace(old_row, new_row)

# Add Big Send Button above classic share options
old_classic_share = """              // Classic Share Options (Bottom Bar)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container("""

new_classic_share = """              // Classic Share Options (Bottom Bar)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedUserIds.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          child: activeChatsAsync.whenOrNull(
                            data: (rooms) => ElevatedButton(
                              onPressed: _isSending ? null : () => _sendToSelected(rooms),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              ),
                              child: _isSending
                                  ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                                  : Text('Send to ${_selectedUserIds.length}', style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )),
                            ),
                          ),
                        ),
                        Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
                        const SizedBox(height: 16),
                      ],
                      Row("""

content = content.replace(old_classic_share, new_classic_share)

# Fix row closing tags
old_row_close = """                        },
                      ),
                    ],
                  ),
                ),
              ),"""

new_row_close = """                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),"""

content = content.replace(old_row_close, new_row_close)


with open('lib/shared/widgets/direct_share_sheet.dart', 'w') as f:
    f.write(content)
