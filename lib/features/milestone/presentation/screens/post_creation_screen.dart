import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/story_model.dart';
import '../../../../features/auth/data/auth_provider.dart';
import '../../../../features/posts/data/story_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
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
  StoryType _selectedType = StoryType.story;

  XFile? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
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

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final storage = ref.read(storageRepositoryProvider);
        final file = File(_selectedImage!.path);
        final ext = file.path.split('.').last;
        final imagePath = 'stories/${user.userId}/${const Uuid().v4()}.$ext';
        imageUrl = await storage.uploadImage(imagePath, file);
      }

      final story = StoryModel(
        storyId: const Uuid().v4(),
        heading: _titleController.text.trim(),
        description: _contentController.text.trim(),
        publishedAt: DateTime.now(),
        shortDescription: _contentController.text.trim().length > 50 ? _contentController.text.trim().substring(0, 50) : _contentController.text.trim(),
        mainImage: imageUrl ?? '',
        authorId: user.userId,
        qrId: '',
        readingTime: 3,
        verifierId: '',
        displayAuthorName: !_isAnonymous,
        authorRole: user.role,
        type: _selectedType,
      );

      await ref.read(storyRepositoryProvider).createStory(story);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post published successfully!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish: $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final bool isProOrOrg = user.role == UserRole.healthcareProfessional || user.role == UserRole.organization;
    
    List<StoryType> allowedTypes = [StoryType.story];
    if (isProOrOrg) {
      allowedTypes.addAll([StoryType.finding, StoryType.awareness]);
    }
    
    if (!allowedTypes.contains(_selectedType)) {
      _selectedType = StoryType.story;
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, const Color(0xFFFFDF73)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: const Color(0xFF1A1A1A),
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: _isUploading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF1A1A1A), strokeWidth: 2))
                    : const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker Header
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: _selectedImage == null ? 180 : 250,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(File(_selectedImage!.path)),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                        )
                      : null,
                  border: _selectedImage == null ? Border.all(color: const Color(0xFF333333), width: 1.5) : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, color: theme.primaryColor, size: 48),
                          const SizedBox(height: 12),
                          const Text('Add Cover Image', style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      )
                    : Stack(
                        children: [
                          Positioned(
                            top: 12,
                            right: 12,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              style: IconButton.styleFrom(backgroundColor: Colors.black54),
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit, color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text('Change Cover', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            
            // Text Inputs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                    decoration: InputDecoration(
                      hintText: 'Title your post',
                      hintStyle: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      border: InputBorder.none,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    style: const TextStyle(fontSize: 18, height: 1.6, color: Color(0xFFE0E0E0)),
                    maxLines: null,
                    minLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Share your experience, feelings, and milestones...',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            
            // Settings Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Post Settings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                  const SizedBox(height: 20),
                  const Text('POST TYPE', style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: allowedTypes.map((type) {
                      final isSelected = _selectedType == type;
                      return ChoiceChip(
                        label: Text(
                          type.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFF1A1A1A) : Colors.white70,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: theme.primaryColor,
                        backgroundColor: const Color(0xFF222222),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.transparent)),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedType = type);
                        },
                      );
                    }).toList(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Color(0xFF2A2A2A)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFF222222), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.visibility_off_outlined, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Post Anonymously', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text('Hide your name and profile picture', style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _isAnonymous,
                        activeColor: theme.primaryColor,
                        onChanged: (value) => setState(() => _isAnonymous = value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
