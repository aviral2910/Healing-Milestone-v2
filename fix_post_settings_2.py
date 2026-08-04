import re

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'r') as f:
    content = f.read()

# 1. Remove _saveDraft references
content = re.sub(r'IconButton\(\n\s*icon: const Icon\(Icons.save_outlined\),\n\s*onPressed: _saveDraft,\n\s*tooltip: \'Save Draft\',\n\s*\),', '', content, flags=re.DOTALL)

# 2. Fix postState inside _pickImage or wherever
# Let's replace `postState.` with `ref.read(postCreationControllerProvider).` everywhere except where we explicitly define `final postState = ...`
content = content.replace('postState.', 'ref.read(postCreationControllerProvider).')

# 3. Fix _titleController and _contentController remaining references (probably inside the widget tree somewhere we missed)
# Actually, I should just remove the fields that use _titleController and _contentController entirely. 
# Let's see if they are still around.
# Oh, we had a regex that failed. Let's just remove `_titleController` and `_contentController` blocks.
content = re.sub(r'\s*Padding\(\n\s*padding: const EdgeInsets.symmetric\(horizontal: 16.0\),\n\s*child: TextField\(\n\s*controller: _titleController,.*?\n\s*\),\n\s*\),\n\s*const Divider\(height: 32\),\n\s*Padding\(\n\s*padding: const EdgeInsets.symmetric\(horizontal: 16.0\),\n\s*child: TextField\(\n\s*controller: _contentController,.*?\n\s*\),\n\s*\),\n\s*const SizedBox\(height: 24\),', r'\n            const SizedBox(height: 24),', content, flags=re.DOTALL)

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'w') as f:
    f.write(content)
