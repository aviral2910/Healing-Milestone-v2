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

    return Scaffold(
      backgroundColor:
          theme.colorScheme.surfaceContainer, // Slightly off-background color
      appBar: AppBar(
        title: Text(
          'Report Metrics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _biomarkers.isEmpty
          ? const Center(child: Text("No data extracted yet."))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: theme
                      .colorScheme
                      .surface, // Pure surface color for the card
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Row (Like the Beaufort scale or Teal table)
                    Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 24), // space for the dot
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Test Name',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Value',
                              textAlign: TextAlign.right,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rows
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _biomarkers.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.dividerColor.withValues(alpha: 0.05),
                        indent: 20,
                        endIndent: 20,
                      ),
                      itemBuilder: (context, index) {
                        final b = _biomarkers[index];
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
                            Future.delayed(
                              const Duration(milliseconds: 50),
                              () {
                                _editFocusNode.requestFocus();
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Left: Colored Dot (like Beaufort scale)
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(right: 14),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isAbnormal
                                        ? Colors.red
                                        : theme.colorScheme.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (isAbnormal
                                                    ? Colors.red
                                                    : theme.colorScheme.primary)
                                                .withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                // Middle: Names
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b.aiPredictedStandardName ?? b.rawName,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                      ),
                                      if (b.aiPredictedStandardName != null &&
                                          b.aiPredictedStandardName !=
                                              b.rawName)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Text(
                                            b.rawName,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  fontSize: 12,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Right: Value
                                Expanded(
                                  flex: 1,
                                  child: isEditing
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _editController,
                                                focusNode: _editFocusNode,
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                textAlign: TextAlign.right,
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                        horizontal: 8,
                                                      ),
                                                  filled: true,
                                                  fillColor: theme
                                                      .colorScheme
                                                      .surfaceContainerHighest
                                                      .withValues(alpha: 0.3),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                                onSubmitted: (_) =>
                                                    _saveEdit(b, index),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () => _saveEdit(b, index),
                                              child: const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Align(
                                          alignment: Alignment.centerRight,
                                          child: RichText(
                                            textAlign: TextAlign.right,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: displayValue,
                                                  style: theme
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16,
                                                        color: isAbnormal
                                                            ? Colors.red
                                                            : theme
                                                                  .colorScheme
                                                                  .onSurface,
                                                      ),
                                                ),
                                                if (unit.isNotEmpty)
                                                  TextSpan(
                                                    text: ' $unit',
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }
}
