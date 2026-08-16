import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/models/media_attachment.dart';
import 'package:shimmer/shimmer.dart';

class MilestoneMediaGallery extends StatelessWidget {
  final List<MediaAttachment> media;

  const MilestoneMediaGallery({
    Key? key,
    required this.media,
  }) : super(key: key);

  void _openFullScreenViewer(BuildContext context, MediaAttachment attachment) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FullScreenMediaViewer(media: attachment),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: media.length,
        itemBuilder: (context, index) {
          final attachment = media[index];
          return GestureDetector(
            onTap: () => _openFullScreenViewer(context, attachment),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Hero(
                tag: 'media-${attachment.mediaId}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(imageUrl: attachment.url, memCacheWidth: 800, fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                          child: Container(color: Colors.white),
                        ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFF1E1E1E),
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 32),
                        ),
                      ),),
                    if (attachment.isSensitive)
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          alignment: Alignment.center,
                          child: const Icon(Icons.visibility_off, color: Colors.white, size: 32),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenMediaViewer extends StatelessWidget {
  final MediaAttachment media;

  const FullScreenMediaViewer({Key? key, required this.media}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Hero(
            tag: 'media-${media.mediaId}',
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Center(
                child: CachedNetworkImage(imageUrl: media.url, memCacheWidth: 800, fit: BoxFit.contain,
                  placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                      child: Container(color: Colors.white),
                    ),
                  errorWidget: (context, url, error) => const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 64),
                        SizedBox(height: 16),
                        Text('Failed to load image', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.title,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    media.description,
                    style: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 16),
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
