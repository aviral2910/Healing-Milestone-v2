import 'package:healing_milestones/shared/widgets/app_loader.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/chat/presentation/providers/batch_media_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:healing_milestones/features/auth/data/auth_provider.dart';
import 'package:healing_milestones/features/chat/presentation/providers/chat_providers.dart';
import 'package:healing_milestones/features/chat/data/models/chat_models.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String roomType;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.roomType,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _textController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _isSending = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (_hasText != _textController.text.isNotEmpty) {
        setState(() {
          _hasText = _textController.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickAndSendImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null || user.userId == null) return;

    setState(() => _isSending = true);
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(
            roomId: widget.roomId,
            senderId: user.userId!,
            imageFile: File(pickedFile.path),
          );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendTextMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null || user.userId == null) return;

    _textController.clear();
    setState(() => _isSending = true);

    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(
            roomId: widget.roomId,
            senderId: user.userId!,
            text: text,
          );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.roomId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Builder(
          builder: (context) {
            final theme = Theme.of(context);

            if (widget.roomType == 'support') {
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      Icons.support_agent,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Healing Milestones Support',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              );
            }

            String? otherUserId;
            if (widget.roomId.startsWith('chat_') && currentUser != null) {
              final parts = widget.roomId.split('_');
              if (parts.length == 3) {
                if (parts[1] == currentUser.userId)
                  otherUserId = parts[2];
                else if (parts[2] == currentUser.userId)
                  otherUserId = parts[1];
              }
            }

            if (otherUserId == null)
              return Text('Chat', style: theme.textTheme.titleMedium);

            final otherUserAsync = ref.watch(userByIdProvider(otherUserId));
            return otherUserAsync.when(
              data: (user) {
                if (user == null)
                  return Text('User', style: theme.textTheme.titleMedium);
                return Row(
                  children: [
                    AppAvatar(imageUrl: user.profilePicture, radius: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user.displayName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
              loading: () =>
                  Text('Loading...', style: theme.textTheme.titleMedium),
              error: (_, __) =>
                  Text('Chat', style: theme.textTheme.titleMedium),
            );
          },
        ),
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                // Trigger batch fetch
                final journeyIds = messages
                    .map((m) => m.sharedJourneyId)
                    .whereType<String>()
                    .toSet()
                    .toList();
                final storyIds = messages
                    .map((m) => m.sharedStoryId)
                    .whereType<String>()
                    .toSet()
                    .toList();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (journeyIds.isNotEmpty)
                    ref
                        .read(batchMediaProvider.notifier)
                        .loadJourneys(journeyIds);
                  if (storyIds.isNotEmpty)
                    ref.read(batchMediaProvider.notifier).loadStories(storyIds);
                    
                  // Mark chat as read
                  if (currentUser?.userId != null) {
                    ref.read(chatRepositoryProvider).markAsRead(widget.roomId, currentUser!.userId!);
                  }
                });

                if (messages.isEmpty) {
                  return const Center(child: Text('Say hi!'));
                }
                return ListView.builder(
                  reverse: true, // Newest at bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser?.userId;
                    return _MessageBubble(
                      msg: msg,
                      isMe: isMe,
                      roomId: widget.roomId,
                    );
                  },
                );
              },
              loading: () => const Center(child: AppLoader()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        color: theme.scaffoldBackgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: theme.textTheme.bodyLarge,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Message...',
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    if (_isSending)
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else if (_hasText)
                      TextButton(
                        onPressed: _sendTextMessage,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          foregroundColor: theme.colorScheme.primary,
                        ),
                        child: const Text('Send', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      )
                    else ...[
                      IconButton(
                        icon: Icon(Icons.mic_none, color: theme.colorScheme.onSurfaceVariant),
                        onPressed: () {}, 
                      ),
                      IconButton(
                        icon: Icon(Icons.image_outlined, color: theme.colorScheme.onSurfaceVariant),
                        onPressed: _pickAndSendImage,
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  final ChatMessage msg;
  final bool isMe;
  final String roomId;

  const _MessageBubble({
    required this.msg,
    required this.isMe,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onLongPress: isMe
          ? () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (ctx) => Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Unsend message?',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'This message will be unsent for everyone in the chat.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
                      InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(chatRepositoryProvider).deleteMessage(roomId, msg.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Unsend',
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
                        onTap: () => Navigator.pop(ctx),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Cancel',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            }
          : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMe
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(22).copyWith(
              bottomRight: isMe
                  ? const Radius.circular(6)
                  : const Radius.circular(22),
              bottomLeft: isMe
                  ? const Radius.circular(22)
                  : const Radius.circular(6),
            ),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (msg.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(msg.imageUrl!, fit: BoxFit.cover),
                  ),
                ),
              if (msg.sharedJourneyId != null)
                _buildSharedCard(
                  context: context,
                  ref: ref,
                  id: msg.sharedJourneyId!,
                  isJourney: true,
                  isMe: isMe,
                ),
              if (msg.sharedStoryId != null)
                _buildSharedCard(
                  context: context,
                  ref: ref,
                  id: msg.sharedStoryId!,
                  isJourney: false,
                  isMe: isMe,
                ),
              if (msg.sharedProfileId != null)
                _buildSharedProfileCard(
                  context: context,
                  ref: ref,
                  profileId: msg.sharedProfileId!,
                  isMe: isMe,
                ),
              if (msg.text != null && msg.text!.isNotEmpty)
                Text(
                  msg.text!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isMe
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              const SizedBox(height: 4),
              if (msg.createdAt != null)
                Text(
                  timeago.format(msg.createdAt!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isMe
                        ? theme.colorScheme.onPrimary.withOpacity(0.7)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSharedCard({
    required BuildContext context,
    required WidgetRef ref,
    required String id,
    required bool isJourney,
    required bool isMe,
  }) {
    final mediaState = ref.watch(batchMediaProvider);
    final fgColor = isMe ? Colors.white : Colors.black87;
    final bgColor = isMe
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.05);

    String? imageUrl;
    String? title;

    if (isJourney) {
      final journey = mediaState.journeys[id];
      if (journey == null) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      imageUrl = null;
      title = journey.title;
    } else {
      final story = mediaState.stories[id];
      if (story == null) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      imageUrl = story.mainImage;
      title = story.heading;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isJourney ? Icons.map_rounded : Icons.menu_book_rounded,
                size: 14,
                color: fgColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                isJourney ? 'Shared Journey' : 'Shared Story',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: fgColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            title ?? 'Untitled',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: fgColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSharedProfileCard({
    required BuildContext context,
    required WidgetRef ref,
    required String profileId,
    required bool isMe,
  }) {
    final fgColor = isMe ? Colors.white : Colors.black87;
    final bgColor = isMe
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.05);

    final userAsync = ref.watch(userByIdProvider(profileId));

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: userAsync.when(
        data: (user) {
          if (user == null) return const Text('User not found');
          return Row(
            children: [
              AppAvatar(imageUrl: user.profilePicture, radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: fgColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.username != null)
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontSize: 12,
                          color: fgColor.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Text('Error loading profile'),
      ),
    );
  }
}
