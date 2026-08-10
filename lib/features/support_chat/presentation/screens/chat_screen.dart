import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/support_chat/data/models/chat_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

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
    final user = ref.watch(currentUserProvider);
    final chatIdAsync = ref.watch(supportChatIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Chat'),
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

          return Column(
            children: [
              Expanded(
                child: _buildMessagesList(chatId, user.userId),
              ),
              _buildTypingIndicator(chatId),
              _buildMessageInput(chatId, user.userId),
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
          return const Center(
              child: Text('No messages yet. Send one to start.'));
        }
        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[index];
            final isMe = msg.senderId == currentUserId;

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight: isMe
                        ? const Radius.circular(0)
                        : const Radius.circular(16),
                    bottomLeft: isMe
                        ? const Radius.circular(16)
                        : const Radius.circular(0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (msg.messageType == 'image' && msg.fileUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          msg.fileUrl!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (msg.text.isNotEmpty) const SizedBox(height: 8),
                    ],
                    if (msg.text.isNotEmpty)
                      Text(
                        msg.text,
                        style: TextStyle(
                          color: isMe
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildTypingIndicator(String chatId) {
    final chatAsync = ref.watch(supportChatStreamProvider(chatId));

    return chatAsync.when(
      data: (chat) {
        if (chat != null && chat.typingStatus['admin'] == true) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              'Support is typing...',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildMessageInput(String chatId, String userId) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onChanged: (text) => _onTextChanged(text, chatId, userId),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
                if (_isSending)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => _sendMessage(chatId, userId),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
