with open("lib/features/auth/presentation/screens/suggested_follows_screen.dart", "r") as f:
    content = f.read()

content = content.replace(
"""  @override
  void initState() {
    super.initState();
    // Default select everyone initially
    _selectedUserIds = _suggestedUsers.map((u) => u['id'] as String).toSet();
  }""",
"""  @override
  void initState() {
    super.initState();
    // Start with empty selections
    _selectedUserIds = {};
  }""")

with open("lib/features/auth/presentation/screens/suggested_follows_screen.dart", "w") as f:
    f.write(content)
