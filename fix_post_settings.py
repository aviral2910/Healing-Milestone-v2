import re

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'r') as f:
    content = f.read()

# 1. Imports
content = "import '../providers/post_creation_state.dart';\n" + content

# 2. Class names
content = content.replace('PostCreationScreen', 'PostSettingsScreen')
content = content.replace('_PostCreationScreenState', '_PostSettingsScreenState')

# 3. Constructor
content = re.sub(
    r'class PostSettingsScreen extends StatefulHookConsumerWidget \{.*?\n\}',
    r'''class PostSettingsScreen extends StatefulHookConsumerWidget {
  const PostSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PostSettingsScreen> createState() => _PostSettingsScreenState();
}''',
    content,
    flags=re.DOTALL
)

# 4. State vars & initState & dispose
state_vars_start = content.find('class _PostSettingsScreenState extends ConsumerState<PostSettingsScreen> {')
submit_post_start = content.find('  Future<void> _submitPost() async {')

new_state_vars = '''class _PostSettingsScreenState extends ConsumerState<PostSettingsScreen> {
  bool _isAnonymous = false;
  String _selectedTemplate = 'minimalist';
  StoryType _selectedType = StoryType.story;

  XFile? _selectedImage;
  bool _isUploading = false;

  final TextEditingController _tagController = TextEditingController();
  List<String> _selectedTags = [];
  List<String> _suggestions = [];
  Timer? _debounce;
  bool _isSearchingTags = false;

  final TextEditingController _userSearchController = TextEditingController();
  List<UserModel> _selectedUsers = [];
  List<UserModel> _userSuggestions = [];
  Timer? _userDebounce;
  bool _isSearchingUsers = false;
  bool _removeExistingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(postCreationControllerProvider);
      setState(() {
        _selectedTags = List.from(state.tags);
        _selectedUsers = List.from(state.selectedUsers);
        _isAnonymous = state.isAnonymous;
        _selectedType = state.type;
        if (state.imagePath != null && state.imagePath!.isNotEmpty) {
           // We might not have a local XFile, but we can rely on state.imagePath for network URLs
        }
      });
    });
  }

  @override
  void dispose() {
    _tagController.dispose();
    _userSearchController.dispose();
    _debounce?.cancel();
    _userDebounce?.cancel();
    super.dispose();
  }

'''

content = content[:state_vars_start] + new_state_vars + content[submit_post_start:]

# 5. Update _submitPost()
content = content.replace('if (_titleController.text.trim().isEmpty) {', 'final postState = ref.read(postCreationControllerProvider);\n    if (postState.title.isEmpty) {')

# Inside _submitPost, we need to replace widget.existingStory and others
content = content.replace('widget.existingStory != null', 'postState.isEditing')
content = content.replace('widget.existingStory!.mainImage', '(postState.imagePath ?? "")')
content = content.replace('widget.existingStory?.mainImage', 'postState.imagePath')
content = content.replace('widget.existingStory?.storyId', 'postState.originalStoryId')
content = content.replace("widget.existingStory?.publishedAt ?? DateTime.now()", "DateTime.now() /* TODO existing publish date */")
content = content.replace("widget.existingStory?.qrId ?? ''", "''")
content = content.replace("widget.existingStory?.verifierId ?? ''", "''")

content = content.replace('final contentText = _contentController.text.trim();', 'final contentText = postState.content;')
content = content.replace('_titleController.text.trim()', 'postState.title')

content = content.replace('if (_draftId != null) {', 'if (postState.draftId != null) {')
content = content.replace('ref.read(draftsProvider.notifier).deleteDraft(_draftId!);', 'ref.read(draftsProvider.notifier).deleteDraft(postState.draftId!);')


# 6. Build Method UI
# Change AppBar title
content = content.replace("Text(widget.existingStory != null ? 'Edit Post' : 'New Post')", "const Text('Post Settings')")
# Remove Title and Content text fields
# The layout is: SingleChildScrollView -> Column -> children -> 
# 1. Image Picker
# 2. Title input
# 3. Divider
# 4. Content Input
# 5. Tag section header
# We will cut out from "const SizedBox(height: 16)," after image picker, up to "// Tag section header"
content = re.sub(r'            const SizedBox\(height: 16\);\n\s*Padding\(\n\s*padding: const EdgeInsets.symmetric\(horizontal: 16.0\),\n\s*child: TextField\(\n\s*controller: _titleController,.*?\n\s*\),\n\s*\),\n\s*const Divider\(height: 32\),\n\s*Padding\(\n\s*padding: const EdgeInsets.symmetric\(horizontal: 16.0\),\n\s*child: TextField\(\n\s*controller: _contentController,.*?\n\s*\),\n\s*\),\n\s*const SizedBox\(height: 24\),', r'            const SizedBox(height: 24),', content, flags=re.DOTALL)


# Fix one reference to _contentController inside _pickImage or others? None should exist.

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'w') as f:
    f.write(content)
