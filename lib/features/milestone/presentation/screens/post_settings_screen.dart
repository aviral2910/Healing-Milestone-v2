import 'package:cached_network_image/cached_network_image.dart';

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
import 'dart:async';
import '../../../../features/home/presentation/providers/home_tab_provider.dart';

import '../../../../features/posts/data/hashtag_repository.dart';
import '../../../../features/auth/data/repository_providers.dart';

import '../providers/drafts_provider.dart';

part 'post_settings_hashtags.dart';
part 'post_settings_user_tagging.dart';
part 'post_settings_options.dart';

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
          content: Text(
            'A title is mandatory for your story.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
            (ref.read(postCreationControllerProvider).imagePath ?? "")
                .isNotEmpty) {
          await storage.deleteImageFromUrl(
            (ref.read(postCreationControllerProvider).imagePath ?? ""),
          );
        }
        final file = File(_selectedImage!.path);
        final ext = file.path.split('.').last;
        final imagePath = 'stories/${user.userId}/${const Uuid().v4()}.$ext';
        imageUrl = await storage.uploadImage(imagePath, file);
      } else if (_removeExistingImage) {
        if (ref.read(postCreationControllerProvider).isEditing &&
            (ref.read(postCreationControllerProvider).imagePath ?? "")
                .isNotEmpty) {
          await ref
              .read(storageRepositoryProvider)
              .deleteImageFromUrl(
                (ref.read(postCreationControllerProvider).imagePath ?? ""),
              );
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
      final Iterable<RegExpMatch> matches = hashtagRegExp.allMatches(
        contentText,
      );
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

      int wordCount = contentText.isEmpty
          ? 0
          : contentText.split(RegExp(r'\s+')).length;
      int calculatedReadingTime = (wordCount / 200).ceil();
      if (calculatedReadingTime < 1) calculatedReadingTime = 1;

      final story = StoryModel(
        storyId:
            ref.read(postCreationControllerProvider).originalStoryId ??
            const Uuid().v4(),
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
        taggedUsers: _selectedUsers,
      );

      if (ref.read(postCreationControllerProvider).isEditing) {
        await ref.read(storyRepositoryProvider).updateStory(story);
        ref.invalidate(storyByIdProvider(story.storyId));
      } else {
        await ref.read(storyRepositoryProvider).createStory(story);
        final updatedUser = user.copyWith(
          ownStories: [...user.ownStories, story.storyId],
        );
        await ref.read(authProvider.notifier).updateProfile(updatedUser);
      }

      // Refresh the feeds in the background to speed up UI
      ref.read(paginatedStoriesProvider.notifier).refresh();
      ref.invalidate(userStoriesProvider(user.userId));
      if (ref.read(postCreationControllerProvider).draftId != null) {
        ref
            .read(draftsProvider.notifier)
            .deleteDraft(ref.read(postCreationControllerProvider).draftId!);
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
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Pop both PostSettingsScreen and PostManualScreen to return to where we started (usually Home)
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
        
        // Switch the Bottom Navigation Bar to the Profile (Vault) tab!
        ref.read(homeTabProvider.notifier).state = 4;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to publish: $e',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
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
          .where(
            (tag) => tag.startsWith(cleanQuery) && !_selectedTags.contains(tag),
          )
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
    final cleanTag = tag.toLowerCase().trim().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
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
        final results = await ref
            .read(userRepositoryProvider)
            .searchUsers(cleanQuery);
        if (mounted) {
          final currentUser = ref.read(currentUserProvider);
          setState(() {
            _userSuggestions = results
                .where(
                  (u) =>
                      u.userId != currentUser?.userId &&
                      !_selectedUsers.any(
                        (selected) => selected.userId == u.userId,
                      ),
                )
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
    final bool isProOrOrg =
        user.role == UserRole.healthcareProfessional ||
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
          ref.read(postCreationControllerProvider).isEditing
              ? 'Edit Story'
              : 'Create a Post',
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
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
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isUploading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        ref.read(postCreationControllerProvider).isEditing
                            ? 'Save Changes'
                            : 'Publish',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
                height:
                    (_selectedImage == null &&
                        ((ref
                                    .read(postCreationControllerProvider)
                                    .imagePath
                                    ?.isEmpty ??
                                true) ??
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
                            Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                            BlendMode.darken,
                          ),
                        )
                      : (ref.read(postCreationControllerProvider).isEditing &&
                            (ref
                                        .read(postCreationControllerProvider)
                                        .imagePath ??
                                    "")
                                .isNotEmpty &&
                            (ref
                                        .read(postCreationControllerProvider)
                                        .imagePath ??
                                    "")
                                .startsWith('http') &&
                            !_removeExistingImage)
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            (ref
                                    .read(postCreationControllerProvider)
                                    .imagePath ??
                                ""), maxHeight: 200),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                            BlendMode.darken,
                          ),
                        )
                      : null,
                  border:
                      (_selectedImage == null &&
                          ((ref
                                      .read(postCreationControllerProvider)
                                      .imagePath
                                      ?.isEmpty ??
                                  true) ??
                              true || _removeExistingImage))
                      ? Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 1.5,
                        )
                      : null,
                ),
                child:
                    (_selectedImage == null &&
                        ((ref
                                    .read(postCreationControllerProvider)
                                    .imagePath
                                    ?.isEmpty ??
                                true) ??
                            true || _removeExistingImage))
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: theme.primaryColor,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add Cover Image',
                            style: TextStyle(
                              color:
                                  (Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color ??
                                  Colors.grey),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          Positioned(
                            top: 12,
                            right: 12,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.54),
                              ),
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
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.54),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Change Cover',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

                        _buildHashtagsSection(context, theme),
            const SizedBox(height: 16),
                        _buildUserTaggingSection(context, theme),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
                        _buildSettingsCard(context, theme, isProOrOrg, allowedTypes),
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
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
