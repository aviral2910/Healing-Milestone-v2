import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:healing_milestones/features/posts/presentation/widgets/post_display_widget.dart';
import 'package:healing_milestones/features/accessibility/data/accessibility_providers.dart';

class ImmersiveReadingScreen extends StatefulWidget {
  final String content;
  final double initialDy;

  const ImmersiveReadingScreen({
    Key? key,
    required this.content,
    required this.initialDy,
  }) : super(key: key);

  @override
  State<ImmersiveReadingScreen> createState() => _ImmersiveReadingScreenState();
}

class _ImmersiveReadingScreenState extends State<ImmersiveReadingScreen> {
  late ScrollController _scrollController;
  double _initialScrollOffset = 0.0;
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0.0);

  // Local state for immersive reading mode styling
  double _textSizeFactor = 1.0;
  double _textOpacity = 1.0;
  bool _isEdgePanelOpen = false;

  @override
  void initState() {
    super.initState();
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

    final screenHeight = MediaQuery.of(context).size.height;
    // We calculate the minimum scroll offset needed to match the screen position
    final requiredScrollOffset = topPadding - widget.initialDy;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final delta = _scrollController.hasClients
            ? _scrollController.offset - _initialScrollOffset
            : 0.0;
        Navigator.of(context).pop(delta);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (_isEdgePanelOpen) {
                  setState(() {
                    _isEdgePanelOpen = false;
                  });
                } else {
                  final delta = _scrollController.hasClients
                      ? _scrollController.offset - _initialScrollOffset
                      : 0.0;
                  Navigator.of(context).pop(delta);
                }
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
                    child: PostDisplayWidget(
                      content: widget.content,
                      textScaleFactor: _textSizeFactor,
                      textOpacity: _textOpacity,
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
            Consumer(
              builder: (context, ref, _) {
                final isGreyscale =
                    ref.watch(accessibilityProvider).isGreyscaleMode;
                final theme = Theme.of(context);

                // Styling based on requirements
                final handleColor =
                    isGreyscale ? Colors.grey[500]! : theme.colorScheme.primary;
                final panelBgColor =
                    isGreyscale ? Colors.grey[900]! : theme.colorScheme.surface;
                final borderColor = isGreyscale
                    ? Colors.grey[700]!
                    : theme.colorScheme.primary.withOpacity(0.3);

                final panelWidth = 120.0;
                final panelHeight = 280.0;

                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  right: _isEdgePanelOpen ? 0 : -panelWidth,
                  top: (screenHeight - panelHeight) /
                      2, // Center the panel vertically on screen
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Center handle vertically relative to panel
                    children: [
                      // Handle Tab
                      GestureDetector(
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
                          width: 16,
                          height: 48,
                          decoration: BoxDecoration(
                            color: panelBgColor,
                            border: Border(
                              left: BorderSide(color: borderColor, width: 1),
                              top: BorderSide(color: borderColor, width: 1),
                              bottom: BorderSide(color: borderColor, width: 1),
                            ),
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(8)),
                            boxShadow: [
                              if (!_isEdgePanelOpen)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(-2, 0),
                                )
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 2,
                              height: 20,
                              decoration: BoxDecoration(
                                color: handleColor.withValues(alpha: .6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Expanded Panel Content
                      Container(
                        width: panelWidth,
                        height: panelHeight,
                        decoration: BoxDecoration(
                          color: panelBgColor,
                          border: Border(
                            left: BorderSide(color: borderColor, width: 1),
                            top: BorderSide(color: borderColor, width: 1),
                            bottom: BorderSide(color: borderColor, width: 1),
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(-4, 0),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Text Size Column
                                  Column(
                                    children: [
                                      Icon(Icons.format_size_rounded,
                                          color: handleColor, size: 20),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: RotatedBox(
                                          quarterTurns: 3,
                                          child: SliderTheme(
                                            data: SliderThemeData(
                                              trackHeight: 2,
                                              activeTrackColor: handleColor,
                                              inactiveTrackColor:
                                                  handleColor.withOpacity(0.2),
                                              thumbColor: handleColor,
                                              overlayColor:
                                                  handleColor.withOpacity(0.1),
                                            ),
                                            child: Slider(
                                              value: _textSizeFactor,
                                              min: 0.8,
                                              max: 2.0,
                                              onChanged: (val) {
                                                setState(() {
                                                  _textSizeFactor = val;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Opacity Column
                                  Column(
                                    children: [
                                      Icon(Icons.opacity_rounded,
                                          color: handleColor, size: 20),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: RotatedBox(
                                          quarterTurns: 3,
                                          child: SliderTheme(
                                            data: SliderThemeData(
                                              trackHeight: 2,
                                              activeTrackColor: handleColor,
                                              inactiveTrackColor:
                                                  handleColor.withOpacity(0.2),
                                              thumbColor: handleColor,
                                              overlayColor:
                                                  handleColor.withOpacity(0.1),
                                            ),
                                            child: Slider(
                                              value: _textOpacity,
                                              min: 0.3,
                                              max: 1.0,
                                              onChanged: (val) {
                                                setState(() {
                                                  _textOpacity = val;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _textSizeFactor = 1.0;
                                  _textOpacity = 1.0;
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: handleColor,
                                minimumSize: const Size(80, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Reset',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
