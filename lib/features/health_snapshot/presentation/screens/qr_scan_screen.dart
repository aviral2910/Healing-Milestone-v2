import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class QRScanScreen extends StatefulWidget {
  final String viewId;
  const QRScanScreen({super.key, required this.viewId});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.length == 8) {
        // Assume it's the session ID if it's 8 characters
        setState(() {
          _isProcessing = true;
        });
        
        try {
          final sessionId = barcode.rawValue!;
          
          await FirebaseFirestore.instance
              .collection('qr_sessions')
              .doc(sessionId)
              .set({
            'view_id': widget.viewId,
            'status': 'linked',
          }, SetOptions(merge: true));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Synced to Web Successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop(); // Go back to snapshot screen
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sync failed: $e')),
            );
            setState(() {
              _isProcessing = false;
            });
          }
        }
        break; // Only process one barcode
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Web QR'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          // A nice scanning overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellowAccent, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Point camera at healingmilestones.in/qrshare',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 4),
                  ]
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.yellow),
                    SizedBox(height: 16),
                    Text('Syncing to Web...', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
