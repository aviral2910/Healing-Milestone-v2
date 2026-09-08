import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/biomarker_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    super.dispose();
  }

  Future<void> _saveEdit(
    BiomarkerModel biomarker,
    int index,
    String newVal,
  ) async {
    newVal = newVal.trim();
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
                      const SizedBox(height: 8),
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
            : CustomScrollView(
                slivers: [
                  // Disclaimer Note
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 12,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "AI extraction can make mistakes. Please refer to the original document before making any clinical conclusions.",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Empty state for biomarkers
                  if (_biomarkers.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: const Center(
                        child: Text("No data extracted yet."),
                      ),
                    ),

                  // Biomarker Cards
                  if (_biomarkers.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 40,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final b = _biomarkers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: BiomarkerCard(
                              biomarker: b,
                              compact: false,
                              isEditing: _editingId == b.id,
                              onEditTap: () {
                                setState(() {
                                  _editingId = b.id;
                                });
                              },
                              onSave: (val) {
                                _saveEdit(b, index, val);
                              },
                            ),
                          );
                        }, childCount: _biomarkers.length),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
