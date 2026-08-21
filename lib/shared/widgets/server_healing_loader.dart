import 'dart:async';
import 'package:flutter/material.dart';
import 'app_loader.dart';

class ServerHealingLoader extends StatefulWidget {
  final bool isSliver;
  const ServerHealingLoader({Key? key, this.isSliver = false}) : super(key: key);

  @override
  State<ServerHealingLoader> createState() => _ServerHealingLoaderState();
}

class _ServerHealingLoaderState extends State<ServerHealingLoader> {
  bool _showText = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Only show the "server is healing" text if it takes longer than 2 seconds to load
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showText = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppLoader.small(),
          AnimatedOpacity(
            opacity: _showText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Text(
                'Server is healing (waking up) 🧘‍♀️\nPlease give us a moment...',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.isSliver) {
      return SliverFillRemaining(
        child: content,
      );
    }
    
    return content;
  }
}
