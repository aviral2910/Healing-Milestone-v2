import 'package:flutter/material.dart';
import '../../data/models/biomarker_model.dart';
import '../../data/repositories/medical_vault_repository.dart';

class BiomarkerVerificationScreen extends StatefulWidget {
  final List<BiomarkerModel> initialBiomarkers;
  final String recordId;
  final MedicalVaultRepository repository;

  const BiomarkerVerificationScreen({
    super.key,
    required this.initialBiomarkers,
    required this.recordId,
    required this.repository,
  });

  @override
  State<BiomarkerVerificationScreen> createState() => _BiomarkerVerificationScreenState();
}

class _BiomarkerVerificationScreenState extends State<BiomarkerVerificationScreen> {
  late List<BiomarkerModel> _biomarkers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Create editable copies
    _biomarkers = widget.initialBiomarkers.map((b) => b.copyWith()).toList();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.repository.saveBiomarkers(widget.recordId, _biomarkers);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Results'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'AI Extracted ${_biomarkers.length} Metrics',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Please review the data below. You can correct any misread values before saving them to your vault.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _biomarkers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final biomarker = _biomarkers[index];
                return _buildBiomarkerCard(biomarker, index, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiomarkerCard(BiomarkerModel biomarker, int index, ThemeData theme) {
    final isAbnormal = biomarker.isAbnormal == true;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isAbnormal ? Colors.red.withValues(alpha: 0.5) : theme.colorScheme.outlineVariant,
          width: isAbnormal ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      Text(
                        biomarker.aiPredictedStandardName ?? biomarker.rawName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (biomarker.aiPredictedStandardName != null && biomarker.aiPredictedStandardName != biomarker.rawName)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Printed as: ${biomarker.rawName}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isAbnormal)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Abnormal',
                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInput(biomarker, index)),
                if (biomarker.rawUnit != null && biomarker.rawUnit!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Text(
                    biomarker.rawUnit!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(BiomarkerModel biomarker, int index) {
    if (biomarker.resultType == 'binary') {
      return DropdownButtonFormField<String>(
        value: biomarker.valueText,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        items: const [
          DropdownMenuItem(value: 'Positive', child: Text('Positive')),
          DropdownMenuItem(value: 'Negative', child: Text('Negative')),
          DropdownMenuItem(value: 'Reactive', child: Text('Reactive')),
          DropdownMenuItem(value: 'Non-Reactive', child: Text('Non-Reactive')),
        ],
        onChanged: (val) {
          setState(() {
            _biomarkers[index] = biomarker.copyWith(valueText: val);
          });
        },
      );
    }

    // Numeric input
    return TextFormField(
      initialValue: biomarker.valueNumeric?.toString() ?? '',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        hintText: 'Enter value',
      ),
      onChanged: (val) {
        final parsed = double.tryParse(val);
        setState(() {
          _biomarkers[index] = biomarker.copyWith(valueNumeric: parsed);
        });
      },
    );
  }
}
