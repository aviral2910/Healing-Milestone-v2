import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# Add imports for navigation
if "import 'package:healing_milestones/features/journey/presentation/screens/journey_detail_screen.dart';" not in content:
    imports = """import 'package:healing_milestones/features/journey/presentation/screens/journey_detail_screen.dart';
import 'package:healing_milestones/features/milestone/presentation/screens/story_detail_screen.dart';
import 'package:healing_milestones/features/profile/presentation/screens/public_profile_screen.dart';
"""
    content = content.replace("import 'package:flutter/material.dart';", imports + "import 'package:flutter/material.dart';")

# 1. Wrap msg.imageUrl in GestureDetector
old_image = """              if (msg.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: msg.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildShimmerBox(context, double.infinity, 200),
                      errorWidget: (context, url, error) => const SizedBox(
                        height: 100,
                        child: Center(child: Icon(Icons.error_outline)),
                      ),
                    ),
                  ),
                ),"""
new_image = """              if (msg.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          iconTheme: const IconThemeData(color: Colors.white),
                        ),
                        body: Center(
                          child: InteractiveViewer(
                            minScale: 1.0,
                            maxScale: 4.0,
                            child: CachedNetworkImage(imageUrl: msg.imageUrl!),
                          ),
                        ),
                      )));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: msg.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildShimmerBox(context, double.infinity, 200),
                        errorWidget: (context, url, error) => const SizedBox(
                          height: 100,
                          child: Center(child: Icon(Icons.error_outline)),
                        ),
                      ),
                    ),
                  ),
                ),"""
content = content.replace(old_image, new_image)

# 2. Wrap _buildSharedCard's return Container with GestureDetector
old_card_return = """    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column("""
new_card_return = """    return GestureDetector(
      onTap: () {
        if (isJourney) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => JourneyDetailScreen(journeyId: id)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailScreen(storyId: id)));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column("""
content = content.replace(old_card_return, new_card_return)

# 3. Wrap _buildSharedProfileCard's return Container with GestureDetector
old_profile_return = """    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: userAsync.when("""
new_profile_return = """    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: profileId)));
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: userAsync.when("""
content = content.replace(old_profile_return, new_profile_return)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
