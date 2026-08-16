import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/support_chat/data/models/chat_model.dart';
import 'package:healing_milestones/logo/healing_milestone_logo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../auth/data/auth_provider.dart';
import '../../data/chat_repository.dart';
import '../../data/models/message_model.dart';
import '../providers/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  Timer? _typingTimer;
  bool _isTyping = false;
  bool _isSending = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String text, String chatId, String userId) {
    if (text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
      ref.read(chatRepositoryProvider).updateTypingStatus(chatId, userId, true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        setState(() => _isTyping = false);
        ref
            .read(chatRepositoryProvider)
            .updateTypingStatus(chatId, userId, false);
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _sendMessage(String chatId, String userId) async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    setState(() => _isSending = true);

    try {
      final repo = ref.read(chatRepositoryProvider);
      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await repo.uploadImage(chatId, _selectedImage!);
      }

      final message = MessageModel(
        id: const Uuid().v4(),
        text: text,
        senderId: userId,
        timestamp: DateTime.now(),
        messageType: _selectedImage != null ? 'image' : 'text',
        fileUrl: imageUrl,
      );

      await repo.sendMessage(chatId, message, recipientId: 'admin');

      _textController.clear();
      setState(() {
        _selectedImage = null;
        _isSending = false;
        _isTyping = false;
      });
      repo.updateTypingStatus(chatId, userId, false);
    } catch (e) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final chatIdAsync = ref.watch(supportChatIdProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withValues(alpha: 0.5),
            height: 1.0,
          ),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.headset_mic_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent[400],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Support Team',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Typically replies in a few hours',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFA1A1A6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: chatIdAsync.when(
        data: (chatId) {
          if (user == null) return const Center(child: Text('Not logged in'));

          // Clear unread count when chat is opened and stream updates
          ref.listen<AsyncValue<ChatModel?>>(supportChatStreamProvider(chatId),
              (previous, next) {
            final chat = next.value;
            if (chat != null && (chat.unreadCount[user.userId] ?? 0) > 0) {
              ref
                  .read(chatRepositoryProvider)
                  .clearUnreadCount(chatId, user.userId);
            }
          });

          return Stack(
            children: [
              // Background Watermark
              Positioned.fill(
                child: Center(
                  child: Opacity(
                    opacity: 0.05,
                    child: IgnorePointer(
                      child: HealingMilestonesStaticLogoWidget(
                        logoSize: 250,
                        logoColor: theme.colorScheme.onSurface,
                        showText: false,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: _buildMessagesList(chatId, user.userId),
                  ),
                  _buildTypingIndicator(chatId),
                  _buildMessageInput(chatId, user.userId, theme),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading chat: $e')),
      ),
    );
  }

  Widget _buildMessagesList(String chatId, String currentUserId) {
    final messagesAsync = ref.watch(supportChatMessagesProvider(chatId));

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mark_chat_read_outlined,
                  size: 64,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Send a message to start the conversation.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFA1A1A6),
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg.senderId == currentUserId;

            // Optional: Group messages to show time breaks
            bool showTime = false;
            if (index == messages.length - 1) {
              showTime = true;
            } else {
              final previousMsg = messages[index + 1];
              if (msg.timestamp.difference(previousMsg.timestamp).inMinutes > 30) {
                showTime = true;
              }
            }

            return Column(
              children: [
                if (showTime)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      _formatDateDivider(msg.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFA1A1A6),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                        bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.messageType == 'image' && msg.fileUrl != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(imageUrl: msg.fileUrl!, memCacheWidth: 800, fit: BoxFit.cover,),
                          ),
                          if (msg.text.isNotEmpty) const SizedBox(height: 8),
                        ],
                        if (msg.text.isNotEmpty)
                          Text(
                            msg.text,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.3,
                              color: isMe
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  String _formatDateDivider(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0 && now.day == date.day) {
      return DateFormat.jm().format(date);
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != date.day)) {
      return 'Yesterday, ${DateFormat.jm().format(date)}';
    } else if (difference.inDays < 7) {
      return '${DateFormat.E().format(date)}, ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat('MMM d, yyyy h:mm a').format(date);
    }
  }

  Widget _buildTypingIndicator(String chatId) {
    final chatAsync = ref.watch(supportChatStreamProvider(chatId));

    return chatAsync.when(
      data: (chat) {
        if (chat != null && chat.typingStatus['admin'] == true) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.headset_mic_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Typing...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: const Color(0xFFA1A1A6),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildMessageInput(String chatId, String userId, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.add_photo_alternate_outlined, color: const Color(0xFFA1A1A6)),
                    onPressed: _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: (text) {
                        // Just to trigger UI updates for the send button color
                        setState(() {});
                        _onTextChanged(text, chatId, userId);
                      },
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Message Support...',
                        hintStyle: TextStyle(color: const Color(0xFFA1A1A6)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                      ),
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: _isSending
                        ? Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : GestureDetector(
                            onTap: (_textController.text.trim().isNotEmpty || _selectedImage != null)
                                ? () => _sendMessage(chatId, userId)
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (_textController.text.trim().isNotEmpty || _selectedImage != null)
                                    ? theme.colorScheme.primary
                                    : theme.dividerColor.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: (_textController.text.trim().isNotEmpty || _selectedImage != null)
                                      ? theme.colorScheme.onPrimary
                                      : const Color(0xFFA1A1A6),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
