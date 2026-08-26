import re

with open('lib/shared/widgets/qr_share_preview.dart', 'r') as f:
    content = f.read()

if 'direct_share_sheet.dart' not in content:
    content = "import 'package:healing_milestones/shared/widgets/direct_share_sheet.dart';\n" + content

# Replace showShareOptions (Story)
content = re.sub(
    r'void showShareOptions\(BuildContext context, String storyId\) \{.*?showModalBottomSheet\([\s\S]*?\}\,[\s]*\)\;[\s]*\}',
    '''void showShareOptions(BuildContext context, String storyId) {
  final shareUrl = 'https://healingmilestones.in/story/$storyId';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DirectShareSheet(
        storyId: storyId,
        shareUrl: shareUrl,
        shareText: 'Check out this story on Healing Milestones:\\n\\n$shareUrl',
        qrBottomText: 'Scan to read the Healing Story',
      );
    },
  );
}'''.replace('\\n', '\\\\n'),
    content,
    flags=re.DOTALL | re.MULTILINE
)

# Replace showProfileShareOptions
content = re.sub(
    r'void showProfileShareOptions\(BuildContext context, String userId\) \{.*?showModalBottomSheet\([\s\S]*?\}\,[\s]*\)\;[\s]*\}',
    '''void showProfileShareOptions(BuildContext context, String userId) {
  final shareUrl = 'https://healingmilestones.in/user/$userId';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DirectShareSheet(
        profileId: userId,
        shareUrl: shareUrl,
        shareText: 'Check out this profile on Healing Milestones:\\n\\n$shareUrl',
        qrBottomText: 'Scan to view Profile',
      );
    },
  );
}'''.replace('\\n', '\\\\n'),
    content,
    flags=re.DOTALL | re.MULTILINE
)

# Replace showJourneyShareOptions
content = re.sub(
    r'void showJourneyShareOptions\(BuildContext context, String journeyId, String journeyTitle, \{bool isMine = true, String\? authorName\}\) \{.*?showModalBottomSheet\([\s\S]*?\}\,[\s]*\)\;[\s]*\}',
    '''void showJourneyShareOptions(BuildContext context, String journeyId, String journeyTitle, {bool isMine = true, String? authorName}) {
  final shareUrl = 'https://healingmilestones.in/journey/$journeyId';

  String text = 'Follow my journey: $journeyTitle on Healing Milestones:\\n\\n$shareUrl';
  String qrText = 'Scan to follow my journey on Healing Milestones.';
  
  if (!isMine) {
    if (authorName != null && authorName != 'Anonymous') {
      text = "Follow $authorName's journey: $journeyTitle on Healing Milestones:\\n\\n$shareUrl";
      qrText = "Scan to follow $authorName's journey on Healing Milestones.";
    } else {
      text = "Check out this journey: $journeyTitle on Healing Milestones:\\n\\n$shareUrl";
      qrText = "Scan to follow this journey on Healing Milestones.";
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DirectShareSheet(
        journeyId: journeyId,
        shareUrl: shareUrl,
        shareText: text,
        qrBottomText: qrText,
      );
    },
  );
}'''.replace('\\n', '\\\\n'),
    content,
    flags=re.DOTALL | re.MULTILINE
)

with open('lib/shared/widgets/qr_share_preview.dart', 'w') as f:
    f.write(content)
