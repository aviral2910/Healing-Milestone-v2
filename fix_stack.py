with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "r") as f:
    content = f.read()

content = content.replace("Stack(", "Stack(\n                  clipBehavior: Clip.none,")

with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "w") as f:
    f.write(content)
