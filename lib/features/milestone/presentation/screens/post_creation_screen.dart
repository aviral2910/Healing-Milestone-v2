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
import 'dart:async';
import '../../../../features/posts/data/hashtag_repository.dart';
import '../../../../features/auth/data/repository_providers.dart';

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

  final TextEditingController _tagController = TextEditingController();
  List<String> _selectedTags = [];
  List<String> _suggestions = [];
  Timer? _debounce;
  bool _isSearchingTags = false;

  final TextEditingController _userSearchController = TextEditingController();
  List<UserModel> _selectedUsers = [];
  List<UserModel> _userSuggestions = [];
  Timer? _userDebounce;
  bool _isSearchingUsers = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    _userSearchController.dispose();
    _debounce?.cancel();
    _userDebounce?.cancel();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A title is mandatory for your story.',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        shortDescription: _contentController.text.trim().length > 50
            ? _contentController.text.trim().substring(0, 50)
            : _contentController.text.trim(),
        mainImage: imageUrl ?? '',
        authorId: user.userId,
        qrId: '',
        readingTime: 3,
        verifierId: '',
        displayAuthorName: !_isAnonymous,
        authorRole: user.role,
        type: _selectedType,
        hashtagsList: _selectedTags,
        taggedPeople: _selectedUsers.map((u) => u.userId).toList(),
      );

      await ref.read(storyRepositoryProvider).createStory(story);

      final updatedUser = user.copyWith(
        ownStories: [...user.ownStories, story.storyId],
      );
      await ref.read(authProvider.notifier).updateProfile(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post published successfully!',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
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
            content: Text('Failed to publish: $e',
                style: const TextStyle(color: Colors.white)),
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
    // Use imageQuality to compress the image and maxWidth/maxHeight to limit the resolution
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _onTagChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final cleanQuery = query.toLowerCase().trim();

    if (cleanQuery.isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearchingTags = false;
      });
      return;
    }

    // 1. Check local cache (trending tags) first
    final trendingAsync = ref.read(trendingHashtagsProvider);
    List<String> localMatches = [];
    if (trendingAsync.hasValue && trendingAsync.value != null) {
      localMatches = trendingAsync.value!
          .where((tag) =>
              tag.startsWith(cleanQuery) && !_selectedTags.contains(tag))
          .take(4)
          .toList();
    }

    if (localMatches.isNotEmpty) {
      setState(() {
        _suggestions = localMatches;
        _isSearchingTags = false;
      });
      return;
    }

    setState(() {
      _isSearchingTags = true;
    });

    // 2. Server fallback with debounce
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await ref
            .read(hashtagRepositoryProvider)
            .searchHashtags(cleanQuery);
        if (mounted) {
          setState(() {
            _suggestions = results
                .where((tag) => !_selectedTags.contains(tag))
                .take(4)
                .toList();
            _isSearchingTags = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearchingTags = false;
          });
        }
      }
    });
  }

  void _addTag(String tag) {
    final cleanTag =
        tag.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (cleanTag.isNotEmpty && !_selectedTags.contains(cleanTag)) {
      setState(() {
        _selectedTags.add(cleanTag);
        _tagController.clear();
        _suggestions = [];
      });
    }
  }

  void _onUserSearchChanged(String query) {
    if (_userDebounce?.isActive ?? false) _userDebounce!.cancel();

    final cleanQuery = query.toLowerCase().trim();

    if (cleanQuery.isEmpty) {
      setState(() {
        _userSuggestions = [];
        _isSearchingUsers = false;
      });
      return;
    }

    setState(() {
      _isSearchingUsers = true;
    });

    _userDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await ref.read(userRepositoryProvider).searchUsers(cleanQuery);
        if (mounted) {
          final currentUser = ref.read(currentUserProvider);
          setState(() {
            _userSuggestions = results
                .where((u) => u.userId != currentUser?.userId && !_selectedUsers.any((selected) => selected.userId == u.userId))
                .take(4)
                .toList();
            _isSearchingUsers = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearchingUsers = false;
          });
        }
      }
    });
  }

  void _addUser(UserModel user) {
    if (!_selectedUsers.any((u) => u.userId == user.userId)) {
      setState(() {
        _selectedUsers.add(user);
        _userSearchController.clear();
        _userSuggestions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final bool isProOrOrg = user.role == UserRole.healthcareProfessional ||
        user.role == UserRole.organization;

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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Color(0xFF1A1A1A), strokeWidth: 2))
                    : const Text('Publish',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
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
                          colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.3),
                              BlendMode.darken),
                        )
                      : null,
                  border: _selectedImage == null
                      ? Border.all(color: const Color(0xFF333333), width: 1.5)
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: theme.primaryColor, size: 48),
                          const SizedBox(height: 12),
                          const Text('Add Cover Image',
                              style: TextStyle(
                                  color: Color(0xFFA0A0A0),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )
                    : Stack(
                        children: [
                          Positioned(
                            top: 12,
                            right: 12,
                            child: IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit,
                                      color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text('Change Cover',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Outfit'),
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
                    style: const TextStyle(
                        fontSize: 18, height: 1.6, color: Color(0xFFE0E0E0)),
                    maxLines: null,
                    minLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Share your experience, feelings, and milestones...',
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

            const SizedBox(height: 16),

            // Hashtags Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tags',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit')),
                  const SizedBox(height: 12),
                  // Selected Tags Chips
                  if (_selectedTags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _selectedTags.map((tag) {
                        return Chip(
                          label: Text('#$tag',
                              style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          backgroundColor: theme.primaryColor,
                          deleteIconColor: const Color(0xFF1A1A1A),
                          onDeleted: () {
                            setState(() {
                              _selectedTags.remove(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Tag Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: TextField(
                      controller: _tagController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a tag (e.g. cancerfree)',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                        prefixText: '# ',
                        prefixStyle: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold),
                        suffixIcon: _isSearchingTags
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              )
                            : null,
                      ),
                      onChanged: _onTagChanged,
                      onSubmitted: _addTag,
                    ),
                  ),
                  // Suggestions Dropdown
                  if (_suggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: Column(
                        children: _suggestions.map((suggestion) {
                          return ListTile(
                            dense: true,
                            title: Text('#$suggestion',
                                style: const TextStyle(color: Colors.white)),
                            onTap: () {
                              _addTag(suggestion);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // User Tagging Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tag People & Medical Professionals',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit')),
                  const SizedBox(height: 12),
                  // Selected Users Chips
                  if (_selectedUsers.isNotEmpty) ...[
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _selectedUsers.map((u) {
                        return Chip(
                          avatar: CircleAvatar(
                            backgroundImage: NetworkImage(u.profilePicture ??
                                'https://api.dicebear.com/7.x/avataaars/png?seed=${u.userId}'),
                          ),
                          label: Text('@${u.username ?? u.displayName}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          backgroundColor: const Color(0xFF222222),
                          deleteIconColor: Colors.white70,
                          onDeleted: () {
                            setState(() {
                              _selectedUsers.removeWhere((selected) => selected.userId == u.userId);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // User Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: TextField(
                      controller: _userSearchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search people to tag...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                        prefixIconConstraints: const BoxConstraints(minWidth: 40),
                        suffixIcon: _isSearchingUsers
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              )
                            : null,
                      ),
                      onChanged: _onUserSearchChanged,
                    ),
                  ),
                  // User Suggestions Dropdown
                  if (_userSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: Column(
                        children: _userSuggestions.map((u) {
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(u.profilePicture ??
                                  'https://api.dicebear.com/7.x/avataaars/png?seed=${u.userId}'),
                            ),
                            title: Text(u.displayName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: u.username != null ? Text('@${u.username}', style: TextStyle(color: theme.primaryColor, fontSize: 12)) : null,
                            onTap: () {
                              _addUser(u);
                            },
                          );
                        }).toList(),
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
                  const Text('Post Settings',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit')),
                  const SizedBox(height: 20),
                  const Text('POST TYPE',
                      style: TextStyle(
                          color: Color(0xFFA0A0A0),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2)),
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
                            color: isSelected
                                ? const Color(0xFF1A1A1A)
                                : Colors.white70,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: theme.primaryColor,
                        backgroundColor: const Color(0xFF222222),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.transparent)),
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
                            decoration: BoxDecoration(
                                color: const Color(0xFF222222),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.visibility_off_outlined,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Post Anonymously',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text('Hide your name and profile picture',
                                  style: TextStyle(
                                      color: Color(0xFFA0A0A0), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _isAnonymous,
                        activeColor: theme.primaryColor,
                        onChanged: (value) =>
                            setState(() => _isAnonymous = value),
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
