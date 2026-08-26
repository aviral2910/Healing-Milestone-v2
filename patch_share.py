with open("lib/shared/widgets/qr_share_preview.dart", "r") as f:
    content = f.read()

# Replace the method signature
old_sig = "void showJourneyShareOptions(BuildContext context, String journeyId, String journeyTitle) {"
new_sig = "void showJourneyShareOptions(BuildContext context, String journeyId, String journeyTitle, {bool isMine = true, String? authorName}) {"
content = content.replace(old_sig, new_sig)

# Replace the text logic
old_body = """            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Share Link'),
              onTap: () {
                Navigator.of(context).pop();
                Share.share(
                    'Follow my journey: $journeyTitle on Healing Milestones:\\n\\n$shareUrl',
                    subject: 'Healing Milestones Journey');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Share QR Code'),
              onTap: () {
                Navigator.of(context).pop();
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: 'Dismiss',
                  barrierColor: Colors.black87,
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return QrSharePreview(
                      id: journeyId,
                      shareUrl: shareUrl,
                      shareText: 'Scan to follow my journey on Healing Milestones.',
                      qrBottomText: 'HEALING MILESTONES',
                    );
                  },"""

new_body = """            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Share Link'),
              onTap: () {
                Navigator.of(context).pop();
                String text = 'Follow my journey: $journeyTitle on Healing Milestones:\\n\\n$shareUrl';
                if (!isMine) {
                  if (authorName != null && authorName != 'Anonymous') {
                    text = "Follow $authorName's journey: $journeyTitle on Healing Milestones:\\n\\n$shareUrl";
                  } else {
                    text = "Check out this journey: $journeyTitle on Healing Milestones:\\n\\n$shareUrl";
                  }
                }
                
                Share.share(text, subject: 'Healing Milestones Journey');
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Share QR Code'),
              onTap: () {
                Navigator.of(context).pop();
                
                String qrText = 'Scan to follow my journey on Healing Milestones.';
                if (!isMine) {
                  if (authorName != null && authorName != 'Anonymous') {
                    qrText = "Scan to follow $authorName's journey on Healing Milestones.";
                  } else {
                    qrText = "Scan to follow this journey on Healing Milestones.";
                  }
                }

                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: 'Dismiss',
                  barrierColor: Colors.black87,
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return QrSharePreview(
                      id: journeyId,
                      shareUrl: shareUrl,
                      shareText: qrText,
                      qrBottomText: 'HEALING MILESTONES',
                    );
                  },"""

content = content.replace(old_body, new_body)

with open("lib/shared/widgets/qr_share_preview.dart", "w") as f:
    f.write(content)
