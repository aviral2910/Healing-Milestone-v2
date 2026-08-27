import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

old_image = """              if (msg.imageUrl != null)
                Padding("""

new_image = """              if (msg.imageUrl != null || msg.isViewOnce)
                Padding("""

content = content.replace(old_image, new_image)

# Wait, if msg.imageUrl is null, the CachedNetworkImage will throw if it's NOT a view once image.
# But if it IS a view once image, it will call _buildViewOnceImage, which handles null safely if isViewed is true.
# Let's make sure _buildViewOnceImage safely handles null imageUrl when tapped.
old_tap = """      onTap: () async {
        // View the photo
        await Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 4)]),
          ),
          body: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            clipBehavior: Clip.none,
            child: Center(
              child: CachedNetworkImage(imageUrl: msg.imageUrl!),
            ),
          ),
        )));"""

new_tap = """      onTap: () async {
        if (msg.imageUrl == null) return;
        // View the photo
        await Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 4)]),
          ),
          body: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            clipBehavior: Clip.none,
            child: Center(
              child: CachedNetworkImage(imageUrl: msg.imageUrl!),
            ),
          ),
        )));"""

content = content.replace(old_tap, new_tap)

# Also fix the GestureDetector for normal images in case it gets here somehow
old_normal = """                      : GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                              backgroundColor: Colors.black,"""

new_normal = """                      : GestureDetector(
                          onTap: () {
                            if (msg.imageUrl == null) return;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                              backgroundColor: Colors.black,"""
content = content.replace(old_normal, new_normal)

old_normal_img = """                            child: CachedNetworkImage(
                              imageUrl: msg.imageUrl!,"""
new_normal_img = """                            child: CachedNetworkImage(
                              imageUrl: msg.imageUrl ?? '',"""
content = content.replace(old_normal_img, new_normal_img)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
