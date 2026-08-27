import re

with open('lib/shared/utils/share_utils.dart', 'r') as f:
    content = f.read()

# Replace showModalBottomSheet with showGeneralDialog and DirectShareOverlay
new_content = """import 'package:flutter/material.dart';
import 'package:healing_milestones/shared/widgets/direct_share_sheet.dart';

void showJourneyShareOptions(BuildContext context, String journeyId, String title, {bool isMine = false, String authorName = ""}) {
  DirectShareOverlay.show(
    context,
    journeyId: journeyId,
    shareUrl: 'https://healingmilestones.com/journey/$journeyId',
    shareText: authorName.isNotEmpty ? 'Check out this journey by $authorName: $title' : 'Check out this journey: $title',
    qrBottomText: 'Scan to view journey',
  );
}

void showStoryShareOptions(BuildContext context, String storyId, String content) {
  DirectShareOverlay.show(
    context,
    storyId: storyId,
    shareUrl: 'https://healingmilestones.com/story/$storyId',
    shareText: 'Check out this story: $content',
    qrBottomText: 'Scan to view story',
  );
}

void showProfileShareOptions(BuildContext context, String profileId) {
  DirectShareOverlay.show(
    context,
    profileId: profileId,
    shareUrl: 'https://healingmilestones.com/profile/$profileId',
    shareText: 'Check out this profile!',
    qrBottomText: 'Scan to view profile',
  );
}

void showShareOptions(BuildContext context, String storyId) {
  DirectShareOverlay.show(
    context,
    storyId: storyId,
    shareUrl: 'https://healingmilestones.com/story/$storyId',
    shareText: 'Check out this post!',
    qrBottomText: 'Scan to view post',
  );
}
"""

with open('lib/shared/utils/share_utils.dart', 'w') as f:
    f.write(new_content)
