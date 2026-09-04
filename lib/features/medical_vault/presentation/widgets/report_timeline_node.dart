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
    Navigator.of(context, rootNavigator: false).push(
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
              padding: const EdgeInsets.only(bottom: 24.0, right: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: report.reportTypes.map((type) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      type,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Added ${DateFormat('MMM d, yyyy').format(report.createdAt)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          padding: EdgeInsets.zero,
                          onSelected: (value) async {
                            if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Report'),
                                  content: const Text('Are you sure you want to permanently delete this report and its files?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                ref.read(medicalRecordsProvider.notifier).deleteReport(report.id);
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
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
