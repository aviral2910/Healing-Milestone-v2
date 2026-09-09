import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/biomarker_card.dart';
import '../widgets/add_biomarker_bottom_sheet.dart';
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

  List<BiomarkerModel> _getDisplayBiomarkers() {
    final List<BiomarkerModel> merged = [];
    final List<BiomarkerModel> sysList = [];
    final List<BiomarkerModel> diaList = [];

    for (final b in _biomarkers) {
      final lowerName = b.rawName.toLowerCase();
      if (lowerName.contains('systolic')) {
        sysList.add(b);
      } else if (lowerName.contains('diastolic')) {
        diaList.add(b);
      } else {
        merged.add(b);
      }
    }

    final int pairs = sysList.length < diaList.length ? sysList.length : diaList.length;
    for (int i = 0; i < pairs; i++) {
      final sys = sysList[i];
      final dia = diaList[i];
      merged.insert(0, BiomarkerModel(
        id: sys.id,
        rawName: 'Blood Pressure',
        rawUnit: sys.rawUnit ?? 'mmHg',
        resultType: 'numeric', 
        valueNumeric: null, 
        valueText: '${sys.valueNumeric?.toInt() ?? '-'}/${dia.valueNumeric?.toInt() ?? '-'}',
        isAbnormal: (sys.isAbnormal ?? false) || (dia.isAbnormal ?? false),
        aiPredictedStandardName: 'Blood Pressure',
      ));
    }
    
    if (sysList.length > pairs) merged.addAll(sysList.sublist(pairs));
    if (diaList.length > pairs) merged.addAll(diaList.sublist(pairs));

    return merged;
  }


  Future<void> _showBPEditDialog(BiomarkerModel sysB, BiomarkerModel diaB) async {
    final sysController = TextEditingController(text: sysB.valueNumeric?.toInt().toString() ?? '');
    final diaController = TextEditingController(text: diaB.valueNumeric?.toInt().toString() ?? '');
    final theme = Theme.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Blood Pressure'),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: sysController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Systolic',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('/', style: TextStyle(fontSize: 24)),
              ),
              Expanded(
                child: TextField(
                  controller: diaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Diastolic',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final newSys = double.tryParse(sysController.text.trim());
      final newDia = double.tryParse(diaController.text.trim());
      
      if (newSys != null && newDia != null) {
        final repo = ref.read(medicalVaultRepositoryProvider);
        try {
          final updatedSys = await repo.updateBiomarker(sysB.id!, {'valueNumeric': newSys});
          final updatedDia = await repo.updateBiomarker(diaB.id!, {'valueNumeric': newDia});
          
          setState(() {
            final sIdx = _biomarkers.indexWhere((b) => b.id == sysB.id);
            final dIdx = _biomarkers.indexWhere((b) => b.id == diaB.id);
            if (sIdx != -1) _biomarkers[sIdx] = updatedSys;
            if (dIdx != -1) _biomarkers[dIdx] = updatedDia;
          });
          
          ref.invalidate(medicalRecordsProvider);
          ref.invalidate(biomarkerTrendsProvider);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update BP')));
          }
        }
      }
    }
  }

  Future<void> _saveEdit(
    BiomarkerModel biomarker,
    String newVal,
  ) async {
    newVal = newVal.trim();
    if (newVal.isEmpty) {
      setState(() => _editingId = null);
      return;
    }
    
    final repo = ref.read(medicalVaultRepositoryProvider);
    
    if (biomarker.rawName == 'Blood Pressure' && newVal.contains('/')) {
      final parts = newVal.split('/');
      if (parts.length == 2) {
        final sysVal = double.tryParse(parts[0].trim());
        final diaVal = double.tryParse(parts[1].trim());
        
        if (sysVal != null && diaVal != null) {
          try {
            final sysIndex = _biomarkers.indexWhere((b) => b.rawName.toLowerCase().contains('systolic'));
            final diaIndex = _biomarkers.indexWhere((b) => b.rawName.toLowerCase().contains('diastolic'));
            
            if (sysIndex != -1 && diaIndex != -1) {
              final updatedSys = await repo.updateBiomarker(_biomarkers[sysIndex].id!, {'valueNumeric': sysVal, 'resultType': 'numeric', 'valueText': null});
              final updatedDia = await repo.updateBiomarker(_biomarkers[diaIndex].id!, {'valueNumeric': diaVal, 'resultType': 'numeric', 'valueText': null});
              
              setState(() {
                _biomarkers[sysIndex] = updatedSys;
                _biomarkers[diaIndex] = updatedDia;
                _editingId = null;
              });
              ref.invalidate(medicalRecordsProvider);
              ref.invalidate(biomarkerTrendsProvider);
              return;
            }
          } catch (e) {}
        }
      }
    }

    final parsed = double.tryParse(newVal);
    final updates = <String, dynamic>{};

    if (biomarker.resultType == 'numeric' && parsed != null) {
      updates['valueNumeric'] = parsed;
    } else {
      updates['valueText'] = newVal;
    }

    try {
      final updated = await repo.updateBiomarker(biomarker.id!, updates);

      setState(() {
        final realIndex = _biomarkers.indexWhere((b) => b.id == updated.id);
        if (realIndex != -1) {
          _biomarkers[realIndex] = updated;
        }
        _editingId = null;
      });

      ref.invalidate(medicalRecordsProvider);
      ref.invalidate(biomarkerTrendsProvider);
    } catch (e) {}
  }

  @override
  Future<void> _addMetricManually(List<BiomarkerModel> newMetrics) async {
    try {
      final repo = ref.read(medicalVaultRepositoryProvider);
      final created = await repo.saveBiomarkers(widget.report.id, newMetrics);

      if (mounted && created.isNotEmpty) {
        setState(() {
          _biomarkers.addAll(created);
        });
        ref.invalidate(medicalRecordsProvider);
        ref.invalidate(biomarkerTrendsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Metrics added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add metric: $e')));
      }
    }
  }

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
        floatingActionButton: _isExtracting
            ? null
            : FloatingActionButton.extended(
                onPressed: () =>
                    AddBiomarkerBottomSheet.show(context, _addMetricManually),
                icon: const Icon(Icons.add),
                label: const Text('Add Metric'),
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
                      sliver: Builder(
                        builder: (context) {
                          final displayBiomarkers = _getDisplayBiomarkers();
                          return SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                              final b = displayBiomarkers[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: BiomarkerCard(
                                  biomarker: b,
                                  compact: false,
                                  isEditing: _editingId == b.id,
                                  onEditTap: () {
                                    if (b.rawName == 'Blood Pressure') {
                                      final sysIdx = _biomarkers.indexWhere((orig) => orig.rawName.toLowerCase().contains('systolic'));
                                      final diaIdx = _biomarkers.indexWhere((orig) => orig.rawName.toLowerCase().contains('diastolic'));
                                      if (sysIdx != -1 && diaIdx != -1) {
                                        _showBPEditDialog(_biomarkers[sysIdx], _biomarkers[diaIdx]);
                                      }
                                      return;
                                    }
                                    setState(() {
                                      _editingId = b.id;
                                    });
                                  },
                                  onSave: (val) {
                                    _saveEdit(b, val);
                                  },
                                ),
                              );
                            }, childCount: displayBiomarkers.length),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
