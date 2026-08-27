import re

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'r') as f:
    content = f.read()

# Replace the entire _pickAndSendImage function
pattern = r"  Future<void> _pickAndSendImage\(\) async \{.*?\n  \}"
replacement = """  Future<void> _pickAndSendImage() async {
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

content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open('lib/features/chat/presentation/screens/chat_room_screen.dart', 'w') as f:
    f.write(content)
