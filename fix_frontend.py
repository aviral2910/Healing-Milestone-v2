import glob
import os

files = glob.glob('lib/features/journey/**/*.dart', recursive=True)

for file in files:
    with open(file, 'r') as f:
        content = f.read()

    changed = False
    
    if "togetherFeedProvider" in content:
        content = content.replace("ref.invalidate(togetherFeedProvider);", "ref.invalidate(recommendedMilestonesProvider);\n      ref.invalidate(followingMilestonesProvider);")
        content = content.replace("container.invalidate(togetherFeedProvider);", "container.invalidate(recommendedMilestonesProvider);\n      container.invalidate(followingMilestonesProvider);")
        
        # For my_path_screen list
        content = content.replace("togetherFeedProvider,", "recommendedMilestonesProvider, followingMilestonesProvider,")
        
        changed = True
        
    if "AutoDisposeFutureProvider" in content and "walking_with_carousel.dart" in file:
        content = content.replace("AutoDisposeFutureProvider<List<JourneyModel>>", "dynamic")
        changed = True

    if changed:
        with open(file, 'w') as f:
            f.write(content)
        print(f"Fixed {file}")
