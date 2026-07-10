import 'dart:ui';
import 'package:flutter/material.dart';

// 1. Minimalist Template: Strictly black background, pure typography.
class MinimalistTemplate extends StatelessWidget {
  final String content;
  const MinimalistTemplate({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black, // Strict black background constraint
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Text(
        content,
        style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// 2. Image Centric Template: Expanded widgets for centering, exact logo dimensions.
class ImageCentricTemplate extends StatelessWidget {
  final String content;
  final String authorName;
  final String? logoUrl;
  
  const ImageCentricTemplate({
    Key? key, required this.content, required this.authorName, this.logoUrl
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                '"$content"',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (logoUrl != null) ...[
                    Image.network(
                      logoUrl!,
                      width: 30, // Strict 30x30 constraint
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    "- $authorName",
                    style: const TextStyle(color: Color(0xFFA0A0A0), fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Classic Quote Template: 16.0 padding, BoxFit.cover for logo.
class ClassicQuoteTemplate extends StatelessWidget {
  final String content;
  final String? logoUrl;
  
  const ClassicQuoteTemplate({Key? key, required this.content, this.logoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0), // Strict 16.0 padding constraint
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logoUrl != null)
            Image.network(
              logoUrl!,
              height: 40,
              width: 40,
              fit: BoxFit.cover, // Strict BoxFit.cover constraint
            ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 18),
          ),
        ],
      ),
    );
  }
}

// 4. Glassmorphism Template: Frosted glass effect over gradient.
class GlassmorphismTemplate extends StatelessWidget {
  final String content;
  
  const GlassmorphismTemplate({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A2D34), Color(0xFF121212)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Frosted glass blur
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05), // Dark translucent
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                content,
                style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
