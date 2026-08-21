import re

with open("lib/features/auth/data/api_user_repository.dart", "r") as f:
    content = f.read()

repo_code = """
  Future<List<UserModel>> getSuggestedUsers() async {
    try {
      final response = await _dio.get('/api/users/suggested');
      final items = response.data['items'] as List;
      return items.map((e) => UserModel.fromMap(e)).toList();
    } catch (e) {
      print('Error getting suggested users: $e');
      return [];
    }
  }
"""

if "getSuggestedUsers" not in content:
    content = content.replace("Future<bool> isUsernameAvailable", repo_code + "\n  @override\n  Future<bool> isUsernameAvailable")
    with open("lib/features/auth/data/api_user_repository.dart", "w") as f:
        f.write(content)

