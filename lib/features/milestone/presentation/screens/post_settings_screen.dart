import '../providers/post_creation_state.dart';
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

import '../../../../core/models/draft_model.dart';
import '../providers/drafts_provider.dart';
import '../providers/draft_settings_provider.dart';

class PostSettingsScreen extends StatefulHookConsumerWidget {
  const PostSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PostSettingsScreen> createState() => _PostSettingsScreenState();
}

class _PostSettingsScreenState extends ConsumerState<PostSettingsScreen> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(postCreationControllerProvider);
      setState(() {
        _selectedTags = List.from(state.tags);
        _selectedUsers = List.from(state.selectedUsers);
        _isAnonymous = state.isAnonymous;
        _selectedType = state.type;
        if (state.imagePath != null && state.imagePath!.isNotEmpty) {
           // We might not have a local XFile, but we can rely on state.imagePath for network URLs
        }
      });
    });
  }

  @override
  void dispose() {
    _tagController.dispose();
    _userSearchController.dispose();
    _debounce?.cancel();
    _userDebounce?.cancel();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final postState = ref.read(postCreationControllerProvider);
    if (ref.read(postCreationControllerProvider).title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A title is mandatory for your story.',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold)),
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
        if (ref.read(postCreationControllerProvider).isEditing &&
            (ref.read(postCreationControllerProvider).imagePath ?? "").isNotEmpty) {
          await storage.deleteImageFromUrl((ref.read(postCreationControllerProvider).imagePath ?? ""));
        }
        final file = File(_selectedImage!.path);
        final ext = file.path.split('.').last;
        final imagePath = 'stories/${user.userId}/${const Uuid().v4()}.$ext';
        imageUrl = await storage.uploadImage(imagePath, file);
      } else if (_removeExistingImage) {
        if (ref.read(postCreationControllerProvider).isEditing &&
            (ref.read(postCreationControllerProvider).imagePath ?? "").isNotEmpty) {
          await ref
              .read(storageRepositoryProvider)
              .deleteImageFromUrl((ref.read(postCreationControllerProvider).imagePath ?? ""));
        }
        imageUrl = '';
      } else {
        imageUrl = ref.read(postCreationControllerProvider).imagePath ?? '';
      }

      final contentText = ref.read(postCreationControllerProvider).content;
      final tagText = _tagController.text.trim();

      final Set<String> finalTags = Set.from(_selectedTags);

      // Extract from description
      final RegExp hashtagRegExp = RegExp(r'#([a-zA-Z0-9_]+)');
      final Iterable<RegExpMatch> matches =
          hashtagRegExp.allMatches(contentText);
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

      int wordCount =
          contentText.isEmpty ? 0 : contentText.split(RegExp(r'\s+')).length;
      int calculatedReadingTime = (wordCount / 200).ceil();
      if (calculatedReadingTime < 1) calculatedReadingTime = 1;

      final story = StoryModel(
        storyId: ref.read(postCreationControllerProvider).originalStoryId ?? const Uuid().v4(),
        heading: ref.read(postCreationControllerProvider).title,
        description: contentText,
        publishedAt: DateTime.now() /* TODO existing publish date */,
        shortDescription: contentText.length > 50
            ? contentText.substring(0, 50)
            : contentText,
        mainImage: imageUrl,
        authorId: user.userId,
        qrId: '',
        readingTime: calculatedReadingTime,
        verifierId: '',
        displayAuthorName: !_isAnonymous,
        authorRole: user.role,
        type: _selectedType,
        hashtagsList: finalTags.toList(),
        taggedPeople: _selectedUsers.map((u) => u.userId).toList(),
      );

      if (ref.read(postCreationControllerProvider).isEditing) {
        await ref.read(storyRepositoryProvider).updateStory(story);
      } else {
        await ref.read(storyRepositoryProvider).createStory(story);
        final updatedUser = user.copyWith(
          ownStories: [...user.ownStories, story.storyId],
        );
        await ref.read(authProvider.notifier).updateProfile(updatedUser);
      }
      if (ref.read(postCreationControllerProvider).draftId != null) {
        await ref.read(draftsProvider.notifier).deleteDraft(ref.read(postCreationControllerProvider).draftId!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                ref.read(postCreationControllerProvider).isEditing
                    ? 'Post updated successfully!'
                    : 'Post published successfully!',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold)),
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
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          ref.read(postCreationControllerProvider).isEditing ? 'Edit Story' : 'Create a Post',
        ),
        centerTitle: true,
        leading: IconButton(
          icon:
              Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save Draft',
            onPressed: () async {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Draft saved manually.'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
          ),
          if (ref.watch(uatModeProvider))
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: PopupMenuButton<Map<String, dynamic>>(
                icon: Icon(Icons.auto_fix_high,
                    color: theme.colorScheme.primary.computeLuminance() > 0.25
                        ? Colors.black
                        : Colors.white),
                tooltip: 'Populate Dummy Post',
                onSelected: (selected) {
                  setState(() {
                    _selectedTags = List<String>.from(selected['tags'] as List);
                  });
                },
                itemBuilder: (BuildContext context) {
                  return UatDummyData.getAllPosts().map((post) {
                    final content = post['content'] as String;
                    final wordCount = content.isEmpty
                        ? 0
                        : content.split(RegExp(r'\s+')).length;
                    var time = (wordCount / 200).ceil();
                    if (time < 1) time = 1;

                    return PopupMenuItem<Map<String, dynamic>>(
                      value: post,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            post['title'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined,
                                  size: 12,
                                  color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                '$time min read',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.scaffoldBackgroundColor.withValues(alpha: 0.2),
              theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
              // theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor:
                      theme.colorScheme.primary.computeLuminance() > 0.25
                          ? Colors.black
                          : Colors.white,
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: _isUploading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : Text(
                        ref.read(postCreationControllerProvider).isEditing
                            ? 'Save Changes'
                            : 'Publish',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ),
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
                height: (_selectedImage == null &&
                        ((ref.read(postCreationControllerProvider).imagePath?.isEmpty ?? true) ??
                            true || _removeExistingImage))
                    ? 180
                    : 250,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(File(_selectedImage!.path)),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.3),
                              BlendMode.darken),
                        )
                      : (ref.read(postCreationControllerProvider).isEditing &&
                              (ref.read(postCreationControllerProvider).imagePath ?? "").isNotEmpty &&
                              !_removeExistingImage)
                          ? DecorationImage(
                              image:
                                  NetworkImage((ref.read(postCreationControllerProvider).imagePath ?? "")),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.3),
                                  BlendMode.darken),
                            )
                          : null,
                  border: (_selectedImage == null &&
                          ((ref.read(postCreationControllerProvider).imagePath?.isEmpty ?? true) ??
                              true || _removeExistingImage))
                      ? Border.all(
                          color: Theme.of(context).dividerColor, width: 1.5)
                      : null,
                ),
                child: (_selectedImage == null &&
                        ((ref.read(postCreationControllerProvider).imagePath?.isEmpty ?? true) ??
                            true || _removeExistingImage))
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: theme.primaryColor, size: 48),
                          const SizedBox(height: 12),
                          Text('Add Cover Image',
                              style: TextStyle(
                                  color: (Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color ??
                                      Colors.grey),
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
                              icon: Icon(Icons.close,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.54)),
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.54),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      size: 14),
                                  SizedBox(width: 6),
                                  Text('Change Cover',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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



            // Hashtags Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tags',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(height: 12),
                  // Selected Tags Chips
                  if (_selectedTags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _selectedTags.map((tag) {
                        return Chip(
                          label: Text('#$tag',
                              style: TextStyle(
                                  color: theme.colorScheme.primary
                                              .computeLuminance() >
                                          0.25
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          backgroundColor: theme.primaryColor,
                          deleteIconColor:
                              theme.colorScheme.primary.computeLuminance() >
                                      0.25
                                  ? Colors.black
                                  : Colors.white,
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TextField(
                      controller: _tagController,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                        _LowerCaseTextFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Add a tag (e.g. cancerfree)',
                        hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3)),
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
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        children: _suggestions.map((suggestion) {
                          return ListTile(
                            dense: true,
                            title: Text('#$suggestion',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
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
                  Text('Tag People & Medical Professionals',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          )),
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
                              style: TextStyle(
                                  color: theme.colorScheme.primary
                                              .computeLuminance() >
                                          0.25
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          backgroundColor: theme.primaryColor,
                          deleteIconColor:
                              theme.colorScheme.primary.computeLuminance() >
                                      0.25
                                  ? Colors.black
                                  : Colors.white,
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
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TextField(
                      controller: _userSearchController,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search people to tag...',
                        hintStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3)),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.54),
                            size: 20),
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
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
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
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Post Settings',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(height: 20),
                  Text('POST TYPE',
                      style: TextStyle(
                          color:
                              (Theme.of(context).textTheme.bodySmall?.color ??
                                  Colors.grey),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.1),
                      highlightColor: Colors.transparent,
                    ),
                    child: Wrap(
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
                                  ? Colors.black
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: theme.primaryColor,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.08),
                          surfaceTintColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side:
                                  const BorderSide(color: Colors.transparent)),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedType = type);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Theme.of(context).dividerColor),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.visibility_off_outlined,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Post Anonymously',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 4),
                                  Text('Hide your name and profile picture',
                                      style: TextStyle(
                                          color: (Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color ??
                                              Colors.grey),
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
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
            const SizedBox(height: 120),
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
