import 'package:flutter/material.dart';
import 'package:healing_milestones/core/models/story_model.dart';
import 'package:healing_milestones/shared/widgets/universal_comments_thread.dart';

void showCommentsBottomSheet(BuildContext context, StoryModel story) {
  showUniversalCommentsBottomSheet(
    context,
    targetId: story.storyId,
    ownerId: story.authorId,
    threadType: CommentThreadType.story,
  );
}
