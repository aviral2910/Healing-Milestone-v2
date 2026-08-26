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
  final Set<String> _sentRoomIds = {};
  bool _isSending = false;

  void _sendToRoom(String roomId, String targetUserId) async {
    if (_sentRoomIds.contains(roomId)) return;

    setState(() {
      _isSending = true;
    });

    try {
      final repo = ref.read(chatRepositoryProvider);
      
      // Ensure the chat room actually exists or is requested first
      await repo.requestChat(targetUserId, isMutual: false); // safe to call multiple times

      await repo.sendMessage(
        roomId: roomId,
        senderId: FirebaseAuth.instance.currentUser!.uid,
        text: widget.journeyId != null
            ? "Check out this Journey!"
            : widget.storyId != null ? "Check out this Story!" : "Check out this profile!",
        sharedJourneyId: widget.journeyId,
        sharedStoryId: widget.storyId,
      );

      if (mounted) {
        setState(() {
          _sentRoomIds.add(roomId);
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
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeChatsAsync = ref.watch(activeChatsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Share", style: theme.textTheme.headlineLarge?.copyWith(fontSize: 22)),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                ),
                child: TextField(
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search people...',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

            // Vertical Users List
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

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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

                                final isSent = _sentRoomIds.contains(room.id);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    children: [
                                      AppAvatar(imageUrl: user.profilePicture, radius: 24),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(user.displayName, style: theme.textTheme.titleMedium),
                                            Text('@${user.username}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: isSent ? null : () => _sendToRoom(room.id, otherUserId),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSent ? theme.colorScheme.surface : theme.colorScheme.primary,
                                          foregroundColor: isSent ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimary,
                                          elevation: 0,
                                          minimumSize: const Size(80, 36),
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            side: isSent ? BorderSide(color: theme.dividerColor) : BorderSide.none,
                                          ),
                                        ),
                                        child: Text(isSent ? 'Sent' : 'Send', style: theme.textTheme.titleMedium?.copyWith(
                                          color: isSent ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onPrimary,
                                        )),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loading: () => const Padding(
                                padding: EdgeInsets.only(bottom: 16.0),
                                child: Row(children: [AppLoader.small(), SizedBox(width: 16), Text('Loading...')]),
                              ),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: AppLoader()),
                      error: (e, _) => Center(child: Text("Error loading chats")),
                    ),
            ),

            Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),

            // Classic Share Options (Horizontal Row)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              color: theme.colorScheme.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionBtn(
                    context: context,
                    icon: Icons.link_rounded,
                    label: 'Copy Link',
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
                    icon: Icons.share_rounded,
                    label: 'Share via',
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor),
              ),
              child: Icon(icon, size: 28, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(label, style: theme.textTheme.titleMedium?.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
