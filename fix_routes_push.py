import re
import sys

# 1. story_detail_screen.dart
path_detail = 'lib/features/milestone/presentation/screens/story_detail_screen.dart'
with open(path_detail, 'r') as f:
    content = f.read()

# Add import if missing
if 'post_creation_state.dart' not in content:
    content = "import '../providers/post_creation_state.dart';\n" + content

content = content.replace("context.push(AppRoutes.create, extra: story);", "ref.read(postCreationControllerProvider.notifier).initializeWithStory(story);\n                                context.push(AppRoutes.create);")

with open(path_detail, 'w') as f:
    f.write(content)

# 2. drafts_screen.dart
path_draft = 'lib/features/profile/presentation/screens/drafts_screen.dart'
with open(path_draft, 'r') as f:
    content = f.read()

if 'post_creation_state.dart' not in content:
    content = "import '../../../../features/milestone/presentation/providers/post_creation_state.dart';\n" + content

content = content.replace("context.push(AppRoutes.create, extra: {'draft': draft});", "ref.read(postCreationControllerProvider.notifier).initializeWithDraft(draft);\n                            context.push(AppRoutes.create);")

with open(path_draft, 'w') as f:
    f.write(content)


# 3. profile_screen.dart
path_profile = 'lib/features/profile/presentation/screens/profile_screen.dart'
with open(path_profile, 'r') as f:
    content = f.read()

if 'post_creation_state.dart' not in content:
    content = "import '../../../../features/milestone/presentation/providers/post_creation_state.dart';\n" + content

content = content.replace("context.push(AppRoutes.create);", "ref.read(postCreationControllerProvider.notifier).reset();\n                        context.push(AppRoutes.create);")

with open(path_profile, 'w') as f:
    f.write(content)
