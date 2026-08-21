import re

with open("lib/features/auth/data/auth_provider.dart", "r") as f:
    content = f.read()

# Add clear cache to signOut
sign_out_replacement = """  Future<void> signOut() async {
    final currentState = state.value;
    try {
      if (currentState?.authUser?.uid != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('cached_user_model_${currentState!.authUser!.uid}');
      }
      state = const AsyncValue.loading();
      await _authRepository.signOut();"""

content = re.sub(r'  Future<void> signOut\(\) async \{\n    final currentState = state\.value;\n    try \{\n      // Show loading state while signing out\n      state = const AsyncValue\.loading\(\);\n      await _authRepository\.signOut\(\);', sign_out_replacement, content, flags=re.DOTALL)

# Add clear cache to deleteAccount
delete_replacement = """  Future<void> deleteAccount() async {
    final currentState = state.value;
    try {
      if (currentState?.authUser?.uid != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('cached_user_model_${currentState!.authUser!.uid}');
      }
      state = const AsyncValue.loading();"""

content = re.sub(r'  Future<void> deleteAccount\(\) async \{\n    final currentState = state\.value;\n    try \{\n      state = const AsyncValue\.loading\(\);', delete_replacement, content, flags=re.DOTALL)


# Also add clear cache if unauthorized / not found is handled. But that is handled by _handleUserAuthenticated throwing, which doesn't clear cache directly. But if they are logged out by the listener, the listener triggers _init() with user == null, which does nothing.

with open("lib/features/auth/data/auth_provider.dart", "w") as f:
    f.write(content)
