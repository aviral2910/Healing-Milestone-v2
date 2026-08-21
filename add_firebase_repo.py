import re

with open("lib/features/auth/data/firebase_user_repository.dart", "r") as f:
    content = f.read()

repo_code = """
  @override
  Future<List<UserModel>> getSuggestedUsers() async {
    return [];
  }
"""

if "getSuggestedUsers" not in content:
    content = content.replace("Future<bool> isUsernameAvailable", repo_code + "\n  Future<bool> isUsernameAvailable")
    with open("lib/features/auth/data/firebase_user_repository.dart", "w") as f:
        f.write(content)

