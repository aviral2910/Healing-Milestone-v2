with open("lib/features/journey/presentation/widgets/walking_with_carousel.dart", "r") as f:
    content = f.read()

content = content.replace(
    "final ProviderListenable<AsyncValue<List<JourneyModel>>> provider;",
    "final dynamic provider;"
)

content = content.replace(
    "final followingAsync = ref.watch(provider);",
    "final AsyncValue<List<JourneyModel>> followingAsync = ref.watch(provider);"
)

with open("lib/features/journey/presentation/widgets/walking_with_carousel.dart", "w") as f:
    f.write(content)
print("Updated provider type casting")
