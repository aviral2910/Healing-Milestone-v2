import re

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'r') as f:
    content = f.read()

# 1. Remove _saveDraft references
content = re.sub(r'IconButton\(\n\s*icon: const Icon\(Icons.save_outlined\),\n\s*onPressed: _saveDraft,\n\s*tooltip: \'Save Draft\',\n\s*\),', '', content, flags=re.DOTALL)

# 2. Fix nullable issues in image pickers
# `postState.imagePath.isNotEmpty` causes errors because `postState.imagePath` is nullable.
content = content.replace('ref.read(postCreationControllerProvider).imagePath.isNotEmpty', '(ref.read(postCreationControllerProvider).imagePath?.isNotEmpty ?? false)')

# 3. Remove _titleController and _contentController calls
# lines 436, 437 are probably `_titleController.dispose()` and `_contentController.dispose()`
content = content.replace('_titleController.dispose();', '')
content = content.replace('_contentController.dispose();', '')

# lines 678, 702 are probably inside a generic save method or somehow we missed another TextField
# Let's completely nuke any remaining `controller: _titleController` and `controller: _contentController`
content = re.sub(r'TextField\(\n\s*controller: _titleController,.*?\n\s*\)', 'Container()', content, flags=re.DOTALL)
content = re.sub(r'TextField\(\n\s*controller: _contentController,.*?\n\s*\)', 'Container()', content, flags=re.DOTALL)

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'w') as f:
    f.write(content)
