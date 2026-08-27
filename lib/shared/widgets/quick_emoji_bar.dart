import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickEmojiBar extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback? onEmojiTapped;
  final bool alwaysVisible;

  const QuickEmojiBar({
    Key? key,
    required this.textController,
    required this.focusNode,
    this.onEmojiTapped,
    this.alwaysVisible = false,
  }) : super(key: key);

  static const List<String> _quickEmojis = [
    '❤️', '🫂', '🙌', '✨', '🌻', '🔥', '👏', '💯', '💪', '🙏'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: (alwaysVisible || focusNode.hasFocus)
          ? Container(
              width: double.infinity,
              color: Colors.transparent,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: _quickEmojis.map((emoji) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final currentText = textController.text;
                          final selection = textController.selection;
                          if (selection.isValid && selection.start >= 0) {
                            final newText = currentText.replaceRange(
                              selection.start,
                              selection.end,
                              emoji,
                            );
                            textController.value = TextEditingValue(
                              text: newText,
                              selection: TextSelection.collapsed(
                                offset: selection.start + emoji.length,
                              ),
                            );
                          } else {
                            textController.text = currentText + emoji;
                            textController.selection = TextSelection.collapsed(
                              offset: textController.text.length,
                            );
                          }

                          if (onEmojiTapped != null) {
                            onEmojiTapped!();
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          : const SizedBox(width: double.infinity),
    );
  }
}
