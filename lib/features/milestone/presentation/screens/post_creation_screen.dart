import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../widgets/media_upload_bottom_sheet.dart';

class PostCreationScreen extends StatefulHookConsumerWidget {
  const PostCreationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends ConsumerState<PostCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isAnonymous = false;
  String _selectedTemplate = 'glassmorphism';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitPost() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A title is mandatory for your story.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    // TODO: Connect to Riverpod provider to construct Milestone object and upload to Firestore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep Charcoal
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text('Share Your Milestone', style: TextStyle(color: Color(0xFFE0E0E0))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title *',
                labelStyle: TextStyle(color: Color(0xFFA0A0A0)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2C2C2C))),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Share your healing journey...',
                hintStyle: TextStyle(color: Color(0xFFA0A0A0)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2C2C2C))),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Post Anonymously', style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 16)),
                Switch(
                  value: _isAnonymous,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // TODO: Add MediaUploadBottomSheet trigger button here
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                icon: const Icon(Icons.attach_file),
                label: const Text('Add Media Attachment'),
                onPressed: () {
                  MediaUploadBottomSheet.show(context);
                },
              ),
            ),
            const SizedBox(height: 20),
            // TODO: Add Doctor/Hospital tagging dropdown here
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submitPost,
                child: const Text('Submit for Verification', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
