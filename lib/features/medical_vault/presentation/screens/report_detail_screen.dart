import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/medical_vault_models.dart';
import '../../data/models/biomarker_model.dart';
import '../providers/medical_vault_providers.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final MedicalRecord report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  late List<BiomarkerModel> _biomarkers;
  String? _editingId;
  final _editController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _biomarkers = List.from(widget.report.biomarkers);
  }

  @override
  void dispose() {
    _editController.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveEdit(BiomarkerModel biomarker, int index) async {
    final newVal = _editController.text.trim();
    if (newVal.isEmpty) {
      setState(() => _editingId = null);
      return;
    }

    final parsed = double.tryParse(newVal);
    final updates = <String, dynamic>{};

    if (biomarker.resultType == 'numeric' && parsed != null) {
      updates['valueNumeric'] = parsed;
    } else {
      updates['valueText'] = newVal;
    }

    try {
      final repo = ref.read(medicalVaultRepositoryProvider);
      final updated = await repo.updateBiomarker(biomarker.id!, updates);

      setState(() {
        _biomarkers[index] = updated;
        _editingId = null;
      });

      ref.invalidate(medicalRecordsProvider);
      ref.invalidate(biomarkerTrendsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Sort: Abnormal first, then normal
    final sortedBiomarkers = List<BiomarkerModel>.from(_biomarkers)
      ..sort((a, b) {
        if (a.isAbnormal == true && b.isAbnormal != true) return -1;
        if (a.isAbnormal != true && b.isAbnormal == true) return 1;
        return 0;
      });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Extracted Metrics'),
            Text(
              '${_biomarkers.length} results found',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _biomarkers.isEmpty
          ? const Center(child: Text("No data extracted yet."))
          : Column(
              children: [
                // Minimalist table header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 48), // Space for icon
                      Expanded(
                        child: Text(
                          'TEST NAME',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'RESULT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 40),
                    itemCount: sortedBiomarkers.length,
                    separatorBuilder: (context, index) => Divider(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.3,
                      ),
                      height: 1,
                      indent: 72,
                      endIndent: 24,
                    ),
                    itemBuilder: (context, index) {
                      final b = sortedBiomarkers[index];
                      // Find actual index in original list for saving
                      final originalIndex = _biomarkers.indexWhere(
                        (element) => element.id == b.id,
                      );
                      final isEditing = _editingId == b.id;
                      final isAbnormal = b.isAbnormal == true;
                      final displayValue =
                          b.valueNumeric?.toString() ?? b.valueText ?? '-';
                      final unit = b.rawUnit ?? '';

                      return InkWell(
                        onTap: () {
                          if (isEditing) return;
                          setState(() {
                            _editingId = b.id;
                            _editController.text = displayValue;
                          });
                          Future.delayed(const Duration(milliseconds: 50), () {
                            _editFocusNode.requestFocus();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              // Leading Icon (Circle)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isAbnormal
                                      ? Colors.red.withValues(alpha: 0.15)
                                      : theme.colorScheme.primaryContainer
                                            .withValues(alpha: 0.5),
                                ),
                                child: Icon(
                                  isAbnormal
                                      ? Icons.warning_rounded
                                      : Icons.science_outlined,
                                  color: isAbnormal
                                      ? Colors.red
                                      : theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Middle: Name and subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.aiPredictedStandardName ?? b.rawName,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: isAbnormal
                                                ? Colors.red.shade700
                                                : theme.colorScheme.onSurface,
                                          ),
                                    ),
                                    if (isAbnormal)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Out of range',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: Colors.red.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    if (!isAbnormal &&
                                        b.aiPredictedStandardName != null &&
                                        b.aiPredictedStandardName != b.rawName)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Printed as: ${b.rawName}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Right: Value (or TextField if editing)
                              if (isEditing)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller: _editController,
                                        focusNode: _editFocusNode,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        textAlign: TextAlign.right,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 8,
                                              ),
                                          filled: true,
                                          fillColor: theme
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.5),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        onSubmitted: (_) =>
                                            _saveEdit(b, originalIndex),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      onPressed: () =>
                                          _saveEdit(b, originalIndex),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      displayValue,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isAbnormal
                                                ? Colors.red.shade700
                                                : theme.colorScheme.onSurface,
                                          ),
                                    ),
                                    if (unit.isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        unit,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
