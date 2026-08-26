with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "r") as f:
    content = f.read()

content = content.replace("widget.title: ", "title: ")
content = content.replace("widget.category: ", "category: ")

with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "w") as f:
    f.write(content)
