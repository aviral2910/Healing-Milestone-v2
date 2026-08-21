import re

with open("lib/features/auth/presentation/screens/professional_onboarding_screen.dart", "r") as f:
    content = f.read()

# Remove the TextButton that says 'Skip' and the _skip method
replacement = """      appBar: AppBar(
        title: Text(titleText,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),"""

content = re.sub(r'      appBar: AppBar\([\s\S]*?backgroundColor: Colors\.transparent,\n        actions: \[\n          TextButton\([\s\S]*?child: Text\([\s\S]*?\'Skip\',[\s\S]*?\),\n          \),\n          const SizedBox\(width: 8\),\n        \],\n      \),', replacement, content)

# Remove _skip method
content = re.sub(r'  Future<void> _skip\(\) async \{[\s\S]*?\}', '', content)

with open("lib/features/auth/presentation/screens/professional_onboarding_screen.dart", "w") as f:
    f.write(content)
