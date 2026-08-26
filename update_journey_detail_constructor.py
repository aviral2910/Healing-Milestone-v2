import re
import glob

def add_ismine():
    # 1. Update JourneyDetailScreen
    with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "r") as f:
        content = f.read()
    
    if "final bool isMine;" not in content:
        content = content.replace("final MilestoneVisibility? visibility;", "final MilestoneVisibility? visibility;\n  final bool isMine;")
        content = content.replace("this.visibility,", "this.visibility,\n    this.isMine = false,")
        with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "w") as f:
            f.write(content)
        print("Updated JourneyDetailScreen")

add_ismine()
