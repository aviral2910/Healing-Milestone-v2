import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/chat/presentation/providers/chat_providers.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';
import 'package:healing_milestones/shared/widgets/qr_share_preview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:healing_milestones/core/theme/app_theme.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _sentRoomIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _sendToRoom(String roomId, String otherUserId) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() {
      _sentRoomIds.add(roomId);
    });

    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(
            roomId: roomId,
            senderId: currentUser.userId,
            text: "Check this out!", // Optional text
            sharedJourneyId: widget.journeyId,
            sharedStoryId: widget.storyId,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
        setState(() {
          _sentRoomIds.remove(roomId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final activeChatsAsync = ref.watch(activeChatsProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search people...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Active Chats List
            SizedBox(
              height: 120, // Height for horizontal list
              child: currentUser == null
                  ? const Center(child: Text("Please log in to share to DMs"))
                  : activeChatsAsync.when(
                      data: (rooms) {
                        if (rooms.isEmpty) {
                          return Center(
                            child: Text(
                              "No recent chats yet.\nStart a chat from someone's profile!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        // Filter out empty rooms or group rooms (assuming 1-on-1 for now)
                        final validRooms = rooms.where((r) => r.participants.contains(currentUser.userId) && r.participants.length > 1 && r.type != "support")
                            .toList();

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          itemCount: validRooms.length,
                          itemBuilder: (context, index) {
                            final room = validRooms[index];
                            final otherUserId = room.participants.firstWhere(
                              (id) => id != currentUser.userId,
                            );

                            // Watch other user's profile
                            final otherUserAsync = ref.watch(
                              userByIdProvider(otherUserId),
                            );

                            return Container(
                              width: 80,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: otherUserAsync.when(
                                data: (user) {
                                  // Apply search filter
                                  if (user == null)
                                    return const SizedBox.shrink();
                                  if (_searchQuery.isNotEmpty &&
                                      !user.displayName.toLowerCase().contains(
                                        _searchQuery,
                                      )) {
                                    return const SizedBox.shrink();
                                  }

                                  final isSent = _sentRoomIds.contains(room.id);

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AppAvatar(
                                        imageUrl: user.profilePicture,
                                        radius: 28,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        user.displayName.split(' ').first,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        height: 28,
                                        width: 64,
                                        child: isSent
                                            ? FilledButton(
                                                onPressed: null,
                                                style: FilledButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  backgroundColor: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                                child: const Text(
                                                  'Sent',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : OutlinedButton(
                                                onPressed: () => _sendToRoom(
                                                  room.id,
                                                  otherUserId,
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                ),
                                                child: const Text(
                                                  'Send',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ],
                                  );
                                },
                                loading: () =>
                                    const Center(child: AppLoader.small()),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: AppLoader()),
                      error: (e, st) => Center(child: Text('Error: $e')),
                    ),
            ),

            const Divider(height: 32),

            // Classic Share Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionBtn(
                  icon: Icons.copy,
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
                  icon: Icons.share_rounded,
                  label: 'Share via...',
                  onTap: () {
                    Navigator.pop(context);
                    // ignore: deprecated_member_use
                    Share.share(
                      widget.shareText,
                      subject: 'Healing Milestones',
                    );
                  },
                ),
                _buildOptionBtn(
                  icon: Icons.qr_code_2,
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
                          id:
                              widget.storyId ??
                              widget.journeyId ??
                              widget.profileId ??
                              'unknown',
                          shareUrl: widget.shareUrl,
                          shareText: widget.shareText,
                          qrBottomText: widget.qrBottomText,
                        );
                      },
                      transitionBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.05),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
