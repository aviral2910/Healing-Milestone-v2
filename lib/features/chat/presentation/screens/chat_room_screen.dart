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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickAndSendImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    
    final user = ref.read(currentUserProvider);
    if (user == null || user.userId == null) return;

    setState(() => _isSending = true);
    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            roomId: widget.roomId,
            senderId: user.userId!,
            imageFile: File(pickedFile.path),
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
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
      await ref.read(chatRepositoryProvider).sendMessage(
            roomId: widget.roomId,
            senderId: user.userId!,
            text: text,
          );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
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
            if (widget.roomType == 'support') {
              return Row(
                children: [
                  const CircleAvatar(radius: 18, backgroundColor: Colors.blue, child: Icon(Icons.support_agent, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  const Text('Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              );
            }

            String? otherUserId;
            if (widget.roomId.startsWith('chat_') && currentUser != null) {
              final parts = widget.roomId.split('_');
              if (parts.length == 3) {
                if (parts[1] == currentUser.userId) otherUserId = parts[2];
                else if (parts[2] == currentUser.userId) otherUserId = parts[1];
              }
            }

            if (otherUserId == null) return const Text('Chat');

            final otherUserAsync = ref.watch(userByIdProvider(otherUserId));
            return otherUserAsync.when(
              data: (user) {
                if (user == null) return const Text('User');
                return Row(
                  children: [
                    AppAvatar(imageUrl: user.profilePicture, radius: 18),
                    const SizedBox(width: 12),
                    Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                );
              },
              loading: () => const Text('Loading...'),
              error: (_, __) => const Text('Chat'),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                // Trigger batch fetch
                final journeyIds = messages.map((m) => m.sharedJourneyId).whereType<String>().toSet().toList();
                final storyIds = messages.map((m) => m.sharedStoryId).whereType<String>().toSet().toList();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (journeyIds.isNotEmpty) ref.read(batchMediaProvider.notifier).loadJourneys(journeyIds);
                  if (storyIds.isNotEmpty) ref.read(batchMediaProvider.notifier).loadStories(storyIds);
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
                    return _MessageBubble(msg: msg, isMe: isMe);
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
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined),
              onPressed: _isSending ? null : _pickAndSendImage,
            ),
            // TODO: Add attachment icon for Journeys/Stories
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendTextMessage(),
              ),
            ),
            const SizedBox(width: 8),
            if (_isSending)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              IconButton(
                icon: const Icon(Icons.send_rounded),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _sendTextMessage,
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

  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
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
            if (msg.text != null && msg.text!.isNotEmpty)
              Text(
                msg.text!,
                style: TextStyle(
                  color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
            const SizedBox(height: 4),
            if (msg.createdAt != null)
              Text(
                timeago.format(msg.createdAt!),
                style: TextStyle(
                  fontSize: 10,
                  color: isMe ? theme.colorScheme.onPrimary.withValues(alpha: 0.7) : theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
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
    final bgColor = isMe ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05);

    String? imageUrl;
    String? title;

    if (isJourney) {
      final journey = mediaState.journeys[id];
      if (journey == null) {
        return const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
      }
      imageUrl = null;
      title = journey.title;
    } else {
      final story = mediaState.stories[id];
      if (story == null) {
        return const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
      }
      imageUrl = story.mainImage;
      title = story.heading;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isJourney ? Icons.map_rounded : Icons.menu_book_rounded, size: 14, color: fgColor.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text(isJourney ? 'Shared Journey' : 'Shared Story', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fgColor.withValues(alpha: 0.8))),
            ],
          ),
          const SizedBox(height: 8),
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover)),
          const SizedBox(height: 8),
          Text(title ?? 'Untitled', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: fgColor), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
