import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/accessibility/data/accessibility_providers.dart';
import 'package:healing_milestones/features/posts/presentation/widgets/post_display_widget.dart';

class ImmersiveReadingScreen extends ConsumerStatefulWidget {
  final String content;
  final double initialDy;

  const ImmersiveReadingScreen({
    Key? key,
    required this.content,
    required this.initialDy,
  }) : super(key: key);

  @override
  ConsumerState<ImmersiveReadingScreen> createState() =>
      _ImmersiveReadingScreenState();
}

class _ImmersiveReadingScreenState
    extends ConsumerState<ImmersiveReadingScreen> {
  late ScrollController _scrollController;
  double _initialScrollOffset = 0.0;
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);
  bool _isEdgePanelOpen = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final max = _scrollController.position.maxScrollExtent;
        if (max > 0) {
          _progressNotifier.value =
              (_scrollController.offset / max).clamp(0.0, 1.0);
        } else {
          _progressNotifier.value = 1.0;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final safeAreaTop = MediaQuery.of(context).padding.top;
        final topPadding =
            widget.initialDy > safeAreaTop ? widget.initialDy : safeAreaTop;
        _initialScrollOffset = topPadding - widget.initialDy;

        if (_initialScrollOffset > 0) {
          _jumpToOffset(_initialScrollOffset);
        } else if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent <= 0) {
          _progressNotifier.value = 1.0;
        }
      }
    });
  }

  int _jumpRetries = 0;

  void _jumpToOffset(double offset) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _scrollController.jumpTo(
            offset > _scrollController.position.maxScrollExtent
                ? _scrollController.position.maxScrollExtent
                : offset);
      } else if (_jumpRetries < 20) {
        _jumpRetries++;
        _jumpToOffset(offset);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _progressNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeAreaTop = MediaQuery.of(context).padding.top;

    // The minimum padding at the top should be the safe area so text isn't hidden under the notch.
    // But if they tapped it while it was lower than the safe area, we use that exact position.
    final topPadding =
        widget.initialDy > safeAreaTop ? widget.initialDy : safeAreaTop;

    // When text size changes, we want to maintain our relative position within the text.
    ref.listen(accessibilityProvider, (previous, next) {
      if (previous != null && previous.textSizeFactor != next.textSizeFactor) {
        final ratio = next.textSizeFactor / previous.textSizeFactor;
        if (_scrollController.hasClients) {
          final currentTextOffset = _scrollController.offset - topPadding;
          final newTextOffset = currentTextOffset * ratio;
          // Jump to the new offset to keep the same text word roughly in view
          _scrollController.jumpTo(topPadding + newTextOffset);
        }
      }
    });

    final screenHeight = MediaQuery.of(context).size.height;
    // We calculate the minimum scroll offset needed to match the screen position
    final requiredScrollOffset = topPadding - widget.initialDy;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final textOffset = _scrollController.hasClients
            ? _scrollController.offset - topPadding
            : 0.0;
        Navigator.of(context).pop(textOffset);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (_isEdgePanelOpen) {
                  setState(() => _isEdgePanelOpen = false);
                  return;
                }
                final textOffset = _scrollController.hasClients
                    ? _scrollController.offset - topPadding
                    : 0.0;
                Navigator.of(context).pop(textOffset);
              },
              behavior: HitTestBehavior.opaque,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: screenHeight + requiredScrollOffset,
                  ),
                  color: theme.colorScheme.surface,
                  width: double.infinity,
                  padding: EdgeInsets.only(top: topPadding, bottom: 100),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 8.0,
                    ),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final state = ref.watch(accessibilityProvider);
                        final data = MediaQuery.of(context);
                        return MediaQuery(
                          data: data.copyWith(
                            textScaler: TextScaler.linear(
                                data.textScaler.scale(1) *
                                    state.textSizeFactor),
                          ),
                          child: Opacity(
                            opacity: state.textOpacity,
                            child: child!,
                          ),
                        );
                      },
                      child: PostDisplayWidget(
                        content: widget.content,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).padding.bottom,
                  width: double.infinity,
                  color: theme.colorScheme.surface,
                )),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: _progressNotifier,
                builder: (context, progress, _) {
                  return LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary.withOpacity(0.7)),
                  );
                },
              ),
            ),

            // Edge Panel
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutBack,
              right: _isEdgePanelOpen ? 0 : -220,
              top: 0,
              bottom: 0,
              child: SafeArea(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Consumer(builder: (context, ref, child) {
                        final accessibilityState =
                            ref.watch(accessibilityProvider);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _isEdgePanelOpen = !_isEdgePanelOpen;
                            });
                          },
                          onPanUpdate: (details) {
                            if (details.delta.dx < -2) {
                              setState(() => _isEdgePanelOpen = true);
                            } else if (details.delta.dx > 2) {
                              setState(() => _isEdgePanelOpen = false);
                            }
                          },
                          child: Container(
                            width: 18,
                            height: 90,
                            decoration: BoxDecoration(
                              color: accessibilityState.isGreyscaleMode
                                  ? Colors.grey[900]
                                  : Theme.of(context).cardColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              border: Border(
                                top: BorderSide(
                                  color: accessibilityState.isGreyscaleMode
                                      ? Colors.grey.withValues(alpha: .2)
                                      : theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                                left: BorderSide(
                                  color: accessibilityState.isGreyscaleMode
                                      ? Colors.grey.withValues(alpha: .2)
                                      : theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: accessibilityState.isGreyscaleMode
                                      ? Colors.grey.withValues(alpha: .2)
                                      : theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 2,
                                  offset: const Offset(-2, 0),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isEdgePanelOpen
                                  ? Icons.chevron_right
                                  : Icons.chevron_left,
                              color: accessibilityState.isGreyscaleMode
                                  ? Colors.white
                                  : Theme.of(context).iconTheme.color,
                              size: 20,
                            ),
                          ),
                        );
                      }),

                      // Panel Content
                      Consumer(
                        builder: (context, ref, child) {
                          final accessibilityState =
                              ref.watch(accessibilityProvider);
                          return Container(
                            width: 220,
                            padding: const EdgeInsets.symmetric(
                                vertical: 24, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              color: accessibilityState.isGreyscaleMode
                                  ? Colors.grey[900]
                                  : theme.colorScheme.surface
                                      .withValues(alpha: 0.95),
                              border: Border(
                                top: BorderSide(
                                  color: accessibilityState.isGreyscaleMode
                                      ? Colors.grey.withValues(alpha: .2)
                                      : theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                                left: BorderSide(
                                  color: accessibilityState.isGreyscaleMode
                                      ? Colors.grey.withValues(alpha: .2)
                                      : theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: accessibilityState.isGreyscaleMode
                                      ? Colors.grey.withValues(alpha: .2)
                                      : theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(-5, 0),
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Display Settings',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Text Size Slider
                                Column(
                                  children: [
                                    const Icon(Icons.format_size,
                                        size: 20, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 150,
                                      child: RotatedBox(
                                        quarterTurns: 3,
                                        child: Consumer(
                                          builder: (context, ref, _) {
                                            final state = ref
                                                .watch(accessibilityProvider);
                                            return Slider(
                                              value: state.textSizeFactor,
                                              min: 0.8,
                                              max: 2.0,
                                              activeColor:
                                                  theme.colorScheme.primary,
                                              onChanged: (val) => ref
                                                  .read(accessibilityProvider
                                                      .notifier)
                                                  .updateTextSizeFactor(val),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Size',
                                        style: theme.textTheme.labelSmall),
                                  ],
                                ),
                                // Opacity Slider
                                Column(
                                  children: [
                                    const Icon(Icons.opacity,
                                        size: 20, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 150,
                                      child: RotatedBox(
                                        quarterTurns: 3,
                                        child: Consumer(
                                          builder: (context, ref, _) {
                                            final state = ref
                                                .watch(accessibilityProvider);
                                            return Slider(
                                              value: state.textOpacity,
                                              min: 0.3,
                                              max: 1.0,
                                              activeColor:
                                                  theme.colorScheme.primary,
                                              onChanged: (val) => ref
                                                  .read(accessibilityProvider
                                                      .notifier)
                                                  .updateTextOpacity(val),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Opacity',
                                        style: theme.textTheme.labelSmall),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: Consumer(builder: (context, ref, _) {
                                return OutlinedButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(accessibilityProvider.notifier)
                                        .updateTextSizeFactor(1.0);
                                    ref
                                        .read(accessibilityProvider.notifier)
                                        .updateTextOpacity(1.0);
                                  },
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Reset'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        theme.colorScheme.onSurface,
                                    side: BorderSide(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.2)),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
