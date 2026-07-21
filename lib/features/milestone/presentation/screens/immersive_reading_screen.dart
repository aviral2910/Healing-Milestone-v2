import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final safeAreaTop = MediaQuery.of(context).padding.top;
        final topPadding = widget.initialDy > safeAreaTop ? widget.initialDy : safeAreaTop;
        _initialScrollOffset = topPadding - widget.initialDy;
        
        if (_initialScrollOffset > 0) {
          _jumpToOffset(_initialScrollOffset);
        }
      }
    });
  }

  int _jumpRetries = 0;

  void _jumpToOffset(double offset) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        _scrollController.jumpTo(offset > _scrollController.position.maxScrollExtent 
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeAreaTop = MediaQuery.of(context).padding.top;
    
    // The minimum padding at the top should be the safe area so text isn't hidden under the notch.
    // But if they tapped it while it was lower than the safe area, we use that exact position.
    final topPadding = widget.initialDy > safeAreaTop ? widget.initialDy : safeAreaTop;

    final screenHeight = MediaQuery.of(context).size.height;
    // We calculate the minimum scroll offset needed to match the screen position
    final requiredScrollOffset = topPadding - widget.initialDy;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final delta = _scrollController.hasClients ? _scrollController.offset - _initialScrollOffset : 0.0;
        Navigator.of(context).pop(delta);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: GestureDetector(
          onTap: () {
            final delta = _scrollController.hasClients ? _scrollController.offset - _initialScrollOffset : 0.0;
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
      ),
    );
  }
}
