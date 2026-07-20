import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/story_model.dart';
import '../../../../features/auth/data/auth_provider.dart';
import '../../../../features/posts/data/story_providers.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../core/utils/uat_dummy_data.dart';
import '../../../../features/posts/data/hashtag_repository.dart';
import '../../../../features/auth/data/repository_providers.dart';
import '../../../../main.dart';

class PostCreationScreen extends StatefulHookConsumerWidget {
  final StoryModel? existingStory;

  const PostCreationScreen({Key? key, this.existingStory}) : super(key: key);

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
  bool _removeExistingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingStory != null) {
      final story = widget.existingStory!;
      _titleController.text = story.heading;
      _contentController.text = story.description;
      _selectedTags = List.from(story.hashtagsList);
      _selectedType = story.type;
      _isAnonymous = !story.displayAuthorName;
      // We can't synchronously load the users for taggedPeople here easily without an async fetch,
      // but we could just pre-populate the UI with the existing IDs or leave it for later.
      // For now, we will leave tagged users as is or fetch them if needed.
      // To properly handle tagged users, we should ideally fetch them from the repo.
    }
  }

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
        if (widget.existingStory != null && widget.existingStory!.mainImage.isNotEmpty) {
          await storage.deleteImageFromUrl(widget.existingStory!.mainImage);
        }
        final file = File(_selectedImage!.path);
        final ext = file.path.split('.').last;
        final imagePath = 'stories/${user.userId}/${const Uuid().v4()}.$ext';
        imageUrl = await storage.uploadImage(imagePath, file);
      } else if (_removeExistingImage) {
        if (widget.existingStory != null && widget.existingStory!.mainImage.isNotEmpty) {
          await ref.read(storageRepositoryProvider).deleteImageFromUrl(widget.existingStory!.mainImage);
        }
        imageUrl = '';
      } else {
        imageUrl = widget.existingStory?.mainImage ?? '';
      }

      final contentText = _contentController.text.trim();
      final tagText = _tagController.text.trim();
      
      final Set<String> finalTags = Set.from(_selectedTags);
      
      // Extract from description
      final RegExp hashtagRegExp = RegExp(r'#([a-zA-Z0-9_]+)');
      final Iterable<RegExpMatch> matches = hashtagRegExp.allMatches(contentText);
      for (final match in matches) {
        final tag = match.group(1)?.toLowerCase().trim();
        if (tag != null && tag.isNotEmpty) {
          finalTags.add(tag);
        }
      }
      
      // Extract unsubmitted tags from input field
      if (tagText.isNotEmpty) {
        final remainingTags = tagText.split(RegExp(r'[\s,]+'));
        for (var tag in remainingTags) {
          tag = tag.replaceAll('#', '').toLowerCase().trim();
          if (tag.isNotEmpty) {
            finalTags.add(tag);
          }
        }
      }

      final story = StoryModel(
        storyId: widget.existingStory?.storyId ?? const Uuid().v4(),
        heading: _titleController.text.trim(),
        description: contentText,
        publishedAt: widget.existingStory?.publishedAt ?? DateTime.now(),
        shortDescription: contentText.length > 50
            ? contentText.substring(0, 50)
            : contentText,
        mainImage: imageUrl,
        authorId: user.userId,
        qrId: widget.existingStory?.qrId ?? '',
        readingTime: widget.existingStory?.readingTime ?? 3,
        verifierId: widget.existingStory?.verifierId ?? '',
        displayAuthorName: !_isAnonymous,
        authorRole: user.role,
        type: _selectedType,
        hashtagsList: finalTags.toList(),
        taggedPeople: _selectedUsers.map((u) => u.userId).toList(),
      );

      if (widget.existingStory != null) {
        await ref.read(storyRepositoryProvider).updateStory(story);
      } else {
        await ref.read(storyRepositoryProvider).createStory(story);
        final updatedUser = user.copyWith(
          ownStories: [...user.ownStories, story.storyId],
        );
        await ref.read(authProvider.notifier).updateProfile(updatedUser);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingStory != null ? 'Post updated successfully!' : 'Post published successfully!',
                style: const TextStyle(
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
        final results =
            await ref.read(userRepositoryProvider).searchUsers(cleanQuery);
        if (mounted) {
          final currentUser = ref.read(currentUserProvider);
          setState(() {
            _userSuggestions = results
                .where((u) =>
                    u.userId != currentUser?.userId &&
                    !_selectedUsers
                        .any((selected) => selected.userId == u.userId))
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
          if (ref.watch(uatModeProvider))
            IconButton(
              icon: Icon(Icons.auto_fix_high, color: Theme.of(context).primaryColor),
              tooltip: 'Populate Dummy Post',
              onPressed: () {
                final selected = UatDummyData.getRandomPost();
                
                setState(() {
                  _titleController.text = selected['title'] as String;
                  _contentController.text = selected['content'] as String;
                  _selectedTags = List<String>.from(selected['tags'] as List);
                });
              },
            ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
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
                  foregroundColor: theme.colorScheme.onPrimary,
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: _isUploading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary, strokeWidth: 2))
                    : Text(widget.existingStory != null ? 'Save Changes' : 'Publish',
                        style: const TextStyle(
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
                height: (_selectedImage == null && (widget.existingStory?.mainImage.isEmpty ?? true || _removeExistingImage)) ? 180 : 250,
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
                      : (widget.existingStory != null && widget.existingStory!.mainImage.isNotEmpty && !_removeExistingImage)
                          ? DecorationImage(
                              image: NetworkImage(widget.existingStory!.mainImage),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withValues(alpha: 0.3),
                                  BlendMode.darken),
                            )
                          : null,
                  border: (_selectedImage == null && (widget.existingStory?.mainImage.isEmpty ?? true || _removeExistingImage))
                      ? Border.all(color: const Color(0xFF333333), width: 1.5)
                      : null,
                ),
                child: (_selectedImage == null && (widget.existingStory?.mainImage.isEmpty ?? true || _removeExistingImage))
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
                                  _removeExistingImage = true;
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Outfit'),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Title your post',
                      hintStyle: TextStyle(
                        fontSize: 24,
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
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TextField(
                      controller: _tagController,
                      style: const TextStyle(color: Colors.white),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                        _LowerCaseTextFormatter(),
                      ],
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
                        border: Border.all(color: Theme.of(context).dividerColor),
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
                              _selectedUsers.removeWhere(
                                  (selected) => selected.userId == u.userId);
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
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TextField(
                      controller: _userSearchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search people to tag...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.white54, size: 20),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 40),
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
                        border: Border.all(color: Theme.of(context).dividerColor),
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
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            subtitle: u.username != null
                                ? Text('@${u.username}',
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 12))
                                : null,
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
                border: Border.all(color: Theme.of(context).dividerColor),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Theme.of(context).dividerColor),
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

class _LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
