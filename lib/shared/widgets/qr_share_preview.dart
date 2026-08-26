import 'package:healing_milestones/shared/widgets/direct_share_sheet.dart';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:healing_milestones/logo/healing_milestone_logo.dart';
import 'package:gal/gal.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

class QrSharePreview extends StatefulWidget {
  final String id;
  final String shareUrl;
  final String shareText;
  final String qrBottomText;

  const QrSharePreview({
    Key? key,
    required this.id,
    required this.shareUrl,
    required this.shareText,
    required this.qrBottomText,
  }) : super(key: key);

  @override
  State<QrSharePreview> createState() => _QrSharePreviewState();
}

class _QrSharePreviewState extends State<QrSharePreview> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  void _shareQrCode() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
        pixelRatio: 3.0,
      );

      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File(
                '${tempDir.path}/healing_milestones_qr_${widget.id}.png')
            .create();
        await file.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: widget.shareText,
        );
      }
    } catch (e) {
      debugPrint('Error sharing QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share QR code.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  void _downloadQrCode() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
        pixelRatio: 3.0,
      );

      if (imageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/healing_milestones_qr_${widget.id}.png';
        final file = await File(filePath).create();
        await file.writeAsBytes(imageBytes);

        // Check permission if necessary, gal usually handles it internally
        await Gal.putImage(filePath);

        if (mounted) {
          Navigator.of(context).pop(); // Close the dialog first
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code successfully saved to gallery!')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error downloading QR code: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog on error too
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save QR code.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share QR Code',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // The widget we want to capture
            Screenshot(
              controller: _screenshotController,
              child: Container(
                color:
                    theme.colorScheme.surface, // Background color for the image
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: widget.shareUrl,
                        version: QrVersions.auto,
                        size: 200.0,
                        embeddedImage: const AssetImage('assets/logo.png'),
                        embeddedImageStyle: const QrEmbeddedImageStyle(
                          size: Size(40, 40),
                        ),
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const HealingMilestonesStaticLogoWidget(
                      logoSize: 32.0,
                      showText: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.qrBottomText,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSharing ? null : _downloadQrCode,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(
                          color: theme.colorScheme.primary, width: 1.5),
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSharing ? null : _shareQrCode,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: const AppLoader.small())
                        : const Icon(Icons.share),
                    label: Text(_isSharing ? 'Sharing...' : 'Share'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}


void showShareOptions(BuildContext context, String storyId) {
  final shareUrl = 'https://healingmilestones.in/story/$storyId';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DirectShareSheet(
        storyId: storyId,
        shareUrl: shareUrl,
        shareText: 'Check out this story on Healing Milestones:\n\n$shareUrl',
        qrBottomText: 'Scan to read the Healing Story',
      );
    },
  );
}

void showProfileShareOptions(BuildContext context, String userId) {
  final shareUrl = 'https://healingmilestones.in/user/$userId';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DirectShareSheet(
        profileId: userId,
        shareUrl: shareUrl,
        shareText: 'Check out this profile on Healing Milestones:\n\n$shareUrl',
        qrBottomText: 'Scan to view Profile',
      );
    },
  );
}

void showJourneyShareOptions(BuildContext context, String journeyId, String journeyTitle, {bool isMine = true, String? authorName}) {
  final shareUrl = 'https://healingmilestones.in/journey/$journeyId';

  String text = 'Follow my journey: $journeyTitle on Healing Milestones:\n\n$shareUrl';
  String qrText = 'Scan to follow my journey on Healing Milestones.';
  
  if (!isMine) {
    if (authorName != null && authorName != 'Anonymous') {
      text = "Follow $authorName's journey: $journeyTitle on Healing Milestones:\n\n$shareUrl";
      qrText = "Scan to follow $authorName's journey on Healing Milestones.";
    } else {
      text = "Check out this journey: $journeyTitle on Healing Milestones:\n\n$shareUrl";
      qrText = "Scan to follow this journey on Healing Milestones.";
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DirectShareSheet(
        journeyId: journeyId,
        shareUrl: shareUrl,
        shareText: text,
        qrBottomText: qrText,
      );
    },
  );
}
