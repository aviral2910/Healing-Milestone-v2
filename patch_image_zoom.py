import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

old_viewer = """                      Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
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
                      )));"""

new_viewer = """                      Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
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

content = content.replace(old_viewer, new_viewer)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
