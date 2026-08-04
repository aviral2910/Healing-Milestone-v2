import re

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'r') as f:
    content = f.read()

# Replace class names
content = content.replace('PostCreationScreen', 'PostSettingsScreen')
content = content.replace('_PostCreationScreenState', '_PostSettingsScreenState')

# Replace _submitPost logic to read from provider
new_submit_post = """    final postState = ref.read(postCreationControllerProvider);
    final contentText = postState.content;
    final tagText = _tagController.text.trim();

    final Set<String> finalTags = Set.from(_selectedTags);"""

content = re.sub(r'final contentText = _contentController.text.trim\(\);\s*final tagText = _tagController.text.trim\(\);\s*final Set<String> finalTags = Set.from\(_selectedTags\);', new_submit_post, content)

# Change widget.existingStory check inside _submitPost to use postState.isEditing and originalStoryId
content = content.replace("widget.existingStory != null", "postState.isEditing")
content = content.replace("widget.existingStory?.storyId ?? const Uuid().v4()", "postState.originalStoryId ?? const Uuid().v4()")
content = content.replace("widget.existingStory?.publishedAt", "null /* TODO get publishedAt */")
content = content.replace("widget.existingStory?.qrId ?? ''", "''")
content = content.replace("widget.existingStory?.verifierId ?? ''", "''")
content = content.replace("widget.existingStory!.mainImage", "postState.imagePath ?? ''")
content = content.replace("widget.existingStory?.mainImage ?? ''", "postState.imagePath ?? ''")
content = content.replace("_titleController.text.trim()", "postState.title")
content = content.replace("_draftId", "postState.draftId")

# Need to add import for post_creation_state.dart
import_statement = "import '../providers/post_creation_state.dart';\n"
content = import_statement + content

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'w') as f:
    f.write(content)
