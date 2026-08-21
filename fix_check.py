import re

with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "r") as f:
    content = f.read()

replacement = """                    onPressed: () {
                      if (milestones.length < 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'You need at least 3 check-ins before you can complete this journey!'),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                        return;
                      }
                      CompleteJourneyOverlay.show(context, journeyId: journeyId);
                    },"""

content = content.replace("""                    onPressed: () {
                      CompleteJourneyOverlay.show(context, journeyId: journeyId);
                    },""", replacement)

with open("lib/features/journey/presentation/screens/journey_detail_screen.dart", "w") as f:
    f.write(content)
