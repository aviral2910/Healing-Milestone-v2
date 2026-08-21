import re

with open("lib/features/settings/presentation/screens/settings_screen.dart", "r") as f:
    content = f.read()

if "package:firebase_auth/firebase_auth.dart" not in content:
    content = "import 'package:firebase_auth/firebase_auth.dart';\n" + content

reauth_logic = """
                          String errorMessage = e.toString();
                          if (errorMessage.contains('requires-recent-login')) {
                            final fbUser = FirebaseAuth.instance.currentUser;
                            if (fbUser != null) {
                              bool isGoogle = false;
                              bool isPhone = false;
                              for (final providerInfo in fbUser.providerData) {
                                if (providerInfo.providerId == 'google.com') isGoogle = true;
                                if (providerInfo.providerId == 'phone') isPhone = true;
                              }
                              
                              if (isGoogle) {
                                try {
                                  await ref.read(authProvider.notifier).reauthenticateWithGoogle();
                                  await ref.read(authProvider.notifier).deleteAccount();
                                  if (context.mounted) context.go(AppRoutes.home);
                                  return;
                                } catch (reAuthErr) {
                                  errorMessage = 'Google Re-authentication failed. Please log out and log back in.';
                                }
                              } else if (isPhone) {
                                if (context.mounted) {
                                  _showPhoneReauthDialog(context, ref, fbUser.phoneNumber ?? '');
                                  return;
                                }
                              } else {
                                errorMessage = 'For security reasons, you must log out and log back in before deleting your account.';
                                await ref.read(authProvider.notifier).signOut();
                                if (context.mounted) context.go(AppRoutes.home);
                              }
                            }
                          }
                          
                          if (context.mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
                                backgroundColor: theme.colorScheme.error,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
"""

content = re.sub(r'                          String errorMessage = e\.toString\(\);\n                          if \(errorMessage\.contains\(\'requires-recent-login\'\)\) \{[\s\S]*?\}', reauth_logic.strip(), content)

# Remove the trailing } and add the dialog, then re-add the trailing }
# Since it's a stateless/consumer widget, we can find the last '}'
idx = content.rfind("}")
if idx != -1:
    dialog_code = """
  void _showPhoneReauthDialog(BuildContext context, WidgetRef ref, String phoneNumber) {
    final theme = Theme.of(context);
    final otpController = TextEditingController();
    bool isLoading = false;
    bool codeSent = false;
    String error = '';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: const Text('Verify Identity'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('For security, please verify your phone number ($phoneNumber) to delete your account.'),
                  const SizedBox(height: 16),
                  if (error.isNotEmpty)
                    Text(error, style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: 16),
                  if (!codeSent)
                    ElevatedButton(
                      onPressed: isLoading ? null : () async {
                        setState(() { isLoading = true; error = ''; });
                        try {
                          await ref.read(authProvider.notifier).verifyPhoneNumber(phoneNumber);
                          setState(() { isLoading = false; codeSent = true; });
                        } catch (e) {
                          setState(() { isLoading = false; error = 'Failed to send SMS code.'; });
                        }
                      },
                      child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Send SMS Code'),
                    )
                  else
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '6-digit OTP',
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                if (codeSent)
                  ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      if (otpController.text.length != 6) {
                        setState(() => error = 'Enter a valid 6-digit OTP');
                        return;
                      }
                      setState(() { isLoading = true; error = ''; });
                      try {
                        await ref.read(authProvider.notifier).reauthenticateWithPhoneCredential(otpController.text);
                        await ref.read(authProvider.notifier).deleteAccount();
                        if (context.mounted) {
                          Navigator.pop(context); // close dialog
                          context.go(AppRoutes.home);
                        }
                      } catch (e) {
                        setState(() { isLoading = false; error = 'Incorrect OTP or verification failed.'; });
                      }
                    },
                    child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Verify & Delete'),
                  ),
              ],
            );
          }
        );
      }
    );
  }
"""
    content = content[:idx] + dialog_code + content[idx:]

with open("lib/features/settings/presentation/screens/settings_screen.dart", "w") as f:
    f.write(content)
