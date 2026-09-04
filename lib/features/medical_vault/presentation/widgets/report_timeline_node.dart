import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/medical_vault_models.dart';
import '../providers/medical_vault_providers.dart';
import 'edit_report_overlay.dart';

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
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      final file = report.files[initialIndex];
                      final isImage = file.fileType.startsWith('image/');

                      if (isImage) {
                        return InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 5.0,
                          panEnabled: true,
                          scaleEnabled: true,
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl: file.url,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Center(
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      if (file.fileType == 'application/pdf') {
                        return SfPdfViewer.network(
                          file.url,
                          canShowScrollHead: false,
                          canShowScrollStatus: false,
                          pageSpacing: 2,
                        );
                      }

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.insert_drive_file_rounded,
                              size: 80,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              file.fileName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
                padding: const EdgeInsets.symmetric(vertical: 20),
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
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 40),
                          child: Text(
                            'Added ${DateFormat('MMM d, yyyy').format(report.createdAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: report.reportTypes.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final type = entry.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == report.reportTypes.length - 1
                                      ? 0
                                      : 8.0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    type,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Builder(builder: (context) {
                          final indexedFiles = report.files.asMap().entries.toList();
                          final imageEntries = indexedFiles.where((e) => e.value.fileType.startsWith('image/')).toList();
                          final docEntries = indexedFiles.where((e) => !e.value.fileType.startsWith('image/')).toList();
                          
                          Widget buildSectionHeader(String title, int count) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                              child: Text(
                                '${title.toUpperCase()} ($count)',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            );
                          }
                          
                          Widget buildImageItem(MapEntry<int, dynamic> entry, bool isLast) {
                            final index = entry.key;
                            final file = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(right: isLast ? 0 : 12.0),
                              child: InkWell(
                                onTap: () => _showFullScreenGallery(context, index),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                                    color: theme.colorScheme.surface,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: file.url,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        highlightColor: theme.colorScheme.primary.withValues(alpha: 0.25),
                                        child: Container(color: Colors.white),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          Widget buildDocItem(MapEntry<int, dynamic> entry, bool isLast) {
                            final index = entry.key;
                            final file = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(right: isLast ? 0 : 12.0),
                              child: InkWell(
                                onTap: () => _showFullScreenGallery(context, index),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 220,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                                    color: theme.colorScheme.primary.withValues(alpha: 0.03),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.description_rounded, color: theme.colorScheme.primary, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              file.fileName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.labelMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: theme.colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Document',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.primary,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageEntries.isNotEmpty) ...[
                                buildSectionHeader('Images', imageEntries.length),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: imageEntries.asMap().entries.map((e) {
                                      return buildImageItem(e.value, e.key == imageEntries.length - 1);
                                    }).toList(),
                                  ),
                                ),
                              ],
                              if (imageEntries.isNotEmpty && docEntries.isNotEmpty)
                                const SizedBox(height: 16),
                              if (docEntries.isNotEmpty) ...[
                                buildSectionHeader('Documents', docEntries.length),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: docEntries.asMap().entries.map((e) {
                                      return buildDocItem(e.value, e.key == docEntries.length - 1);
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }),
                      ],
                    ),
                    Positioned(
                      top: -16,
                      right: 16,
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        onSelected: (value) async {
                          if (value == 'edit') {
                            EditReportOverlay.show(context, report);
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Report'),
                                content: const Text(
                                  'Are you sure you want to permanently delete this report and its files?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              ref
                                  .read(medicalRecordsProvider.notifier)
                                  .deleteReport(report.id);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit Tags & Date'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
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
