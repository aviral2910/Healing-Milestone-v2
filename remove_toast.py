import re

with open("lib/features/auth/data/auth_provider.dart", "r") as f:
    content = f.read()

replacement = """      } else {
        print('Background fetch failed, keeping cached user data.');
      }"""

content = re.sub(r'      } else \{\n        print\(\'Background fetch failed, keeping cached user data\.\'\);\n        rootScaffoldMessengerKey\.currentState\?\.showSnackBar\([\s\S]*?\);\n      \}', replacement, content)

with open("lib/features/auth/data/auth_provider.dart", "w") as f:
    f.write(content)
