import re

with open("lib/features/auth/data/auth_provider.dart", "r") as f:
    content = f.read()

# Make sure imports exist
if "import 'dart:convert';" not in content:
    content = content.replace("import 'package:flutter_riverpod/flutter_riverpod.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'dart:convert';\nimport 'package:shared_preferences/shared_preferences.dart';")

replacement = """  Future<void> _handleUserAuthenticated(AuthUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUserStr = prefs.getString('cached_user_model_${user.uid}');
      if (cachedUserStr != null) {
        try {
          final cachedUserModel = UserModel.fromMap(jsonDecode(cachedUserStr));
          state = AsyncData(
            AuthState(
              status: AuthStatus.authenticated,
              authUser: user,
              userModel: cachedUserModel,
            ),
          );
        } catch (e) {
          print('Failed to parse cached user: $e');
        }
      }

      final userModel = await _userRepository.getUserData(user.uid);
      if (userModel == null) {
        state = AsyncData(
          AuthState(status: AuthStatus.needsOnboarding, authUser: user),
        );
      } else {
        await prefs.setString('cached_user_model_${user.uid}', jsonEncode(userModel.toMap()));
        state = AsyncData(
          AuthState(
            status: AuthStatus.authenticated,
            authUser: user,
            userModel: userModel,
          ),
        );
      }
    } catch (e, st) {
      if (state.value?.userModel == null) {
        state = AsyncError(e, st);
      } else {
        print('Background fetch failed, keeping cached user data.');
      }
    }
  }"""

content = re.sub(r'  Future<void> _handleUserAuthenticated\(AuthUser user\) async \{\n    try \{\n      final userModel = await _userRepository\.getUserData\(user\.uid\);\n      if \(userModel == null\) \{\n        state = AsyncData\(\n          AuthState\(status: AuthStatus\.needsOnboarding, authUser: user\),\n        \);\n      \} else \{\n        state = AsyncData\(\n          AuthState\(\n            status: AuthStatus\.authenticated,\n            authUser: user,\n            userModel: userModel,\n          \),\n        \);\n      \}\n    \} catch \(e, st\) \{\n      state = AsyncError\(e, st\);\n    \}\n  \}', replacement, content, flags=re.DOTALL)

with open("lib/features/auth/data/auth_provider.dart", "w") as f:
    f.write(content)

