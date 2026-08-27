import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

old_pick = """  Future<void> _pickAndSendImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null || user.userId == null) return;

    setState(() => _isSending = true);
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(
            roomId: widget.roomId,
            senderId: user.userId!,
            imageFile: File(pickedFile.path),
          );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }"""

new_pick = """  Future<void> _pickAndSendImage() async {
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

    if (isViewOnce == null) return; // User cancelled

    final user = ref.read(currentUserProvider);
    if (user == null || user.userId == null) return;

    setState(() => _isSending = true);
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(
            roomId: widget.roomId,
            senderId: user.userId!,
            imageFile: File(pickedFile.path),
            isViewOnce: isViewOnce,
          );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }"""

content = content.replace(old_pick, new_pick)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
