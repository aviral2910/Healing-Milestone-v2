with open('lib/shared/widgets/direct_share_sheet.dart', 'r') as f:
    content = f.read()

# Just quickly replace basic TextStyles with theme
old_row = """                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                            Text('@${user.username}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                                          ],
                                        ),
                                      ),"""

new_row = """                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(user.displayName, style: Theme.of(context).textTheme.titleMedium),
                                            Text('@${user.username}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                          ],
                                        ),
                                      ),"""
content = content.replace(old_row, new_row)
with open('lib/shared/widgets/direct_share_sheet.dart', 'w') as f:
    f.write(content)
