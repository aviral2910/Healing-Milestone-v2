import re

with open("lib/features/auth/data/api_user_repository.dart", "r") as f:
    content = f.read()

replacement = """  Future<UserModel?> _fetchUserData(String uid) async {
    try {
      final response = await _dio.get('/api/users/$uid');
      return UserModel.fromMap(response.data);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          // Truly not found in DB = needs onboarding
          return null;
        }
      }
      // For network errors, 500s, or timeouts, we must throw so the app doesn't assume the user doesn't exist.
      rethrow;
    }
  }"""

content = re.sub(r'  Future<UserModel\?> _fetchUserData\(String uid\) async \{\n    try \{\n      final response = await _dio\.get\(\'/api/users/\$uid\'\);\n      return UserModel\.fromMap\(response\.data\);\n    \} catch \(e\) \{\n      return null;\n    \}\n  \}', replacement, content, flags=re.DOTALL)

with open("lib/features/auth/data/api_user_repository.dart", "w") as f:
    f.write(content)

