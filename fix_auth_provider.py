with open("lib/features/auth/data/auth_provider.dart", "r") as f:
    content = f.read()

replacement = """  Future<void> reauthenticateWithGoogle() async {
    try {
      await _authRepository.reauthenticateWithGoogle();
    } catch (e) {
      print('Reauthenticate Google error: $e');
      rethrow;
    }
  }

  Future<void> reauthenticateWithPhoneCredential(String smsCode) async {
    try {
      final verificationId = state.value?.verificationId;
      if (verificationId == null) {
        throw Exception("Verification ID is missing.");
      }
      await _authRepository.reauthenticateWithPhoneCredential(verificationId, smsCode);
      
      // Clear verification id
      state = AsyncValue.data(
        currentState.copyWith(
          verificationId: null,
          linkingPhoneNumber: null,
        ),
      );
    } catch (e) {
      print('Reauthenticate Phone error: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {"""

content = content.replace("  Future<void> deleteAccount() async {", replacement)

with open("lib/features/auth/data/auth_provider.dart", "w") as f:
    f.write(content)
