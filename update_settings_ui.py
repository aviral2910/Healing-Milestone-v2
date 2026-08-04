import re

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'r') as f:
    content = f.read()

# Replace initState
new_init_state = """  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(postCreationControllerProvider);
      setState(() {
        _selectedTags = List.from(state.tags);
        _selectedUsers = List.from(state.selectedUsers);
        _isAnonymous = state.isAnonymous;
        _selectedType = state.type;
      });
    });
  }"""

content = re.sub(r'  @override\s+void initState\(\) \{.*?  \}', new_init_state, content, flags=re.DOTALL)

# Now we need to remove the title and content text fields from the SingleChildScrollView
# In the build method, we have:
#            // Title input
#            const SizedBox(height: 16),
#            Padding(
#              padding: const EdgeInsets.symmetric(horizontal: 16.0),
# ...
#            ),
#            // Divider
#            const Divider(height: 32),
#            // Content Input
# ...
#            ),
# We will use regex to remove everything between `// Title input` and `// Tag section header`

content = re.sub(r'\s*// Title input.*?// Tag section header', r'\n            // Tag section header', content, flags=re.DOTALL)

with open('lib/features/milestone/presentation/screens/post_settings_screen.dart', 'w') as f:
    f.write(content)
