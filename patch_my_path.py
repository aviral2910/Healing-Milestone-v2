import re

with open("lib/features/journey/presentation/screens/my_path_screen.dart", "r") as f:
    content = f.read()

content = content.replace("visibility: journey.visibility,", "visibility: journey.visibility,\n                                  isMine: true,")

with open("lib/features/journey/presentation/screens/my_path_screen.dart", "w") as f:
    f.write(content)
print("Updated my_path_screen.dart")
