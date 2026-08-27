import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

old_pick = """  Future<void> _pickAndSendImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compress image natively
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (pickedFile == null) return;

    // Ask user if they want to send as View Once
    bool? isViewOnce = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Send Image", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.send_rounded, size: 28),
                title: const Text("Send Normally"),
                subtitle: const Text("Image stays in the chat permanently"),
                onTap: () => Navigator.pop(ctx, false),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timer_rounded, size: 28, color: Colors.blue),
                title: const Text("Send as View Once", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                subtitle: const Text("Image disappears after they view it"),
                onTap: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        ),
      ),
    );

    if (isViewOnce == null) return; // User cancelled"""

new_pick = """  Future<void> _pickAndSendImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compress image natively
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (pickedFile == null) return;

    // Show Full-Screen Image Preview with View Once toggle
    bool? isViewOnce = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _ImagePreviewScreen(imageFile: File(pickedFile.path)),
      ),
    );

    if (isViewOnce == null) return; // User cancelled"""

content = content.replace(old_pick, new_pick)


# Now append the _ImagePreviewScreen class at the bottom of the file
preview_class = """
class _ImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  const _ImagePreviewScreen({required this.imageFile});

  @override
  State<_ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<_ImagePreviewScreen> {
  bool isViewOnce = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black45, blurRadius: 4)]),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Image Preview
          Positioned.fill(
            child: InteractiveViewer(
              child: Center(
                child: Image.file(widget.imageFile, fit: BoxFit.contain),
              ),
            ),
          ),
          
          // Bottom Controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // View Once Toggle Button
                  InkWell(
                    onTap: () {
                      setState(() {
                        isViewOnce = !isViewOnce;
                      });
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isViewOnce ? Colors.blue : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: isViewOnce ? Colors.blue : Colors.white54),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isViewOnce ? Icons.timer_rounded : Icons.timer_outlined, 
                            color: Colors.white, 
                            size: 20
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isViewOnce ? 'View Once On' : 'View Once Off',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Send Button
                  FloatingActionButton(
                    onPressed: () => Navigator.pop(context, isViewOnce),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
"""

content += preview_class

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
