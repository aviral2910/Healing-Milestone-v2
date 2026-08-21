import re

with open("lib/features/profile/presentation/screens/edit_profile_screen.dart", "r") as f:
    content = f.read()

# Fix the broken inputFormatters
content = content.replace("""                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
                    ],
                      size: 20),""", "                      size: 20),")

content = content.replace("""                controller: _usernameController,
                textInputAction: TextInputAction.next,""", """                controller: _usernameController,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
                ],""")

with open("lib/features/profile/presentation/screens/edit_profile_screen.dart", "w") as f:
    f.write(content)
