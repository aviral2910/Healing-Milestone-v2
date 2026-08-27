import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

old_image = """              if (msg.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
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

new_image = """              if (msg.imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: msg.isViewOnce
                      ? _buildViewOnceImage(context, ref, msg, isMe)
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
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


# Now add the _buildViewOnceImage method to _MessageBubble
helper = """  Widget _buildViewOnceImage(BuildContext context, WidgetRef ref, ChatMessage msg, bool isMe) {
    if (msg.isViewed) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_red_eye_outlined, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text('Opened', style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
          ],
        ),
      );
    }

    if (isMe) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.timer_rounded, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text('Photo Sent', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
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
        )));
        
        // Once popped, mark as viewed!
        // wait, we need the roomId. We don't have roomId in _MessageBubble easily.
        // Actually, we do if we pass it, or we can just access it.
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.timer_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Tap to View Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }"""

# Inject before _buildShimmerBox
content = content.replace("  Widget _buildShimmerBox", helper + "\n\n  Widget _buildShimmerBox")

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
