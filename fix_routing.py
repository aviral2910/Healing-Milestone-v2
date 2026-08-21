import re

# Fix Professional Onboarding to go to interest selection
with open("lib/features/auth/presentation/screens/professional_onboarding_screen.dart", "r") as f:
    content = f.read()
content = content.replace("context.go(AppRoutes.ascensionTransition);", "context.push(AppRoutes.interestSelection);")
with open("lib/features/auth/presentation/screens/professional_onboarding_screen.dart", "w") as f:
    f.write(content)

# Fix Suggested Follows to go to ascension transition
with open("lib/features/auth/presentation/screens/suggested_follows_screen.dart", "r") as f:
    content = f.read()
content = content.replace("context.go(AppRoutes.home);", "context.go(AppRoutes.ascensionTransition);")
with open("lib/features/auth/presentation/screens/suggested_follows_screen.dart", "w") as f:
    f.write(content)
