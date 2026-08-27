import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# 1. Add _hasText and initState
state_vars_old = """  final _textController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _isSending = false;

  @override
  void dispose() {"""

state_vars_new = """  final _textController = TextEditingController();
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
  void dispose() {"""
content = content.replace(state_vars_old, state_vars_new)

# 2. Update AppBar actions
appbar_actions_old = """        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {}, // Future profile view
          ),
        ],"""
appbar_actions_new = """        actions: [
          IconButton(
            icon: const Icon(Icons.local_phone_outlined),
            onPressed: () {}, 
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {}, 
          ),
        ],"""
content = content.replace(appbar_actions_old, appbar_actions_new)

# 3. Update _buildInputArea
input_area_pattern = re.compile(r"  Widget _buildInputArea\(BuildContext context\) \{.*?    \);\n  \}", re.DOTALL)
input_area_new = """  Widget _buildInputArea(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        color: theme.scaffoldBackgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt, color: theme.colorScheme.onPrimary, size: 22),
                  onPressed: () {}, // Future camera integration
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
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
  }"""
content = input_area_pattern.sub(input_area_new, content)

# 4. Update _MessageBubble Unsend Dialog and Radius
unsend_old = """      onLongPress: isMe
          ? () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Unsend Message?'),
                  content: const Text(
                    'This will permanently delete the message for everyone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref
                            .read(chatRepositoryProvider)
                            .deleteMessage(roomId, msg.id);
                      },
                      child: const Text(
                        'Unsend',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            }
          : null,"""

unsend_new = """      onLongPress: isMe
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
          : null,"""
content = content.replace(unsend_old, unsend_new)

bubble_radius_old = """            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(16),
              bottomLeft: isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(4),
            ),"""

bubble_radius_new = """            borderRadius: BorderRadius.circular(22).copyWith(
              bottomRight: isMe
                  ? const Radius.circular(6)
                  : const Radius.circular(22),
              bottomLeft: isMe
                  ? const Radius.circular(22)
                  : const Radius.circular(6),
            ),"""
content = content.replace(bubble_radius_old, bubble_radius_new)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
