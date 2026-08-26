with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "r") as f:
    content = f.read()

content = content.replace("visibility: widget.milestone.visibility,", "visibility: widget.milestone.visibility,\n                    isMine: widget.milestone.isMine,")

with open("lib/features/journey/presentation/widgets/together_feed_card.dart", "w") as f:
    f.write(content)
