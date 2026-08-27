import re

with open('lib/shared/widgets/direct_share_sheet.dart', 'r') as f:
    content = f.read()

old_send = """          await repo.sendMessage(
            roomId: roomId,
            senderId: currentUid,
            text: widget.journeyId != null
                ? "Check out this Journey!"
                : widget.storyId != null
                ? "Check out this Story!"
                : "Check out this profile!",
            sharedJourneyId: widget.journeyId,
            sharedStoryId: widget.storyId,
          );"""

new_send = """          await repo.sendMessage(
            roomId: roomId,
            senderId: currentUid,
            text: widget.journeyId != null
                ? "Check out this Journey!"
                : widget.storyId != null
                ? "Check out this Post!"
                : "Check out this profile!",
            sharedJourneyId: widget.journeyId,
            sharedStoryId: widget.storyId,
            sharedProfileId: widget.profileId,
          );"""

content = content.replace(old_send, new_send)

with open('lib/shared/widgets/direct_share_sheet.dart', 'w') as f:
    f.write(content)
