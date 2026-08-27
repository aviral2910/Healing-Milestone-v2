import 'package:flutter/material.dart';
import 'package:healing_milestones/features/journey/data/models/journey_models.dart';
import 'package:healing_milestones/shared/widgets/universal_comments_thread.dart';

void showCommentsBottomSheet(BuildContext context, JourneyMilestoneModel story) {
  showUniversalCommentsBottomSheet(
    context,
    targetId: story.id,
    ownerId: story.userId,
    threadType: CommentThreadType.journey,
    journeyId: story.journeyId,
  );
}
