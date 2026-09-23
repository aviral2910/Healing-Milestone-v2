import 'package:flutter/material.dart';
import '../../data/models/biomarker_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/medical_vault_repository.dart';
import '../providers/medical_vault_providers.dart';
import '../providers/trends_provider.dart';

class EditBiomarkerBottomSheet extends ConsumerStatefulWidget {
  final BiomarkerModel primaryBiomarker;
  final BiomarkerModel? secondaryBiomarker;

  const EditBiomarkerBottomSheet({
    super.key,
    required this.primaryBiomarker,
    this.secondaryBiomarker,
  });

  static Future<void> show(
    BuildContext context,
    BiomarkerModel primary,
    BiomarkerModel? secondary,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditBiomarkerBottomSheet(
          primaryBiomarker: primary,
          secondaryBiomarker: secondary,
        ),
      ),
    );
  }

  @override
  ConsumerState<EditBiomarkerBottomSheet> createState() =>
      _EditBiomarkerBottomSheetState();
}

class _EditBiomarkerBottomSheetState extends ConsumerState<EditBiomarkerBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _valueController;
  late TextEditingController _diastolicController;
  late TextEditingController _unitController;
  bool _isAbnormal = false;
  bool _isSaving = false;

  bool get _isDualBP => widget.secondaryBiomarker != null;

  @override
  void initState() {
    super.initState();
    
    // We only allow editing the value and abnormal flag in this quick edit,
    // to keep it simple and consistent.
    
    String displayName = widget.primaryBiomarker.rawName;
    if (_isDualBP) {
      displayName = 'Blood Pressure';
    }

    _nameController = TextEditingController(text: displayName);
    
    _valueController = TextEditingController(
      text: widget.primaryBiomarker.valueNumeric?.toInt().toString() ?? '',
    );
    
    _diastolicController = TextEditingController(
      text: widget.secondaryBiomarker?.valueNumeric?.toInt().toString() ?? '',
    );

    _unitController = TextEditingController(
      text: widget.primaryBiomarker.rawUnit ?? '',
    );

    _isAbnormal = widget.primaryBiomarker.isAbnormal ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _diastolicController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valText = _valueController.text.trim();
    if (valText.isEmpty) return;

    setState(() => _isSaving = true);
    final repo = ref.read(medicalVaultRepositoryProvider);

    try {
      if (_isDualBP) {
        final sysVal = double.tryParse(valText);
        final diaVal = double.tryParse(_diastolicController.text.trim());

        if (sysVal != null && diaVal != null) {
          await repo.updateBiomarker(widget.primaryBiomarker.id!, {
            'valueNumeric': sysVal,
            'isAbnormal': _isAbnormal,
          });
          await repo.updateBiomarker(widget.secondaryBiomarker!.id!, {
            'valueNumeric': diaVal,
            'isAbnormal': _isAbnormal,
          });
        }
      } else {
        final numVal = double.tryParse(valText);
        if (numVal != null) {
          await repo.updateBiomarker(widget.primaryBiomarker.id!, {
            'valueNumeric': numVal,
            'isAbnormal': _isAbnormal,
          });
        }
      }
      
      ref.invalidate(medicalRecordsProvider);
      ref.invalidate(biomarkerTrendsProvider);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Entry',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Name (read-only visually)
                  Text(
                    _nameController.text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Value Input
                  if (_isDualBP)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _buildMinimalTextField(
                            controller: _valueController,
                            hint: 'Systolic (e.g. 120)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            '/',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildMinimalTextField(
                            controller: _diastolicController,
                            hint: 'Diastolic (e.g. 80)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        if (_unitController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 12),
                            child: Text(
                              _unitController.text,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _buildMinimalTextField(
                            controller: _valueController,
                            hint: 'Value',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        if (_unitController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 12),
                            child: Text(
                              _unitController.text,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  
                  SwitchListTile(
                    title: const Text('Mark as Abnormal'),
                    subtitle: const Text('Flag this result as out of range'),
                    value: _isAbnormal,
                    onChanged: (val) => setState(() => _isAbnormal = val),
                    activeColor: Colors.red,
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  const SizedBox(height: 32),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
