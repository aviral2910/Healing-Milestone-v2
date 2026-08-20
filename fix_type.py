with open("lib/features/journey/presentation/screens/together_feed_screen.dart", "r") as f:
    content = f.read()

content = content.replace(
    "final feedAsync = ref.watch(milestoneProvider);",
    "final AsyncValue<OffsetPaginatedState<JourneyMilestoneModel>> feedAsync = ref.watch(milestoneProvider);"
)

if "import '../../data/models/journey_models.dart';" not in content:
    content = "import '../../data/models/journey_models.dart';\n" + content

with open("lib/features/journey/presentation/screens/together_feed_screen.dart", "w") as f:
    f.write(content)
