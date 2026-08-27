import re

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'r') as f:
    content = f.read()

old_sheet_text = """                                      Text(
                                        otherUser.displayName,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 24),
                                      Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),"""

new_sheet_text = """                                      Text(
                                        otherUser.displayName,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 32),
                                        child: Text(
                                          'This will permanently delete the chat and its history for both of you.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),"""

content = content.replace(old_sheet_text, new_sheet_text)

with open('lib/features/chat/presentation/screens/inbox_screen.dart', 'w') as f:
    f.write(content)
