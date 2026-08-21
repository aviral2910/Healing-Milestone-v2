import re

with open("lib/main.dart", "r") as f:
    content = f.read()

# Add the global key before main()
key_code = "final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();\n\nvoid main() async {"
content = content.replace("void main() async {", key_code)

# Add scaffoldMessengerKey to MaterialApp.router
app_replacement = """    Widget app = MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Healing Milestones',"""
content = re.sub(r'    Widget app = MaterialApp\.router\(\n      title: \'Healing Milestones\',', app_replacement, content)

with open("lib/main.dart", "w") as f:
    f.write(content)
