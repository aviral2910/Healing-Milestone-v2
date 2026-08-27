import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# Add shimmer import if not present
if "import 'package:shimmer/shimmer.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:shimmer/shimmer.dart';\nimport 'package:cached_network_image/cached_network_image.dart';")

# Add _buildShimmerBox helper at the end of the file
shimmer_helper = """  Widget _buildShimmerBox(BuildContext context, double width, double height, {double radius = 8}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white12 : Colors.black12,
      highlightColor: isDark ? Colors.white24 : Colors.black26,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}"""
content = content.replace("}\n}", "}\n" + shimmer_helper)

# Update msg.imageUrl to use CachedNetworkImage with Shimmer
old_image = """              if (msg.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(msg.imageUrl!, fit: BoxFit.cover),
                  ),
                ),"""
new_image = """              if (msg.imageUrl != null)
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
content = content.replace(old_image, new_image)

# Update _buildSharedCard loading states
old_journey_load = """      if (journey == null) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }"""
new_journey_load = """      if (journey == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildShimmerBox(context, double.infinity, 80, radius: 12),
        );
      }"""
content = content.replace(old_journey_load, new_journey_load)

old_story_load = """      if (story == null) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }"""
new_story_load = """      if (story == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildShimmerBox(context, double.infinity, 160, radius: 12),
        );
      }"""
content = content.replace(old_story_load, new_story_load)

# Update _buildSharedCard image loading
old_card_image = """          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),"""
new_card_image = """          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildShimmerBox(context, double.infinity, 120),
                errorWidget: (context, url, error) => const SizedBox(
                  height: 120,
                  child: Center(child: Icon(Icons.error_outline)),
                ),
              ),
            ),"""
content = content.replace(old_card_image, new_card_image)


# Update _buildSharedProfileCard loading state
old_profile_load = """        loading: () => const Center(child: CircularProgressIndicator()),"""
new_profile_load = """        loading: () => _buildShimmerBox(context, double.infinity, 60, radius: 12),"""
content = content.replace(old_profile_load, new_profile_load)


with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
