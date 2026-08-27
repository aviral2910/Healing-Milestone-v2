import 'package:healing_milestones/shared/widgets/app_loader.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import 'dart:io';
import 'package:healing_milestones/features/journey/presentation/screens/journey_detail_screen.dart';
import 'package:healing_milestones/features/milestone/presentation/screens/story_detail_screen.dart';
import 'package:healing_milestones/features/profile/presentation/screens/public_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      imageQuality: 70, // Compress image natively
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (pickedFile == null) return;

    // Ask user if they want to send as View Once
    bool? isViewOnce = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Send Image", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.send_rounded, size: 28),
                title: const Text("Send Normally"),
                subtitle: const Text("Image stays in the chat permanently"),
                onTap: () => Navigator.pop(ctx, false),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timer_rounded, size: 28, color: Colors.blue),
                title: const Text("Send as View Once", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                subtitle: const Text("Image disappears after they view it"),
                onTap: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );

    if (isViewOnce == null) return; // User cancelled

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
            isViewOnce: isViewOnce,
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

  Widget _buildViewOnceImage(BuildContext context, WidgetRef ref, ChatMessage msg, bool isMe) {
    if (msg.isViewed) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_red_eye_outlined, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text('Opened', style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
          ],
        ),
      );
    }

    if (isMe) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.timer_rounded, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text('Photo Sent', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        // View the photo
        await Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 4)]),
          ),
          body: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            clipBehavior: Clip.none,
            child: Center(
              child: CachedNetworkImage(imageUrl: msg.imageUrl!),
            ),
          ),
        )));
        
        // Once popped, mark as viewed!
        ref.read(chatRepositoryProvider).markMessageAsViewed(roomId, msg.id);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.timer_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Tap to View Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox(BuildContext context, double width, double height, {double radius = 8}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white12 : Colors.black12,
      highlightColor: isDark ? Colors.white24 : Colors.black26,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

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
    final isDark = theme.brightness == Brightness.dark;
    
    // Sleek monochrome palette
    final sentColor = isDark 
        ? Colors.white.withValues(alpha: 0.2) 
        : const Color(0xFF1C1C1E); 
        
    final receivedColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF1F1F1);

    final sentTextColor = Colors.white;
    final receivedTextColor = isDark ? Colors.white : Colors.black87;

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
            color: isMe ? sentColor : receivedColor,
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
                  child: msg.isViewOnce
                      ? _buildViewOnceImage(context, ref, msg, isMe)
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                              backgroundColor: Colors.black,
                              extendBodyBehindAppBar: true,
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 4)]),
                              ),
                              body: InteractiveViewer(
                                minScale: 1.0,
                                maxScale: 4.0,
                                clipBehavior: Clip.none,
                                child: Center(
                                  child: CachedNetworkImage(imageUrl: msg.imageUrl!),
                                ),
                              ),
                            )));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: msg.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _buildShimmerBox(context, double.infinity, 200),
                              errorWidget: (context, url, error) => const SizedBox(
                                height: 100,
                                child: Center(child: Icon(Icons.error_outline)),
                              ),
                            ),
                          ),
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
                    color: isMe ? sentTextColor : receivedTextColor,
                  ),
                ),
              const SizedBox(height: 4),
              if (msg.createdAt != null)
                Text(
                  timeago.format(msg.createdAt!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isMe 
                        ? sentTextColor.withValues(alpha: 0.6) 
                        : receivedTextColor.withValues(alpha: 0.6),
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
    final theme = Theme.of(context);
    final mediaState = ref.watch(batchMediaProvider);
    final fgColor = isMe ? Colors.white : theme.colorScheme.onSurface;
    final bgColor = isMe
        ? Colors.white.withValues(alpha: 0.2)
        : theme.colorScheme.onSurface.withValues(alpha: 0.08);

    String? imageUrl;
    String? title;

    if (isJourney) {
      if (!mediaState.journeys.containsKey(id)) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildShimmerBox(context, double.infinity, 80, radius: 12),
        );
      }
      final journey = mediaState.journeys[id];
      if (journey == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Journey unavailable', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
        );
      }
      imageUrl = null;
      title = journey.title;
    } else {
      if (!mediaState.stories.containsKey(id)) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildShimmerBox(context, double.infinity, 160, radius: 12),
        );
      }
      final story = mediaState.stories[id];
      if (story == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Post unavailable', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
        );
      }
      imageUrl = story.mainImage;
      title = story.heading;
    }

    return GestureDetector(
      onTap: () {
        if (isJourney) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => JourneyDetailScreen(journeyId: id, title: title ?? 'Shared Journey')));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailScreen(milestoneId: id)));
        }
      },
      child: Container(
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
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildShimmerBox(context, double.infinity, 120),
                errorWidget: (context, url, error) => const SizedBox(
                  height: 120,
                  child: Center(child: Icon(Icons.error_outline)),
                ),
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
    ));
  }

  Widget _buildSharedProfileCard({
    required BuildContext context,
    required WidgetRef ref,
    required String profileId,
    required bool isMe,
  }) {
    final theme = Theme.of(context);
    final fgColor = isMe ? Colors.white : theme.colorScheme.onSurface;
    final bgColor = isMe
        ? Colors.white.withValues(alpha: 0.2)
        : theme.colorScheme.onSurface.withValues(alpha: 0.08);

    final userAsync = ref.watch(userByIdProvider(profileId));

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: profileId)));
      },
      child: Container(
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
        loading: () => _buildShimmerBox(context, double.infinity, 60, radius: 12),
        error: (_, __) => const Text('Error loading profile'),
      ),
    ));
  }
}
