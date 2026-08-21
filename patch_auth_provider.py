with open("lib/features/auth/data/auth_provider.dart", "r") as f:
    content = f.read()

replacement = """      // 1. Delete user from the backend database (PostgreSQL)
      try {
        await _userRepository.deleteUserData();
      } catch (e) {
        // If the backend user is already deleted (e.g. from a previous failed attempt that hit requires-recent-login),
        // it might throw a 401 or 404. We can safely ignore it and proceed to delete the Firebase user.
        print('Backend deletion failed/already deleted: $e');
      }"""

content = content.replace("      // 1. Delete user from the backend database (PostgreSQL)\n      await _userRepository.deleteUserData();", replacement)

with open("lib/features/auth/data/auth_provider.dart", "w") as f:
    f.write(content)
