import re

with open('lib/shared/widgets/direct_share_sheet.dart', 'r') as f:
    content = f.read()

# Fix import
if "import 'package:firebase_auth/firebase_auth.dart';" not in content:
    content = "import 'package:firebase_auth/firebase_auth.dart';\n" + content

# Fix user.username.toLowerCase
old_search = """!user.displayName.toLowerCase().contains(_searchQuery) &&
                                    !user.username.toLowerCase().contains(_searchQuery)"""
new_search = """!user.displayName.toLowerCase().contains(_searchQuery) &&
                                    !(user.username?.toLowerCase().contains(_searchQuery) ?? false)"""
content = content.replace(old_search, new_search)

# Fix withOpacity
content = content.replace("withOpacity(0.5)", "withValues(alpha: 0.5)")

with open('lib/shared/widgets/direct_share_sheet.dart', 'w') as f:
    f.write(content)
