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
  String _selectedTemplate = 'minimalist';

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitPost() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A title is mandatory for your story.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    // TODO: Connect to Riverpod provider to construct Milestone object and upload to Firestore
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: theme.textTheme.headlineLarge?.copyWith(fontSize: 32),
              decoration: InputDecoration(
                hintText: 'Title your journey',
                hintStyle: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 32,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18, height: 1.8),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Share your experience, feelings, and milestones...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: const Border(top: BorderSide(color: Color(0xFF2A2A2A))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.photo_outlined),
                onPressed: () => MediaUploadBottomSheet.show(context),
                tooltip: 'Add Media Attachment',
                color: theme.textTheme.bodySmall?.color,
              ),
              IconButton(
                icon: const Icon(Icons.local_hospital_outlined),
                onPressed: () {
                  // TODO: Add Doctor/Hospital tagging dropdown here
                },
                tooltip: 'Tag Medical Provider',
                color: theme.textTheme.bodySmall?.color,
              ),
              const Spacer(),
              Row(
                children: [
                  Text('Anonymous', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                  Switch(
                    value: _isAnonymous,
                    activeColor: theme.colorScheme.secondary,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
