with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "r") as f:
    content = f.read()

old_margin = "margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),"
new_margin = "margin: const EdgeInsets.only(left: 0, right: 16, top: 8, bottom: 8),"

content = content.replace(old_margin, new_margin)

with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "w") as f:
    f.write(content)
