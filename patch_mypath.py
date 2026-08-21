with open("lib/features/home/presentation/screens/home_screen.dart", "r") as f:
    content = f.read()

wall_widget_2 = """            hasAuthError
                ? const ServerHealingLoader()
                : isAuthenticated 
                ? const MyPathScreen()
                : const GuestAuthWallWidget("""

content = content.replace("""            isAuthenticated 
                ? const MyPathScreen()
                : const GuestAuthWallWidget(""", wall_widget_2)

with open("lib/features/home/presentation/screens/home_screen.dart", "w") as f:
    f.write(content)
