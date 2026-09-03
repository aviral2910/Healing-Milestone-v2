import 'package:cached_network_image/cached_network_image.dart';
import 'package:healing_milestones/features/posts/data/paginated_comments_provider.dart';
import '../providers/post_creation_state.dart';
import 'package:healing_milestones/core/router/app_routes.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:healing_milestones/shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_loader.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'immersive_reading_screen.dart';
import '../../../../core/models/media_attachment.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/presentation/widgets/user_badge.dart';
import '../../../../core/presentation/widgets/verified_story_badge.dart';
import '../../../posts/presentation/widgets/post_display_widget.dart';
import '../widgets/milestone_media_gallery.dart';
import '../../../accessibility/data/accessibility_providers.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../posts/data/story_providers.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../shared/widgets/interaction_section.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StoryDetailScreen extends HookConsumerWidget {
  final String milestoneId;

  const StoryDetailScreen({Key? key, required this.milestoneId})
    : super(key: key);

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyAsync = ref.watch(storyByIdProvider(milestoneId));
    // Removed currentUser watch
    final theme = Theme.of(context);
    final mainScrollController = useScrollController();

    // Text to Speech
    final flutterTts = useMemoized(() => FlutterTts());
    final isPlaying = useState(false);
    final playbackSpeed = useState<double>(1.0); // UI multiplier (1.0x = normal)
    final availableVoices = useState<List<Map<String, String>>>([]);
    final selectedVoice = useState<Map<String, String>?>(null);

    useEffect(() {
      // Fetch English voices for the Voice Bar
      flutterTts.getVoices.then((dynamic systemVoices) {
        try {
          if (systemVoices is List) {
            final List<Map<String, String>> engVoices = [];
            final Set<String> seenLocales = {}; // Take only 1 voice per accent to avoid broken variations
            
            final Map<String, String> localeNames = {
              'en-us': 'American',
              'en-gb': 'British',
              'en-in': 'Indian',
              'en-au': 'Australian',
              'en-za': 'South African',
              'en-ng': 'Nigerian',
              'en-ie': 'Irish',
              'en-ca': 'Canadian'
            };

            for (var v in systemVoices) {
              if (v is Map) {
                final locale = v["locale"]?.toString().replaceAll('_', '-') ?? "";
                final name = v["name"]?.toString() ?? "";
                final lowerLocale = locale.toLowerCase();
                
                if (lowerLocale.startsWith("en")) {
                  // Filter out "network" voices on Android which often fail to play
                  if (!name.toLowerCase().contains("network")) {
                     // Only take one working offline voice per region
                     if (!seenLocales.contains(lowerLocale)) {
                       seenLocales.add(lowerLocale);
                       
                       String friendlyName = localeNames[lowerLocale] ?? 'English ($locale)';
                       engVoices.add({
                         "name": name, 
                         "locale": locale,
                         "displayName": "$friendlyName Accent"
                       });
                     }
                  }
                }
              }
            }
            
            // Limit to max 5 distinct accents
            availableVoices.value = engVoices.take(5).toList(); 
          }
        } catch (e) {
          debugPrint("Failed to load voices: $e");
        }
      });

      // Configure TTS for cross-platform reliability
      flutterTts.setSharedInstance(true);
      flutterTts.awaitSpeakCompletion(false); // Force false to prevent native plugin hangs
      
      // Override iOS silent switch so audio plays even if phone is on vibrate
      flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
      );

      flutterTts.setCompletionHandler(() {
        isPlaying.value = false;
      });
      flutterTts.setCancelHandler(() {
        isPlaying.value = false;
      });
      flutterTts.setPauseHandler(() {
        isPlaying.value = false;
      });
      return () {
        flutterTts.stop();
      };
    }, const []);

    return storyAsync.when(
      loading: () => const Scaffold(body: Center(child: AppLoader())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error loading story: $error'))),
      data: (story) {
        if (story == null) {
          return const Scaffold(body: Center(child: Text('Story not found')));
        }

        final userAsync = story.author != null
            ? AsyncData<UserModel?>(story.author)
            : ref.watch(userByIdProvider(story.authorId));

        final List<MediaAttachment> actualMedia = [];
        if (story.mainImage.isNotEmpty) {
          actualMedia.add(
            MediaAttachment(
              mediaId: 'main',
              url: story.mainImage,
              title: 'Cover Image',
              description: '',
              isSensitive: false,
              uploadedAt: story.publishedAt,
            ),
          );
        }
        for (var i = 0; i < story.imageAssets.length; i++) {
          actualMedia.add(
            MediaAttachment(
              mediaId: 'asset_$i',
              url: story.imageAssets[i],
              title: 'Image ${i + 1}',
              description: '',
              isSensitive: false,
              uploadedAt: story.publishedAt,
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              AnimationLimiter(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      ref
                          .read(paginatedCommentsProvider(milestoneId).notifier)
                          .fetchNextPage();
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    controller: mainScrollController,
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: theme.scaffoldBackgroundColor
                            .withValues(alpha: 0.9),
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        actions: [
                          Consumer(
                            builder: (context, ref, child) {
                              final accessibilityState = ref.watch(
                                accessibilityProvider,
                              );
                              final isGreyscale =
                                  accessibilityState.isGreyscaleMode;

                              // Only show in AppBar if the floating icon is disabled
                              if (accessibilityState
                                  .showGreyscaleFloatingIcon) {
                                return const SizedBox.shrink();
                              }

                              return IconButton(
                                icon: Icon(
                                  isGreyscale
                                      ? Icons.auto_stories_rounded
                                      : Icons.auto_stories_outlined,
                                  color: isGreyscale
                                      ? theme.colorScheme.primary
                                      : theme.iconTheme.color,
                                ),
                                tooltip: 'Toggle Reading Mode (Greyscale)',
                                onPressed: () {
                                  ref
                                      .read(accessibilityProvider.notifier)
                                      .toggleGreyscaleMode();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isGreyscale
                                            ? 'Reading Mode Off'
                                            : 'Reading Mode On (Eye-friendly Greyscale)',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final currentUser = ref.watch(
                                currentUserProvider,
                              );
                              if (currentUser == null)
                                return const SizedBox.shrink();
                              return PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    ref
                                        .read(
                                          postCreationControllerProvider
                                              .notifier,
                                        )
                                        .initializeWithStory(story);
                                    context.push(AppRoutes.createPostManual);
                                  } else if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Story'),
                                        content: const Text(
                                          'Are you sure you want to delete this story? This action cannot be undone.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      try {
                                        if (story.mainImage.isNotEmpty) {
                                          await ref
                                              .read(storageRepositoryProvider)
                                              .deleteImageFromUrl(
                                                story.mainImage,
                                              );
                                        }
                                        for (final asset in story.imageAssets) {
                                          if (asset.isNotEmpty) {
                                            await ref
                                                .read(storageRepositoryProvider)
                                                .deleteImageFromUrl(asset);
                                          }
                                        }

                                        await ref
                                            .read(storyRepositoryProvider)
                                            .deleteStory(story.storyId);
                                        final updatedUser = currentUser
                                            .copyWith(
                                              ownStories: currentUser.ownStories
                                                  .where(
                                                    (id) => id != story.storyId,
                                                  )
                                                  .toList(),
                                            );
                                        await ref
                                            .read(authProvider.notifier)
                                            .updateProfile(updatedUser);

                                        // Invalidate providers to refresh UI
                                        ref.invalidate(
                                          paginatedStoriesProvider,
                                        );
                                        ref.invalidate(
                                          userStoriesProvider(
                                            currentUser.userId,
                                          ),
                                        );

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Story deleted successfully',
                                              ),
                                            ),
                                          );
                                          context.pop();
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to delete: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  } else if (value == 'request_verification') {
                                    try {
                                      final updatedStory = story.copyWith(
                                        verificationStatus: 'pending',
                                      );
                                      await ref
                                          .read(storyRepositoryProvider)
                                          .updateStory(updatedStory);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Verification request submitted',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to request verification: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  } else if (value == 'report') {
                                    context.push(
                                      AppRoutes.reportStory(story.storyId),
                                    );
                                  }
                                },
                                itemBuilder: (context) {
                                  final isAuthor =
                                      currentUser.userId == story.authorId;
                                  return [
                                    if (isAuthor) ...[
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, size: 20),
                                            SizedBox(width: 8),
                                            Text('Edit Story'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                              size: 20,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Delete Story',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (story.verificationStatus == 'none' ||
                                          story.verificationStatus ==
                                              'rejected')
                                        const PopupMenuItem(
                                          value: 'request_verification',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.verified_outlined,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Request Verification'),
                                            ],
                                          ),
                                        ),
                                    ] else ...[
                                      const PopupMenuItem(
                                        value: 'report',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.flag_outlined,
                                              size: 20,
                                              color: Colors.orange,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Report Content',
                                              style: TextStyle(
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ];
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              [
                                    if (story.isHidden)
                                      GestureDetector(
                                        onTap: () async {
                                          final url = Uri.parse(
                                            'mailto:support@healingmilestones.in?subject=Hidden%20Story%20Appeal',
                                          );
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url);
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 24,
                                          ),
                                          color: Colors.orange.withValues(
                                            alpha: 0.9,
                                          ),
                                          child: const Text(
                                            '⚠️ Hidden by admin. Visible only to you. Tap here to email support@healingmilestones.in to unhide.',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Massive Editorial Typography Header
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0,
                                        vertical: 16.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            story.heading.isNotEmpty
                                                ? story.heading
                                                : 'A Healing Journey',
                                            style: theme.textTheme.headlineLarge
                                                ?.copyWith(
                                                  fontSize: 32, // Massive scale
                                                  height: 1.1,
                                                  letterSpacing: 1.1,
                                                  fontWeight: FontWeight.w900,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface, // Frost white
                                                ),
                                          ),
                                          const SizedBox(height: 12),
                                          if (story.isVerifiedStory)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const VerifiedStoryBadge(),
                                              ],
                                            ),
                                          const SizedBox(height: 24),

                                          // Author Metadata Row
                                          GestureDetector(
                                            onTap: story.displayAuthorName
                                                ? () {
                                                    final currentUser = ref
                                                        .read(
                                                          currentUserProvider,
                                                        );
                                                    if (currentUser?.userId ==
                                                        story.authorId) {
                                                      context.push(
                                                        AppRoutes.profile,
                                                      );
                                                    } else {
                                                      context.push(
                                                        '/user/${story.authorId}',
                                                      );
                                                    }
                                                  }
                                                : null,
                                            child: Row(
                                              children: [
                                                AppAvatar(
                                                  imageUrl: userAsync
                                                      .value
                                                      ?.profilePicture,
                                                  radius: 22,
                                                  role:
                                                      userAsync.value?.role ??
                                                      story.authorRole,
                                                  isAnonymous:
                                                      !story.displayAuthorName,
                                                  showRing: true,
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          userAsync.when(
                                                            data: (user) {
                                                              final displayName =
                                                                  user?.displayName;
                                                              final username =
                                                                  user?.username;

                                                              String
                                                              authorText =
                                                                  'Author ${story.authorId}';
                                                              if (!story
                                                                  .displayAuthorName) {
                                                                authorText =
                                                                    'Anonymous';
                                                              } else if (displayName !=
                                                                      null &&
                                                                  displayName
                                                                      .isNotEmpty) {
                                                                authorText =
                                                                    displayName;
                                                              } else if (username !=
                                                                      null &&
                                                                  username
                                                                      .isNotEmpty) {
                                                                authorText =
                                                                    '@$username';
                                                              }

                                                              return Text(
                                                                authorText,
                                                                style: theme
                                                                    .textTheme
                                                                    .titleMedium
                                                                    ?.copyWith(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: theme
                                                                          .colorScheme
                                                                          .onSurface,
                                                                    ),
                                                              );
                                                            },
                                                            loading: () => Text(
                                                              !story.displayAuthorName
                                                                  ? 'Anonymous'
                                                                  : 'Loading...',
                                                              style: theme
                                                                  .textTheme
                                                                  .titleMedium
                                                                  ?.copyWith(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: theme
                                                                        .colorScheme
                                                                        .onSurface,
                                                                  ),
                                                            ),
                                                            error: (_, __) => Text(
                                                              !story.displayAuthorName
                                                                  ? 'Anonymous'
                                                                  : 'Author',
                                                              style: theme
                                                                  .textTheme
                                                                  .titleMedium
                                                                  ?.copyWith(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: theme
                                                                        .colorScheme
                                                                        .onSurface,
                                                                  ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          UserBadge(
                                                            role:
                                                                userAsync
                                                                    .value
                                                                    ?.role ??
                                                                story
                                                                    .authorRole,
                                                            isVerified:
                                                                userAsync
                                                                    .value
                                                                    ?.isVerified ??
                                                                story
                                                                    .isAuthorVerified,
                                                            iconSize: 16,
                                                          ),
                                                        ],
                                                      ),
                                                      userAsync.maybeWhen(
                                                        data: (user) {
                                                          if (story
                                                                  .displayAuthorName &&
                                                              user != null &&
                                                              (user
                                                                      .username
                                                                      ?.isNotEmpty ??
                                                                  false) &&
                                                              (user
                                                                      .displayName
                                                                      .isNotEmpty ??
                                                                  false)) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 2.0,
                                                                    bottom: 2.0,
                                                                  ),
                                                              child: Text(
                                                                '@${user.username}',
                                                                style: theme
                                                                    .textTheme
                                                                    .bodySmall
                                                                    ?.copyWith(
                                                                      color: theme
                                                                          .colorScheme
                                                                          .primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                              ),
                                                            );
                                                          }
                                                          return const SizedBox.shrink();
                                                        },
                                                        orElse: () =>
                                                            const SizedBox.shrink(),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            'Published ${_formatDate(story.publishedAt)} • ${story.readingTime > 0 ? story.readingTime : 1} min read',
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                  color: const Color(
                                                                    0xFFA1A1A6,
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  letterSpacing:
                                                                      0.5,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Hashtags
                                    if (story.hashtagsList.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0,
                                        ),
                                        child: _ExpandableTagsList(
                                          tags: story.hashtagsList,
                                        ),
                                      ),
                                    ],

                                    // Tagged People
                                    if (story.taggedUsers.isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0,
                                        ),
                                        child: _TaggedPeopleList(
                                          taggedUsers: story.taggedUsers,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 32),

                                    // The Immutable Post Widget Template - NO DIVIDERS
                                    // Encased in a beautiful midnight matte if it's minimal
                                    Builder(
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () async {
                                            final renderBox =
                                                context.findRenderObject()
                                                    as RenderBox?;
                                            if (renderBox != null) {
                                              final position = renderBox
                                                  .localToGlobal(Offset.zero);

                                              // Instantly request the OS to hide the status bar
                                              SystemChrome.setEnabledSystemUIMode(
                                                SystemUiMode.manual,
                                                overlays: [
                                                  SystemUiOverlay.bottom,
                                                ],
                                              );

                                              if (!context.mounted) return;

                                              final delta =
                                                  await Navigator.of(
                                                    context,
                                                  ).push<double>(
                                                    PageRouteBuilder(
                                                      opaque: false,
                                                      transitionDuration:
                                                          const Duration(
                                                            milliseconds: 300,
                                                          ),
                                                      pageBuilder:
                                                          (
                                                            context,
                                                            animation,
                                                            secondaryAnimation,
                                                          ) => FadeTransition(
                                                            opacity: animation,
                                                            child: ImmersiveReadingScreen(
                                                              content: story
                                                                  .description,
                                                              initialDy:
                                                                  position.dy,
                                                            ),
                                                          ),
                                                    ),
                                                  );

                                              // Restore status bar
                                              SystemChrome.setEnabledSystemUIMode(
                                                SystemUiMode.edgeToEdge,
                                              );

                                              if (delta != null && delta != 0) {
                                                mainScrollController.jumpTo(
                                                  mainScrollController.offset +
                                                      delta,
                                                );
                                              }
                                            }
                                          },
                                          child: Container(
                                            color: theme.colorScheme.surface,
                                            width: double.infinity,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 20.0,
                                                    horizontal: 8.0,
                                                  ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Read Aloud Button
                                                  if (story.description.isNotEmpty) ...[
                                                    AnimatedContainer(
                                                      duration: const Duration(milliseconds: 500),
                                                      curve: Curves.easeOutQuint,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: isPlaying.value 
                                                          ? theme.colorScheme.primary.withValues(alpha: 0.08)
                                                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                                                        borderRadius: BorderRadius.circular(24),
                                                        border: Border.all(
                                                          color: isPlaying.value
                                                              ? theme.colorScheme.primary.withValues(alpha: 0.4)
                                                              : theme.colorScheme.primary.withValues(alpha: 0.1),
                                                          width: isPlaying.value ? 1.5 : 1.0,
                                                        ),
                                                        boxShadow: isPlaying.value
                                                            ? [
                                                                BoxShadow(
                                                                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                                                  blurRadius: 20,
                                                                  spreadRadius: 4,
                                                                )
                                                              ]
                                                            : [],
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // Top Section: Label
                                                          Padding(
                                                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.headphones_rounded, color: theme.colorScheme.primary, size: 18),
                                                                const SizedBox(width: 8),
                                                                Text(
                                                                  'AUDIO STORY',
                                                                  style: TextStyle(
                                                                    color: theme.colorScheme.primary,
                                                                    fontWeight: FontWeight.w800,
                                                                    fontSize: 11,
                                                                    letterSpacing: 1.5,
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                if (isPlaying.value)
                                                                  Row(
                                                                    children: [
                                                                      Icon(Icons.graphic_eq_rounded, color: theme.colorScheme.primary, size: 18),
                                                                    ],
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                          
                                                          // Divider
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                                            child: Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.4), indent: 16, endIndent: 16),
                                                          ),

                                                          // Bottom Section: Player Controls
                                                          Padding(
                                                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                                            child: Row(
                                                              children: [
                                                                // Giant Play Button
                                                                GestureDetector(
                                                                  onTap: () async {
                                                                    if (isPlaying.value) {
                                                                      await flutterTts.stop();
                                                                      isPlaying.value = false;
                                                                    } else {
                                                                      isPlaying.value = true;
                                                                      try {
                                                                        String textToRead = story.description;
                                                                        if (story.heading.isNotEmpty) {
                                                                          textToRead = "${story.heading}. $textToRead";
                                                                        }

                                                                        await flutterTts.setVolume(1.0);
                                                                        await flutterTts.setSpeechRate(0.5 * playbackSpeed.value);
                                                                        await flutterTts.setPitch(1.0);
                                                                        
                                                                        if (selectedVoice.value != null) {
                                                                          await flutterTts.setVoice(selectedVoice.value!);
                                                                        }
                                                                        
                                                                        final List<String> chunks = [];
                                                                        int start = 0;
                                                                        while (start < textToRead.length) {
                                                                          int end = start + 3000; 
                                                                          if (end > textToRead.length) {
                                                                            chunks.add(textToRead.substring(start));
                                                                            break;
                                                                          }
                                                                          int lastSpace = textToRead.lastIndexOf(RegExp(r'\s'), end);
                                                                          if (lastSpace <= start) lastSpace = end;
                                                                          chunks.add(textToRead.substring(start, lastSpace));
                                                                          start = lastSpace;
                                                                        }

                                                                        if (Theme.of(context).platform == TargetPlatform.android) {
                                                                          await flutterTts.setQueueMode(1);
                                                                        }
                                                                        
                                                                        for (var chunk in chunks) {
                                                                          await flutterTts.speak(chunk);
                                                                        }
                                                                      } catch (e) {
                                                                        isPlaying.value = false;
                                                                        if (context.mounted) {
                                                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                                                        }
                                                                      }
                                                                    }
                                                                  },
                                                                  child: AnimatedContainer(
                                                                    duration: const Duration(milliseconds: 300),
                                                                    width: 44,
                                                                    height: 44,
                                                                    decoration: BoxDecoration(
                                                                      color: isPlaying.value ? theme.colorScheme.surface : theme.colorScheme.primary,
                                                                      shape: BoxShape.circle,
                                                                      border: isPlaying.value ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                                                                    ),
                                                                    child: Center(
                                                                      child: Padding(
                                                                        padding: EdgeInsets.only(left: isPlaying.value ? 0 : 2.0),
                                                                        child: Icon(
                                                                          isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                                                          color: isPlaying.value ? theme.colorScheme.primary : theme.colorScheme.onPrimary,
                                                                          size: 24,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 16),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        isPlaying.value ? 'Now Playing' : 'Listen to Story',
                                                                        style: TextStyle(
                                                                          fontWeight: FontWeight.bold,
                                                                          fontSize: 16,
                                                                          color: isPlaying.value ? theme.colorScheme.primary : theme.textTheme.titleMedium?.color,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(height: 2),
                                                                      Text(
                                                                        'Generated on device',
                                                                        style: TextStyle(
                                                                          fontSize: 12,
                                                                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                // Speed Menu
                                                                PopupMenuButton<double>(
                                                                  tooltip: 'Playback Speed',
                                                                  offset: const Offset(0, 40),
                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                                    decoration: BoxDecoration(
                                                                      color: theme.colorScheme.surface,
                                                                      borderRadius: BorderRadius.circular(12),
                                                                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Icon(Icons.speed_rounded, size: 14, color: theme.colorScheme.primary),
                                                                        const SizedBox(width: 4),
                                                                        Text(
                                                                          '${playbackSpeed.value}x',
                                                                          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  onSelected: (val) async {
                                                                    playbackSpeed.value = val;
                                                                    if (isPlaying.value) {
                                                                      await flutterTts.stop();
                                                                      isPlaying.value = false;
                                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                                        const SnackBar(content: Text('Speed changed. Tap play to resume.'), duration: Duration(seconds: 2))
                                                                      );
                                                                    }
                                                                  },
                                                                  itemBuilder: (context) => [
                                                                    const PopupMenuItem(value: 0.8, child: Text('0.8x (Slower)')),
                                                                    const PopupMenuItem(value: 1.0, child: Text('1.0x (Normal)')),
                                                                    const PopupMenuItem(value: 1.2, child: Text('1.2x (Faster)')),
                                                                    const PopupMenuItem(value: 1.5, child: Text('1.5x (Fastest)')),
                                                                  ],
                                                                ),
                                                                const SizedBox(width: 8),
                                                                // Voice Menu
                                                                if (availableVoices.value.isNotEmpty)
                                                                  PopupMenuButton<Map<String, String>>(
                                                                    tooltip: 'Change Voice',
                                                                    offset: const Offset(0, 40),
                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                    child: Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                                      decoration: BoxDecoration(
                                                                        color: theme.colorScheme.surface,
                                                                        borderRadius: BorderRadius.circular(12),
                                                                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                                                                      ),
                                                                      child: Icon(Icons.record_voice_over_rounded, color: theme.colorScheme.primary, size: 16),
                                                                    ),
                                                                    onSelected: (val) async {
                                                                      selectedVoice.value = val;
                                                                      if (isPlaying.value) {
                                                                        await flutterTts.stop();
                                                                        isPlaying.value = false;
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          const SnackBar(content: Text('Voice changed. Tap play to resume.'), duration: Duration(seconds: 2))
                                                                        );
                                                                      }
                                                                    },
                                                                    itemBuilder: (context) {
                                                                      return availableVoices.value.map((v) {
                                                                        final isSelected = selectedVoice.value == v || (selectedVoice.value == null && availableVoices.value.first == v);
                                                                        final text = v["displayName"] ?? "Voice";
                                                                        return PopupMenuItem(
                                                                          value: v,
                                                                          child: Text(
                                                                            text,
                                                                            style: TextStyle(
                                                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                                              color: isSelected ? theme.colorScheme.primary : null,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }).toList();
                                                                    },
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                  ],
                                                  PostDisplayWidget(
                                                    content: story.description,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 16),
                                    InteractionSection(
                                      story: story,
                                      showLabels: false,
                                    ),
                                    const SizedBox(height: 32),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (actualMedia.isNotEmpty) ...[
                                            Text(
                                              'Journey Media',
                                              style: theme
                                                  .textTheme
                                                  .headlineLarge
                                                  ?.copyWith(fontSize: 28),
                                            ),
                                            const SizedBox(height: 24),
                                            MilestoneMediaGallery(
                                              media: actualMedia,
                                            ),
                                            const SizedBox(height: 64),
                                          ],

                                          const SizedBox(
                                            height: 40,
                                          ), // Normal padding
                                        ],
                                      ),
                                    ),
                                  ]
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) =>
                                        AnimationConfiguration.staggeredList(
                                          position: entry.key,
                                          duration: const Duration(
                                            milliseconds: 600,
                                          ),
                                          child: SlideAnimation(
                                            verticalOffset: 100.0,
                                            child: FadeInAnimation(
                                              child: entry.value,
                                            ),
                                          ),
                                        ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExpandableTagsList extends StatefulWidget {
  final List<String> tags;

  const _ExpandableTagsList({Key? key, required this.tags}) : super(key: key);

  @override
  State<_ExpandableTagsList> createState() => _ExpandableTagsListState();
}

class _ExpandableTagsListState extends State<_ExpandableTagsList> {
  bool _isExpanded = false;
  // Determine how many tags to show initially. E.g., first 5 tags or all if there are <= 5.
  static const int _initialVisibleCount = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showToggle = widget.tags.length > _initialVisibleCount;
    final visibleTags = _isExpanded
        ? widget.tags
        : widget.tags.take(_initialVisibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: visibleTags.map((tag) {
            return GestureDetector(
              onTap: () {
                context.push('${AppRoutes.search}?q=$tag');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (showToggle) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Show less' : 'Show all ${widget.tags.length} tags',
              style: TextStyle(
                color: const Color(0xFFA1A1A6), // Titanium
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TaggedPeopleList extends ConsumerWidget {
  final List<UserModel> taggedUsers;
  const _TaggedPeopleList({Key? key, required this.taggedUsers})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'With:',
          style: TextStyle(
            color: const Color(0xFFA1A1A6), // Titanium
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: taggedUsers.map((user) {
            return GestureDetector(
              onTap: () {
                final currentUser = ref.read(currentUserProvider);
                if (currentUser?.userId == user.userId) {
                  context.push(AppRoutes.profile);
                } else {
                  context.push(AppRoutes.publicProfile(user.userId));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            user.profilePicture ??
                            'https://api.dicebear.com/7.x/avataaars/png?seed=${user.userId}',
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          highlightColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.25),
                          child: Container(
                            width: 20,
                            height: 20,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => CircleAvatar(
                          radius: 10,
                          backgroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                          child: Icon(
                            Icons.person,
                            size: 12,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '@${user.username ?? user.displayName}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
