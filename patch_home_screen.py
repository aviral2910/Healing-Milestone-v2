with open("lib/features/home/presentation/screens/home_screen.dart", "r") as f:
    content = f.read()

replacement = """    final authState = ref.watch(authProvider).value;
    final hasAuthError = ref.watch(authProvider).hasError;
    final isAuthenticated = authState?.status == AuthStatus.authenticated;
    final currentIndex = ref.watch(homeTabProvider);"""

content = content.replace("    final authState = ref.watch(authProvider).value;\n    final isAuthenticated = authState?.status == AuthStatus.authenticated;\n    final currentIndex = ref.watch(homeTabProvider);", replacement)

import_server_healing = "import 'package:healing_milestones/shared/widgets/server_healing_loader.dart';"
if import_server_healing not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_server_healing)

wall_widget_2 = """            hasAuthError
                ? const ServerHealingLoader()
                : isAuthenticated 
                ? MyPathScreen(
                    isActiveTab: currentIndex == 1,
                  )
                : const GuestAuthWallWidget("""

content = content.replace("""            isAuthenticated 
                ? MyPathScreen(
                    isActiveTab: currentIndex == 1,
                  )
                : const GuestAuthWallWidget(""", wall_widget_2)

wall_widget_4 = """            hasAuthError
                ? const ServerHealingLoader()
                : isAuthenticated 
                ? MessagesScreen(
                    scrollController: _messagesScrollController,
                    isActiveTab: currentIndex == 3,
                  )
                : const GuestAuthWallWidget("""

content = content.replace("""            isAuthenticated 
                ? MessagesScreen(
                    scrollController: _messagesScrollController,
                    isActiveTab: currentIndex == 3,
                  )
                : const GuestAuthWallWidget(""", wall_widget_4)

wall_widget_5 = """            hasAuthError
                ? const ServerHealingLoader()
                : isAuthenticated 
                ? const ProfileScreen()
                : const GuestAuthWallWidget("""

content = content.replace("""            isAuthenticated 
                ? const ProfileScreen()
                : const GuestAuthWallWidget(""", wall_widget_5)

with open("lib/features/home/presentation/screens/home_screen.dart", "w") as f:
    f.write(content)
