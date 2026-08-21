import re

with open("lib/features/auth/presentation/screens/professional_onboarding_screen.dart", "r") as f:
    content = f.read()

# 1. Remove Skip button block
start = content.find("actions: [")
if start != -1:
    end = content.find("],", start) + 2
    if end != -1:
        # We need to just remove the actions block, let's do string replacement instead
        content = content.replace(content[start:end], "")

# 2. Remove _skip method completely
skip_method = """  Future<void> _skip() async {
    if (_usernameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Please enter an available username before skipping.')));
      }
      return;
    }
    final newUserModel = UserModel(
      id: widget.role.name,
      firebaseUid: '',
      email: '',
      role: widget.role,
      username: _usernameController.text.trim(),
      displayName: _nameController.text.trim().isEmpty
          ? _usernameController.text.trim()
          : _nameController.text.trim(),
      specialty: null,
      registrationNumber: null,
      appliedForVerification: false,
    );
    await ref.read(authProvider.notifier).completeOnboarding(newUserModel);
    if (mounted) context.push(AppRoutes.interestSelection);
  }"""
if skip_method in content:
    content = content.replace(skip_method, "")
else:
    # Just do a regex for the _skip method
    content = re.sub(r'  Future<void> _skip\(\) async \{[\s\S]*?context\.push\(AppRoutes\.interestSelection\);\n  \}', '', content)
    # wait, it was originally context.go(AppRoutes.ascensionTransition);
    content = re.sub(r'  Future<void> _skip\(\) async \{[\s\S]*?context\.go\(AppRoutes\.ascensionTransition\);\n  \}', '', content)

# 3. Fix _submit routing
content = content.replace("context.go(AppRoutes.ascensionTransition);", "context.push(AppRoutes.interestSelection);")

with open("lib/features/auth/presentation/screens/professional_onboarding_screen.dart", "w") as f:
    f.write(content)
