import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostDisplayWidget extends HookConsumerWidget {
  final String content;

  const PostDisplayWidget({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        content,
        style: const TextStyle(
          color: Color(0xFFF5F5F7),
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
