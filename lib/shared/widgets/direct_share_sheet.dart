import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/chat/presentation/providers/chat_providers.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';
import 'package:healing_milestones/shared/widgets/qr_share_preview.dart';
import 'package:share_plus/share_plus.dart';

class DirectShareSheet extends ConsumerStatefulWidget {
  final String? storyId;
  final String? journeyId;
  final String? profileId;
  final String shareUrl;
  final String shareText;
  final String qrBottomText;

  const DirectShareSheet({
    super.key,
    this.storyId,
    this.journeyId,
    this.profileId,
    required this.shareUrl,
    required this.shareText,
    required this.qrBottomText,
  });

  @override
  ConsumerState<DirectShareSheet> createState() => _DirectShareSheetState();
}

class _DirectShareSheetState extends ConsumerState<DirectShareSheet> {
  String _searchQuery = '';
  final Set<String> _selectedUserIds = {};
  final Set<String> _sentUserIds = {};
  bool _isSending = false;

  void _sendToSelected(List<dynamic> rooms) async {
    if (_selectedUserIds.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final repo = ref.read(chatRepositoryProvider);
      final currentUid = FirebaseAuth.instance.currentUser!.uid;

      for (final targetUserId in _selectedUserIds) {
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
  }

  @override
  Widget build(BuildContext context) {
    final activeChatsAsync = ref.watch(activeChatsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    // Get the surface color from the app theme (usually #0F0F0F)
    final surfaceColor = theme.colorScheme.surface;
    // Lighter surface for search bar and buttons (usually #1E1E1E)
    final surfaceLight = theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header
            Text(
              "Send to",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Multi-select Users Grid
            Expanded(
              child: currentUser == null
                  ? Center(child: Text("Please log in to share to DMs", style: theme.textTheme.bodyLarge))
                  : activeChatsAsync.when(
                      data: (rooms) {
                        final validRooms = rooms.where((r) => 
                            r.participants.contains(currentUser.userId) && 
                            r.participants.length > 1 && 
                            r.type != "support").toList();

                        if (validRooms.isEmpty) {
                          return Center(
                            child: Text(
                              "No recent chats yet.\nStart a conversation from a profile!",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.75, 
                          ),
                          itemCount: validRooms.length,
                          itemBuilder: (context, index) {
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
                                                border: Border.all(color: surfaceColor, width: 3),
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
                                                border: Border.all(color: surfaceColor, width: 3),
                                              ),
                                              padding: const EdgeInsets.all(3),
                                              child: Icon(Icons.send_rounded, size: 12, color: theme.colorScheme.onSurface),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        user.displayName.split(' ').first,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontSize: 11,
                                          color: isSent ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loading: () => const Center(child: AppLoader.small()),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: AppLoader()),
                      error: (e, _) => Center(child: Text("Error loading chats")),
                    ),
            ),

            // Big Send Button (only visible when items selected)
            if (_selectedUserIds.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: activeChatsAsync.whenOrNull(
                  data: (rooms) => ElevatedButton(
                    onPressed: _isSending ? null : () => _sendToSelected(rooms),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _isSending
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                        : Text('Send', style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          )),
                  ),
                ),
              ),
            ],

            Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),

            // Classic Share Options (Horizontal Row)
            Container(
              padding: const EdgeInsets.only(top: 24, bottom: 32, left: 16, right: 16),
              color: surfaceColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionBtn(
                    context: context,
                    icon: Icons.link_rounded,
                    label: 'Copy link',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.shareUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard')),
                      );
                      Navigator.pop(context);
                    },
                  ),
                  _buildOptionBtn(
                    context: context,
                    icon: Icons.ios_share_rounded,
                    label: 'Share to...',
                    onTap: () {
                      Navigator.pop(context);
                      // ignore: deprecated_member_use
                      Share.share(widget.shareText, subject: 'Healing Milestones');
                    },
                  ),
                  _buildOptionBtn(
                    context: context,
                    icon: Icons.qr_code_2_rounded,
                    label: 'QR Code',
                    onTap: () {
                      Navigator.pop(context);
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: 'Dismiss',
                        barrierColor: Colors.black87,
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return QrSharePreview(
                            id: widget.storyId ?? widget.journeyId ?? widget.profileId ?? 'unknown',
                            shareUrl: widget.shareUrl,
                            shareText: widget.shareText,
                            qrBottomText: widget.qrBottomText,
                          );
                        },
                        transitionBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
                              child: child,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionBtn({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final surfaceLight = theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              label, 
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 11, 
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
