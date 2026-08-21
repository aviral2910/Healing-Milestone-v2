import re

with open("lib/features/settings/presentation/screens/settings_screen.dart", "r") as f:
    content = f.read()

replacement = """                        try {
                          await ref.read(authProvider.notifier).deleteAccount();
                          // Pop loading indicator
                          navContext.pop();
                          // Pop dialog
                          navContext.pop();
                          
                          context.go(AppRoutes.home);
                        } catch (e) {
                          // Pop loading indicator
                          navContext.pop();
                          // Pop dialog
                          navContext.pop();
                          
                          String errorMessage = e.toString();
                          if (errorMessage.contains('requires-recent-login')) {
                            errorMessage = 'For security reasons, you must log out and log back in before deleting your account.';
                            // Automatically sign them out
                            await ref.read(authProvider.notifier).signOut();
                            context.go(AppRoutes.home);
                          }
                          
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
                              backgroundColor: theme.colorScheme.error,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }"""

content = re.sub(r'                        try \{\n                          await ref\.read\(authProvider\.notifier\)\.deleteAccount\(\);\n                          // Pop loading indicator\n                          navContext\.pop\(\);\n                          // Pop dialog\n                          navContext\.pop\(\);\n                          \n                          context\.go\(AppRoutes\.home\);\n                        \} catch \(e\) \{\n                          // Pop loading indicator\n                          navContext\.pop\(\);\n                          // Pop dialog\n                          navContext\.pop\(\);\n                          \n                          scaffoldMessenger\.showSnackBar\(\n                            SnackBar\(\n                              content: Text\(\'Failed to delete account: \$e\'\),\n                              backgroundColor: theme\.colorScheme\.error,\n                            \),\n                          \);\n                        \}', replacement, content, flags=re.DOTALL)

with open("lib/features/settings/presentation/screens/settings_screen.dart", "w") as f:
    f.write(content)

