import re

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'r') as f:
    content = f.read()

# Fix nullable properties for imagePath
# The error says "The property 'isEmpty' can't be unconditionally accessed because the receiver can be 'null'"
content = content.replace('ref.read(postCreationControllerProvider).imagePath.isEmpty', '(ref.read(postCreationControllerProvider).imagePath?.isEmpty ?? true)')

# Wait, the previous replacement was:
# content = content.replace('ref.read(postCreationControllerProvider).imagePath.isNotEmpty', '(ref.read(postCreationControllerProvider).imagePath?.isNotEmpty ?? false)')
# It seems `imagePath` was used as `imagePath.isNotEmpty` but I replaced it wrong.
# Let's just fix it by replacing `.imagePath.isNotEmpty` with `?.imagePath?.isNotEmpty ?? false`
# Since I don't know the exact syntax left, I'll use regex to fix any `imagePath.isNotEmpty` and `imagePath.isEmpty`
content = re.sub(r'ref.read\(postCreationControllerProvider\)\.imagePath\.isNotEmpty', r'(ref.read(postCreationControllerProvider).imagePath?.isNotEmpty ?? false)', content)
content = re.sub(r'ref.read\(postCreationControllerProvider\)\.imagePath\.isEmpty', r'(ref.read(postCreationControllerProvider).imagePath?.isEmpty ?? true)', content)
content = re.sub(r'\(ref\.read\(postCreationControllerProvider\)\.imagePath\?\.isNotEmpty \?\? false\)\.isNotEmpty', r'(ref.read(postCreationControllerProvider).imagePath?.isNotEmpty ?? false)', content)

# Remove unused _saveDraft definition and references
content = re.sub(r'void _saveDraft\(\) \{.*?\}', '', content, flags=re.DOTALL)
content = re.sub(r'Future<void> _saveDraft\(\) async \{.*?\}', '', content, flags=re.DOTALL)

# Let's remove `_titleController.dispose()` if it's there
content = content.replace('_titleController.dispose();', '')
content = content.replace('_contentController.dispose();', '')

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'w') as f:
    f.write(content)
