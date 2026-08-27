import 'dart:ui';
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
        String? roomId;
        try {
          final existingRoom = rooms.firstWhere(
            (r) =>
                r.participants.contains(targetUserId) &&
                r.participants.contains(currentUid),
          );
          roomId = existingRoom.id;
        } catch (_) {
          roomId = await repo.requestChat(targetUserId, isMutual: false);
        }

        if (roomId != null) {
          await repo.sendMessage(
            roomId: roomId,
            senderId: currentUid,
            text: null,
            sharedJourneyId: widget.journeyId,
            sharedStoryId: widget.storyId,
            sharedProfileId: widget.profileId,
          );
        }
      }

      if (mounted) {
        setState(() {
          _sentUserIds.addAll(_selectedUserIds);
          _selectedUserIds.clear();
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sent successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),

            border: Border(
              top: BorderSide(
                color: theme.primaryColor.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Drag handle
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 12.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header (Same as Journey Overlay)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: theme.colorScheme.surface,
                                          border: Border.all(
                                            color: theme.dividerColor
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            size: 24,
                                          ),
                                          style: IconButton.styleFrom(
                                            padding: const EdgeInsets.all(12),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary
                                                  .withValues(alpha: 0.15),
                                              theme.colorScheme.secondary
                                                  .withValues(alpha: 0.05),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.2),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          widget.journeyId != null
                                              ? 'Share Journey'
                                              : widget.storyId != null
                                              ? 'Share Story'
                                              : widget.profileId != null
                                              ? 'Share Profile'
                                              : 'Share',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Search Bar
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: theme.dividerColor.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: TextField(
                                      style: theme.textTheme.titleSmall,
                                      decoration: InputDecoration(
                                        hintText: 'Search people...',
                                        hintStyle: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                          size: 20,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _searchQuery = val.toLowerCase();
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),

                          // Users List
                          currentUser == null
                              ? SliverToBoxAdapter(
                                  child: Center(
                                    child: Text(
                                      "Please log in to share to DMs",
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                )
                              : activeChatsAsync.when(
                                  data: (rooms) {
                                    final validRooms = rooms
                                        .where(
                                          (r) =>
                                              r.participants.contains(
                                                currentUser.userId,
                                              ) &&
                                              r.participants.length > 1 &&
                                              r.type != "support",
                                        )
                                        .toList();

                                    if (validRooms.isEmpty) {
                                      return SliverToBoxAdapter(
                                        child: Center(
                                          child: Text(
                                            "No recent chats.",
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      );
                                    }

                                    return SliverPadding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      sliver: SliverGrid(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                              mainAxisSpacing: 24,
                                              crossAxisSpacing: 12,
                                              childAspectRatio: 0.7,
                                            ),
                                        delegate: SliverChildBuilderDelegate((
                                          context,
                                          index,
                                        ) {
                                          final room = validRooms[index];
                                          final otherUserId = room.participants
                                              .firstWhere(
                                                (id) =>
                                                    id != currentUser.userId,
                                                orElse: () => '',
                                              );
                                          if (otherUserId.isEmpty)
                                            return const SizedBox.shrink();

                                          final otherUserAsync = ref.watch(
                                            userByIdProvider(otherUserId),
                                          );

                                          return otherUserAsync.when(
                                            data: (user) {
                                              if (user == null)
                                                return const SizedBox.shrink();

                                              if (_searchQuery.isNotEmpty &&
                                                  !user.displayName
                                                      .toLowerCase()
                                                      .contains(_searchQuery) &&
                                                  !(user.username
                                                          ?.toLowerCase()
                                                          .contains(
                                                            _searchQuery,
                                                          ) ??
                                                      false)) {
                                                return const SizedBox.shrink();
                                              }

                                              final isSelected =
                                                  _selectedUserIds.contains(
                                                    otherUserId,
                                                  );
                                              final isSent = _sentUserIds
                                                  .contains(otherUserId);

                                              return GestureDetector(
                                                onTap: () => _toggleSelection(
                                                  otherUserId,
                                                ),
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Stack(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: isSelected
                                                                ? Border.all(
                                                                    color: theme
                                                                        .colorScheme
                                                                        .primary,
                                                                    width: 1,
                                                                  )
                                                                : null,
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                isSelected
                                                                    ? 3
                                                                    : 0,
                                                              ),
                                                          child: Opacity(
                                                            opacity: isSent
                                                                ? 0.4
                                                                : 1.0,
                                                            child: AppAvatar(
                                                              imageUrl: user
                                                                  .profilePicture,
                                                              radius: 28,
                                                            ),
                                                          ),
                                                        ),
                                                        if (isSelected)
                                                          Container(
                                                            margin:
                                                                const EdgeInsets.only(
                                                                  bottom: 2,
                                                                  right: 2,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: theme
                                                                  .colorScheme
                                                                  .primary,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                color: theme
                                                                    .scaffoldBackgroundColor,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  3,
                                                                ),
                                                            child: Icon(
                                                              Icons.check,
                                                              size: 14,
                                                              color: theme
                                                                  .colorScheme
                                                                  .onPrimary,
                                                            ),
                                                          ),
                                                        if (isSent)
                                                          Container(
                                                            margin:
                                                                const EdgeInsets.only(
                                                                  bottom: 2,
                                                                  right: 2,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: theme
                                                                  .colorScheme
                                                                  .surfaceContainerHighest,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                color: theme
                                                                    .scaffoldBackgroundColor,
                                                                width: 3,
                                                              ),
                                                            ),
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  3,
                                                                ),
                                                            child: Icon(
                                                              Icons
                                                                  .send_rounded,
                                                              size: 12,
                                                              color: theme
                                                                  .colorScheme
                                                                  .onSurface,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      user.displayName
                                                          .split(' ')
                                                          .first,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: theme
                                                          .textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: isSent
                                                                ? theme
                                                                      .colorScheme
                                                                      .onSurfaceVariant
                                                                : theme
                                                                      .colorScheme
                                                                      .onSurface,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            loading: () => const Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: AppLoader.small(),
                                              ),
                                            ),
                                            error: (_, __) =>
                                                const SizedBox.shrink(),
                                          );
                                        }, childCount: validRooms.length),
                                      ),
                                    );
                                  },
                                  loading: () => const SliverToBoxAdapter(
                                    child: Center(child: AppLoader()),
                                  ),
                                  error: (e, _) => const SliverToBoxAdapter(
                                    child: Center(
                                      child: Text("Error loading chats"),
                                    ),
                                  ),
                                ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: 220),
                          ), // Padding for bottom bar
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Classic Share Options (Bottom Bar)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: 24,
                    bottom: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom + 8
                        : 32,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedUserIds.isNotEmpty) ...[
                        activeChatsAsync.whenOrNull(
                              data: (rooms) => ElevatedButton(
                                onPressed: _isSending
                                    ? null
                                    : () => _sendToSelected(rooms),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56),
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: _isSending
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                    : Text(
                                        'Send to ${_selectedUserIds.length}',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onPrimary,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                            ),
                                      ),
                              ),
                            ) ??
                            const SizedBox.shrink(),
                        const SizedBox(height: 12),
                        Divider(
                          height: 1,
                          color: theme.dividerColor.withValues(alpha: 0.1),
                        ),
                        const SizedBox(height: 0),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildOptionBtn(
                            context: context,
                            icon: Icons.link_rounded,
                            label: 'Copy Link',
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: widget.shareUrl),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Link copied to clipboard'),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          ),
                          _buildOptionBtn(
                            context: context,
                            icon: Icons.ios_share,
                            label: 'Share via',
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
                            context: context,
                            icon: Icons.qr_code_2_rounded,
                            label: 'QR Code',
                            onTap: () {
                              Navigator.pop(context);
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: 'Dismiss',
                                barrierColor: Colors.black.withValues(
                                  alpha: 0.9,
                                ),
                                transitionDuration: const Duration(
                                  milliseconds: 300,
                                ),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
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
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    final surfaceLight =
        theme.cardTheme.color ?? theme.colorScheme.surfaceContainerHighest;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Icon(icon, size: 28, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
