import re

with open("lib/features/auth/data/auth_provider.dart", "r") as f:
    content = f.read()

# Make sure to import main.dart
if "import '../../../../main.dart';" not in content:
    content = content.replace("import 'dart:convert';", "import 'dart:convert';\nimport '../../../../main.dart';\nimport 'package:flutter/material.dart';")

# Find the print statement in _handleUserAuthenticated
replacement = """      } else {
        print('Background fetch failed, keeping cached user data.');
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Server is healing (waking up) 🧘‍♀️ Please give it a few seconds...'),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }"""

content = content.replace("""      } else {
        print('Background fetch failed, keeping cached user data.');
      }""", replacement)

with open("lib/features/auth/data/auth_provider.dart", "w") as f:
    f.write(content)

