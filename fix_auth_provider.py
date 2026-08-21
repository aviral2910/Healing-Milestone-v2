with open("lib/features/auth/data/auth_provider.dart", "r") as f:
    content = f.read()

content = content.replace("currentState.copyWith(", "(state.value ?? const AuthState()).copyWith(")

with open("lib/features/auth/data/auth_provider.dart", "w") as f:
    f.write(content)
