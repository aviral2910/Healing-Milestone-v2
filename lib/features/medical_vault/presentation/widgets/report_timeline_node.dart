import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/medical_vault_models.dart';
import '../providers/medical_vault_providers.dart';

enum TimelinePosition { standalone, start, middle, end }

class ReportTimelineNode extends ConsumerWidget {
  final MedicalRecord report;
  final TimelinePosition position;

  const ReportTimelineNode({
    Key? key,
    required this.report,
    required this.position,
  }) : super(key: key);

  void _showFullScreenGallery(BuildContext context, int initialIndex) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        barrierDismissible: true,
        pageBuilder: (context, _, __) {
        final pageController = PageController(initialPage: initialIndex);
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Dismissible(
            key: const Key('gallery_dismiss'),
            direction: DismissDirection.vertical,
            onDismissed: (_) => Navigator.pop(context),
            child: Stack(
              children: [
                PageView.builder(
                controller: pageController,
                itemCount: report.files.length,
                itemBuilder: (context, index) {
                  final file = report.files[index];
                  final isImage = file.fileType.startsWith('image/');
                  if (isImage) {
                    return InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 5.0,
                      panEnabled: true,
                      scaleEnabled: true,
                      child: Center(
                        child: CachedNetworkImage(imageUrl: file.url, fit: BoxFit.contain),
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf_rounded, size: 80, color: Colors.white.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(file.fileName, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  );
                },
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Left edge swipe detector to pop the gallery
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 25,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 5) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dotColor = theme.colorScheme.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line and Dot Column
          SizedBox(
            width: 40,
            child: CustomPaint(
              painter: _ReportTimelinePainter(
                position: position,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                dotColor: dotColor,
              ),
            ),
          ),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              report.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              ref.read(medicalRecordsProvider.notifier).deleteReport(report.id);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Added ${DateFormat('MMMM d, yyyy').format(report.createdAt)}',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: report.files.map((file) {
                          final isImage = file.fileType.startsWith('image/');
                          final index = report.files.indexOf(file);
                          return InkWell(
                            onTap: () => _showFullScreenGallery(context, index),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                                color: theme.colorScheme.surface,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: isImage
                                    ? CachedNetworkImage(
                                        imageUrl: file.url,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: theme.dividerColor.withValues(alpha: 0.1),
                                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                        ),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.picture_as_pdf_rounded,
                                              size: 36,
                                              color: Colors.redAccent.withValues(alpha: 0.8),
                                            ),
                                            const SizedBox(height: 4),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                              child: Text(
                                                file.fileName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTimelinePainter extends CustomPainter {
  final TimelinePosition position;
  final Color color;
  final Color dotColor;

  _ReportTimelinePainter({
    required this.position,
    required this.color,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = dotColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    // Dot is placed 24 pixels from the top of this widget
    final dotY = 24.0;

    // Draw the dot and glow
    canvas.drawCircle(Offset(centerX, dotY), 12, glowPaint);
    canvas.drawCircle(Offset(centerX, dotY), 5, dotPaint);

    // Draw lines based on position
    bool drawTop = false;
    bool drawBottom = false;

    switch (position) {
      case TimelinePosition.standalone:
        break;
      case TimelinePosition.start:
        drawBottom = true;
        break;
      case TimelinePosition.middle:
        drawTop = true;
        drawBottom = true;
        break;
      case TimelinePosition.end:
        drawTop = true;
        break;
    }

    if (drawTop) {
      canvas.drawLine(Offset(centerX, 0), Offset(centerX, dotY - 14), paint);
    }
    if (drawBottom) {
      canvas.drawLine(
        Offset(centerX, dotY + 14),
        Offset(centerX, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ReportTimelinePainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.color != color ||
        oldDelegate.dotColor != dotColor;
  }
}
