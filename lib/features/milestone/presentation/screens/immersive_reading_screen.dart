import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healing_milestones/features/posts/presentation/widgets/post_display_widget.dart';

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
                final delta = _scrollController.hasClients
                    ? _scrollController.offset - _initialScrollOffset
                    : 0.0;
                Navigator.of(context).pop(delta);
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
          ],
        ),
      ),
    );
  }
}
