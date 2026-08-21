with open("lib/features/posts/presentation/screens/post_screen.dart", "r") as f:
    content = f.read()
if "package:healing_milestones/shared/widgets/server_healing_loader.dart" not in content:
    content = content.replace("import 'package:healing_milestones/shared/widgets/app_loader.dart';", "import 'package:healing_milestones/shared/widgets/app_loader.dart';\nimport 'package:healing_milestones/shared/widgets/server_healing_loader.dart';")
with open("lib/features/posts/presentation/screens/post_screen.dart", "w") as f:
    f.write(content)

with open("lib/features/posts/presentation/screens/recommended_swipe_screen.dart", "r") as f:
    content2 = f.read()
if "package:healing_milestones/shared/widgets/server_healing_loader.dart" not in content2:
    if "import 'package:healing_milestones/shared/widgets/app_loader.dart';" in content2:
        content2 = content2.replace("import 'package:healing_milestones/shared/widgets/app_loader.dart';", "import 'package:healing_milestones/shared/widgets/app_loader.dart';\nimport 'package:healing_milestones/shared/widgets/server_healing_loader.dart';")
    else:
        content2 = "import 'package:healing_milestones/shared/widgets/server_healing_loader.dart';\n" + content2
with open("lib/features/posts/presentation/screens/recommended_swipe_screen.dart", "w") as f:
    f.write(content2)
