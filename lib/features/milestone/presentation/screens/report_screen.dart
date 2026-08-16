import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healing_milestones/features/posts/data/story_providers.dart';
import '../../../auth/data/auth_provider.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String storyId;

  const ReportScreen({super.key, required this.storyId});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final Map<String, bool> _selectedReasons = {
    'Spam or misleading': false,
    'Harassment or bullying': false,
    'Hate speech or graphic violence': false,
    'Self-harm or dangerous acts': false,
    'Inappropriate content': false,
    'Other': false,
  };

  final TextEditingController _otherReasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    final selectedKeys = _selectedReasons.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedKeys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one reason to report.')),
      );
      return;
    }

    if (_selectedReasons['Other'] == true &&
        _otherReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide details for the "Other" reason.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String finalReason = selectedKeys.where((k) => k != 'Other').join(', ');
    if (_selectedReasons['Other'] == true) {
      final otherText = _otherReasonController.text.trim();
      finalReason = finalReason.isEmpty
          ? 'Other: $otherText'
          : '$finalReason, Other: $otherText';
    }

    try {
      final authState = ref.read(authProvider).value;
      final currentUser = authState?.userModel;
      
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      await ref.read(storyRepositoryProvider).reportStory(
            storyId: widget.storyId,
            reporterId: currentUser.userId,
            reason: finalReason,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Content'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why are you reporting this story?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._selectedReasons.keys.map((reasonKey) {
              return CheckboxListTile(
                title: Text(reasonKey),
                value: _selectedReasons[reasonKey],
                activeColor: Colors.orange,
                onChanged: (bool? value) {
                  setState(() {
                    _selectedReasons[reasonKey] = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
            if (_selectedReasons['Other'] == true) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _otherReasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Please provide more details...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: const AppLoader.small(),
                      )
                    : const Text('Submit Report',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
