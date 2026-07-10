import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../shared/templates/templates.dart';

class PostDisplayWidget extends HookConsumerWidget {
  final String content;
  final String authorName;
  final String templateStyle;
  final String? logoUrl;

  const PostDisplayWidget({
    Key? key,
    required this.content,
    required this.authorName,
    required this.templateStyle,
    this.logoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Route to the correct template based on the database string
    switch (templateStyle) {
      case 'minimalist':
        return MinimalistTemplate(content: content);
      case 'imageCentric':
        return ImageCentricTemplate(
          content: content,
          authorName: authorName,
          logoUrl: logoUrl,
        );
      case 'classicQuote':
        return ClassicQuoteTemplate(
          content: content,
          logoUrl: logoUrl,
        );
      case 'glassmorphism':
      default:
        return GlassmorphismTemplate(content: content);
    }
  }
}
