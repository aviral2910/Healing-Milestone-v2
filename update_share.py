with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "r") as f:
    content = f.read()

old_action = "if (_currentVisibility == MilestoneVisibility.public)"
new_action = "if (_currentVisibility == MilestoneVisibility.public || _currentVisibility == MilestoneVisibility.anonymous)"

content = content.replace(old_action, new_action)

with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "w") as f:
    f.write(content)
