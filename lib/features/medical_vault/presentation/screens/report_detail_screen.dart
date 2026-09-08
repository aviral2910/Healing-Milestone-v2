import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healing_milestones/features/medical_vault/data/repositories/medical_vault_repository.dart';
import 'package:healing_milestones/features/medical_vault/presentation/providers/trends_provider.dart';
import '../../data/models/medical_vault_models.dart';
import '../../data/models/biomarker_model.dart';
import '../providers/medical_vault_providers.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final MedicalRecord report;

  const ReportDetailScreen({
    super.key,
    required this.report,
    this.autoExtract = false,
  });
  final bool autoExtract;

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  late List<BiomarkerModel> _biomarkers;
  String? _editingId;
  final _editController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();

  bool _isExtracting = false;
  String? _extractionError;

  @override
  void initState() {
    super.initState();
    _biomarkers = List.from(widget.report.biomarkers);
    if (widget.autoExtract && _biomarkers.isEmpty) {
      _isExtracting = true;
      _runExtraction();
    }
  }

  Future<void> _runExtraction() async {
    setState(() {
      _isExtracting = true;
      _extractionError = null;
    });

    try {
      final fileUrls = widget.report.files.map((f) => f.url).toList();
      final repo = ref.read(medicalVaultRepositoryProvider);
      final extracted = await repo.extractAndSaveBiomarkers(
        widget.report.id,
        fileUrls,
      );

      if (mounted) {
        setState(() {
          _biomarkers = extracted;
          _isExtracting = false;
        });
        ref.invalidate(medicalRecordsProvider);
        ref.invalidate(biomarkerTrendsProvider);

        if (extracted.isEmpty) {
          setState(() {
            _extractionError = "No health metrics were found in this document.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExtracting = false;
          _extractionError =
              "AI extraction failed. The server might be busy or the document is unreadable.";
        });
      }
    }
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_isExtracting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isExtracting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait, AI is analyzing your report.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainer, // Soft background
        appBar: AppBar(
          automaticallyImplyLeading: !_isExtracting,
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: _isExtracting
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Shimmer.fromColors(
                      baseColor: theme.colorScheme.primary,
                      highlightColor: theme.colorScheme.primaryContainer,
                      child: const Icon(Icons.auto_awesome_rounded, size: 80),
                    ),
                    const SizedBox(height: 24),
                    Shimmer.fromColors(
                      baseColor: theme.colorScheme.onSurface,
                      highlightColor: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                      child: Text(
                        'AI is analyzing your report...',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This usually takes 15-20 seconds',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : _extractionError != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.withValues(alpha: 0.8),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Analysis Failed',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _extractionError!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: _runExtraction,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              )
            : _biomarkers.isEmpty
            ? const Center(child: Text("No data extracted yet."))
            : ListView.separated(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 40,
                ),
                itemCount: _biomarkers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final b = _biomarkers[index];
                  final isEditing = _editingId == b.id;
                  final isAbnormal = b.isAbnormal == true;
                  final displayValue =
                      b.valueNumeric?.toString() ?? b.valueText ?? '-';
                  final unit = b.rawUnit ?? '';
                  final isTextResult = b.resultType != 'numeric';

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
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAbnormal
                              ? Colors.red.withValues(alpha: 0.3)
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isAbnormal
                                ? Colors.red.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: isTextResult
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isAbnormal
                                            ? Colors.red.withValues(alpha: 0.1)
                                            : theme.colorScheme.primaryContainer
                                                  .withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        isAbnormal
                                            ? Icons.warning_amber_rounded
                                            : Icons.science_rounded,
                                        color: isAbnormal
                                            ? Colors.red
                                            : theme.colorScheme.primary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            b.aiPredictedStandardName ??
                                                b.rawName,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                          ),
                                          if (b.aiPredictedStandardName !=
                                                  null &&
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
                                  ],
                                ),
                                const SizedBox(height: 16),
                                isEditing
                                    ? Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _editController,
                                              focusNode: _editFocusNode,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: null,
                                              style: theme.textTheme.bodyMedium,
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 12,
                                                    ),
                                                filled: true,
                                                fillColor: theme
                                                    .colorScheme
                                                    .surfaceContainerHighest
                                                    .withValues(alpha: 0.5),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => _saveEdit(b, index),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(
                                                  alpha: 0.1,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.green,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        displayValue,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              height: 1.5,
                                              color: isAbnormal
                                                  ? Colors.red.shade700
                                                  : theme.colorScheme.onSurface,
                                            ),
                                      ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isAbnormal
                                        ? Colors.red.withValues(alpha: 0.1)
                                        : theme.colorScheme.primaryContainer
                                              .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isAbnormal
                                        ? Icons.warning_amber_rounded
                                        : Icons.science_rounded,
                                    color: isAbnormal
                                        ? Colors.red
                                        : theme.colorScheme.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b.aiPredictedStandardName ?? b.rawName,
                                        style: theme.textTheme.titleSmall
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
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
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
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
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
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withValues(alpha: 0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Align(
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                displayValue,
                                                textAlign: TextAlign.right,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 18,
                                                      color: isAbnormal
                                                          ? Colors.red
                                                          : theme
                                                                .colorScheme
                                                                .primary,
                                                    ),
                                              ),
                                              if (unit.isNotEmpty)
                                                Text(
                                                  unit,
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
                              ],
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
