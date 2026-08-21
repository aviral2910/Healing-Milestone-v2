import re

with open("lib/core/repositories/user_repository.dart", "r") as f:
    content = f.read()

if "getSuggestedUsers" not in content:
    content = content.replace("Future<bool> isUsernameAvailable", "Future<List<UserModel>> getSuggestedUsers();\n  Future<bool> isUsernameAvailable")
    with open("lib/core/repositories/user_repository.dart", "w") as f:
        f.write(content)

