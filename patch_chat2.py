import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# 1. Remove Voice/Video actions
old_actions = """        actions: [
          IconButton(
            icon: const Icon(Icons.local_phone_outlined),
            onPressed: () {}, 
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {}, 
          ),
        ],"""
new_actions = """        actions: [],"""
content = content.replace(old_actions, new_actions)

# 2. Remove Camera Button from input area
old_input = """        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4, right: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt, color: theme.colorScheme.onPrimary, size: 22),
                  onPressed: () {}, // Future camera integration
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            Expanded("""

new_input = """        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded("""
content = content.replace(old_input, new_input)

# 3. Add sharedProfileId to _MessageBubble
old_msg_shared = """              if (msg.sharedStoryId != null)
                _buildSharedCard(
                  context: context,
                  ref: ref,
                  id: msg.sharedStoryId!,
                  isJourney: false,
                  isMe: isMe,
                ),
              if (msg.text != null && msg.text!.isNotEmpty)"""

new_msg_shared = """              if (msg.sharedStoryId != null)
                _buildSharedCard(
                  context: context,
                  ref: ref,
                  id: msg.sharedStoryId!,
                  isJourney: false,
                  isMe: isMe,
                ),
              if (msg.sharedProfileId != null)
                _buildSharedProfileCard(
                  context: context,
                  ref: ref,
                  profileId: msg.sharedProfileId!,
                  isMe: isMe,
                ),
              if (msg.text != null && msg.text!.isNotEmpty)"""
content = content.replace(old_msg_shared, new_msg_shared)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
