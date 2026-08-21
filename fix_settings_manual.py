with open("lib/features/settings/presentation/screens/settings_screen.dart", "r") as f:
    content = f.read()

bad_chunk = """                          }
                        }
                          
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(errorMessage, style: const TextStyle(color: Colors.white)),
                              backgroundColor: theme.colorScheme.error,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }"""

good_chunk = """                          }
                        }"""

content = content.replace(bad_chunk, good_chunk)

with open("lib/features/settings/presentation/screens/settings_screen.dart", "w") as f:
    f.write(content)

with open("lib/features/auth/data/auth_provider.dart", "r") as f:
    content = f.read()

content = content.replace("currentState.copyWith(", "(state.value ?? const AuthState()).copyWith(")

with open("lib/features/auth/data/auth_provider.dart", "w") as f:
    f.write(content)
