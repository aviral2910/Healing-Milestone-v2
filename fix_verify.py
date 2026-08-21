with open("lib/features/settings/presentation/screens/settings_screen.dart", "r") as f:
    content = f.read()

content = content.replace("await ref.read(authProvider.notifier).verifyPhoneNumber(phoneNumber);", "await ref.read(authProvider.notifier).verifyPhoneNumber(phoneNumber, onCodeSent: () {});")

with open("lib/features/settings/presentation/screens/settings_screen.dart", "w") as f:
    f.write(content)
