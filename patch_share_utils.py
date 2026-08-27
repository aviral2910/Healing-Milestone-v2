import re

with open('lib/shared/utils/share_utils.dart', 'r') as f:
    content = f.read()

content = content.replace(
    'void showJourneyShareOptions(BuildContext context, String journeyId, String title, {bool isMine = false}) {',
    'void showJourneyShareOptions(BuildContext context, String journeyId, String title, {bool isMine = false, String authorName = ""}) {'
)
content = content.replace(
    "shareText: 'Check out this journey: $title',",
    "shareText: authorName.isNotEmpty ? 'Check out this journey by $authorName: $title' : 'Check out this journey: $title',"
)

with open('lib/shared/utils/share_utils.dart', 'w') as f:
    f.write(content)
