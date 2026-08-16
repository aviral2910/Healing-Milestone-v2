import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostDisplayWidget extends HookConsumerWidget {
  final String content;
  final double textScaleFactor;
  final double textOpacity;

  const PostDisplayWidget({
    Key? key,
    required this.content,
    this.textScaleFactor = 1.0,
    this.textOpacity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 16 * textScaleFactor,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: textOpacity),
        ),
      ),
    );
  }
}
