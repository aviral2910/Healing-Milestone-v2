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

  @override
  void initState() {
    super.initState();
    // If the text was scrolled offscreen, we start the scroll controller at that offset.
    final scrollOffset = widget.initialDy < 0 ? -widget.initialDy : 0.0;
    _scrollController = ScrollController(initialScrollOffset: scrollOffset);
    
    if (scrollOffset > 0) {
      _jumpToOffset(scrollOffset);
    }
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
    // Top padding if the text was lower on the screen than the top edge.
    final topPadding = widget.initialDy > 0 ? widget.initialDy : 0.0;

    final screenHeight = MediaQuery.of(context).size.height;
    final scrollOffset = widget.initialDy < 0 ? -widget.initialDy : 0.0;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pop(_scrollController.offset);
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: GestureDetector(
          onTap: () => Navigator.of(context).pop(_scrollController.offset),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(
                minHeight: screenHeight + scrollOffset,
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
