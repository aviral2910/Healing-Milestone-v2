import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

import '../providers/medical_vault_providers.dart';

class MixViewShareScreen extends ConsumerWidget {
  final String viewId;
  const MixViewShareScreen({super.key, required this.viewId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final viewsAsync = ref.watch(mixViewsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Share Clinical View', style: TextStyle(color: theme.colorScheme.onSurface)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: viewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (views) {
          final view = views.firstWhere(
            (v) => v.id == viewId,
            orElse: () => throw Exception('View not found'),
          );

          final shareUrl = 'https://healingmilestones.in/view/${view.id}';
          final isExpired = view.expiresAt.isBefore(DateTime.now());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  view.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isExpired 
                    ? 'Expired on ${DateFormat('MMM d, h:mm a').format(view.expiresAt)}'
                    : 'Expires ${DateFormat('MMM d, h:mm a').format(view.expiresAt)}',
                  style: TextStyle(
                    color: isExpired ? Colors.red : Colors.grey.shade700, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                
                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: QrImageView(
                    data: shareUrl,
                    version: QrVersions.auto,
                    size: 250.0,
                    dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: isExpired ? Colors.grey : theme.colorScheme.onSurface),
                    eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: isExpired ? Colors.grey : theme.colorScheme.onSurface),
                  ),
                ),
                const SizedBox(height: 32),

                // Actions
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isExpired ? null : () {
                    Clipboard.setData(ClipboardData(text: shareUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard')),
                    );
                  },
                  icon: Icon(Icons.copy, color: theme.colorScheme.onPrimary),
                  label: Text('Copy Link', style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 16)),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Revoke Access?'),
                        content: const Text('This will instantly break the link and the doctor will no longer see your timeline.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Revoke', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      ref.read(mixViewsProvider.notifier).revokeMixView(view.id);
                      if (context.mounted) Navigator.pop(context); // Go back
                    }
                  },
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Revoke Access Now', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
