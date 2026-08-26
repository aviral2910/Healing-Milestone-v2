with open('lib/shared/widgets/direct_share_sheet.dart', 'r') as f:
    content = f.read()

import os

new_content = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/chat/presentation/providers/chat_providers.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

class DirectShareSheet extends ConsumerStatefulWidget {
  final String? journeyId;
  final String? storyId;

  const DirectShareSheet({super.key, this.journeyId, this.storyId});

  @override
  ConsumerState<DirectShareSheet> createState() => _DirectShareSheetState();
}

class _DirectShareSheetState extends ConsumerState<DirectShareSheet> {
  String _searchQuery = '';
  final Set<String> _sentRoomIds = {};
  bool _isSending = false;

  void _shareToRoom(String roomId) async {
    if (_sentRoomIds.contains(roomId)) return;

    setState(() {
      _isSending = true;
    });

    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.sendMessage(
        roomId: roomId,
        text: widget.journeyId != null ? "Check out this Journey!" : "Check out this Story!",
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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text("Share", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
            
            // Vertical List of Users
            Expanded(
              child: currentUser == null
                  ? const Center(child: Text("Please log in to share to DMs"))
                  : activeChatsAsync.when(
                      data: (rooms) {
                        final validRooms = rooms.where((r) => r.participants.contains(currentUser.userId) && r.participants.length > 1 && r.type != "support").toList();

                        if (validRooms.isEmpty) {
                          return Center(
                            child: Text(
                              "No recent chats yet.\\nStart a chat from someone's profile!",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

                                // Basic client-side filter
                                if (_searchQuery.isNotEmpty &&
                                    !user.displayName.toLowerCase().contains(_searchQuery) &&
                                    !user.username.toLowerCase().contains(_searchQuery)) {
                                  return const SizedBox.shrink();
                                }

                                final isSent = _sentRoomIds.contains(room.id);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    children: [
                                      AppAvatar(imageUrl: user.profilePicture, radius: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                            Text('@${user.username}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: isSent ? null : () => _shareToRoom(room.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isSent ? Theme.of(context).colorScheme.surfaceContainerHighest : Colors.blue,
                                          foregroundColor: isSent ? Theme.of(context).colorScheme.onSurfaceVariant : Colors.white,
                                          elevation: 0,
                                          minimumSize: const Size(80, 32),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text(isSent ? 'Sent' : 'Send', style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loading: () => const Padding(
                                padding: EdgeInsets.only(bottom: 12.0),
                                child: ListTile(leading: AppLoader.small(), title: Text('Loading...')),
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
          ],
        ),
      ),
    );
  }
}
"""

with open('lib/shared/widgets/direct_share_sheet.dart', 'w') as f:
    f.write(new_content)
