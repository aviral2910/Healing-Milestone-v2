import re

with open("lib/main.dart", "r") as f:
    content = f.read()

app_replacement = """      builder: (context) => MaterialApp.router(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        title: 'Healing Milestones',"""
content = re.sub(r'      builder: \(context\) => MaterialApp\.router\(\n        title: \'Healing Milestones\',', app_replacement, content)

with open("lib/main.dart", "w") as f:
    f.write(content)
