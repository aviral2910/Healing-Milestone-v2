with open("lib/features/journey/presentation/widgets/log_milestone_overlay.dart", "r") as f:
    content = f.read()

# Let's insert the variable right after EmotionStatus? _selectedEmotion;
old_decl = "EmotionStatus? _selectedEmotion;"
new_decl = "EmotionStatus? _selectedEmotion;\n  EmotionCategory _selectedCategory = EmotionCategory.positive;"

content = content.replace(old_decl, new_decl)

with open("lib/features/journey/presentation/widgets/log_milestone_overlay.dart", "w") as f:
    f.write(content)
