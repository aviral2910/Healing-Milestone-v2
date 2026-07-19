import os
import re

app_routes_import = "import 'package:healing_milestones/core/router/app_routes.dart';"

replacements = {
    r"'/login'": "AppRoutes.login",
    r"'/phone-auth'": "AppRoutes.phoneAuth",
    r"'/verify-otp'": "AppRoutes.verifyOtp",
    r"'/create'": "AppRoutes.create",
    r"'/'": "AppRoutes.home",
    r"'/role-selection'": "AppRoutes.roleSelection",
    r"'/professional-onboarding'": "AppRoutes.professionalOnboarding",
    r"'/profile'": "AppRoutes.profile",
    r"'/edit-profile'": "AppRoutes.editProfile",
    r"'/user-list'": "AppRoutes.userList",
}

def process_file(filepath):
    if 'app_routes.dart' in filepath or 'app_router.dart' in filepath:
        return

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    original_content = content

    for old, new in replacements.items():
        # Match context.push('...') or context.go('...') or context.pushNamed etc if any
        # Also handle context.push('/story/${...}') and context.push('/user/${...}')
        content = re.sub(r"context\.push\(" + old + r"(\s*[,)])", r"context.push(" + new + r"\1", content)
        content = re.sub(r"context\.go\(" + old + r"(\s*[,)])", r"context.go(" + new + r"\1", content)

    # Dynamic replacements
    content = re.sub(r"context\.push\('/user/\$\{([^}]+)\}'\)", r"context.push(AppRoutes.publicProfile(\1))", content)
    content = re.sub(r"context\.go\('/user/\$\{([^}]+)\}'\)", r"context.go(AppRoutes.publicProfile(\1))", content)

    content = re.sub(r"context\.push\('/story/\$\{([^}]+)\}'\)", r"context.push(AppRoutes.storyDetail(\1))", content)
    content = re.sub(r"context\.go\('/story/\$\{([^}]+)\}'\)", r"context.go(AppRoutes.storyDetail(\1))", content)

    if content != original_content:
        # Check if import is already there
        if app_routes_import not in content:
            # find first import
            first_import = content.find("import ")
            if first_import != -1:
                content = content[:first_import] + app_routes_import + "\n" + content[first_import:]
            else:
                content = app_routes_import + "\n\n" + content

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {filepath}")

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Done.")
