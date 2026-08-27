import 'package:flutter/material.dart';
import 'package:healing_milestones/shared/widgets/direct_share_sheet.dart';

void showJourneyShareOptions(BuildContext context, String journeyId, String title, {bool isMine = false, String authorName = ""}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DirectShareSheet(
      journeyId: journeyId,
      shareUrl: 'https://healingmilestones.com/journey/$journeyId',
      shareText: authorName.isNotEmpty ? 'Check out this journey by $authorName: $title' : 'Check out this journey: $title',
      qrBottomText: 'Scan to view journey',
    ),
  );
}

void showStoryShareOptions(BuildContext context, String storyId, String content) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DirectShareSheet(
      storyId: storyId,
      shareUrl: 'https://healingmilestones.com/story/$storyId',
      shareText: 'Check out this story: $content',
      qrBottomText: 'Scan to view story',
    ),
  );
}
