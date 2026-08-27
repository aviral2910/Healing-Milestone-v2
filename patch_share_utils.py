with open('lib/shared/utils/share_utils.dart', 'r') as f:
    content = f.read()

new_functions = """
void showProfileShareOptions(BuildContext context, String profileId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DirectShareSheet(
      profileId: profileId,
      shareUrl: 'https://healingmilestones.com/profile/$profileId',
      shareText: 'Check out this profile!',
      qrBottomText: 'Scan to view profile',
    ),
  );
}

void showShareOptions(BuildContext context, String storyId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DirectShareSheet(
      storyId: storyId,
      shareUrl: 'https://healingmilestones.com/story/$storyId',
      shareText: 'Check out this post!',
      qrBottomText: 'Scan to view post',
    ),
  );
}
"""

with open('lib/shared/utils/share_utils.dart', 'w') as f:
    f.write(content + new_functions)
