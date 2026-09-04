import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../data/models/medical_vault_models.dart';
import '../providers/medical_vault_providers.dart';
import '../../data/repositories/medical_vault_repository.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';

class EditReportOverlay extends ConsumerStatefulWidget {
  final MedicalRecord report;
  const EditReportOverlay({super.key, required this.report});

  static Future<void> show(BuildContext context, MedicalRecord report) {
    return showGeneralDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditReportOverlay(report: report);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            FadeTransition(
              opacity: animation,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: Colors.black.withValues(alpha: 0.4)),
              ),
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          ],
        );
      },
    );
  }

  @override
  ConsumerState<EditReportOverlay> createState() => _EditReportOverlayState();
}

class _EditReportOverlayState extends ConsumerState<EditReportOverlay> {
  final _customTypeController = TextEditingController();
  late List<String> _reportTypes;
  late DateTime _encounterDate;
  
  List<String> _suggestedTypes = [];
  List<String> _backendTags = [];
  
  Timer? _debounce;
  bool _isLoadingTags = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _reportTypes = List.from(widget.report.reportTypes);
    _encounterDate = widget.report.encounterDate;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _customTypeController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchTags(query);
    });
  }

  Future<void> _fetchTags(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _suggestedTypes = [];
          _backendTags = [];
          _isLoadingTags = false;
        });
      }
      return;
    }
    
    setState(() => _isLoadingTags = true);
    try {
      final repo = ref.read(medicalVaultRepositoryProvider);
      final tags = await repo.searchReportTags(query);
      if (mounted) {
        setState(() {
          _backendTags = tags;
          _suggestedTypes = tags.toList();
          if (!tags.any((t) => t.toLowerCase() == query.trim().toLowerCase())) {
            _suggestedTypes.insert(0, query.trim());
          }
          _isLoadingTags = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTags = false);
    }
  }

  void _addCustomType(String value) {
    final custom = value.trim();
    if (custom.isEmpty) return;

    final suggestedMatch = _suggestedTypes.where((s) => s.toLowerCase() == custom.toLowerCase()).toList();
    final typeToAdd = suggestedMatch.isNotEmpty ? suggestedMatch.first : custom;
    final alreadyAdded = _reportTypes.any((t) => t.toLowerCase() == typeToAdd.toLowerCase());

    setState(() {
      if (!alreadyAdded) {
        _reportTypes.add(typeToAdd);
      }
      _customTypeController.clear();
    });
  }

  Future<void> _submit() async {
    if (_customTypeController.text.trim().isNotEmpty) {
      _addCustomType(_customTypeController.text);
    }
    if (_reportTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one report type')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(medicalRecordsProvider.notifier).updateReport(
        id: widget.report.id,
        reportTypes: _reportTypes,
        encounterDate: _encounterDate,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update report: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 32,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Report',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          Text(
                            'Report Types',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          if (_reportTypes.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _reportTypes.map((type) {
                                return Chip(
                                  label: Text(type),
                                  onDeleted: () {
                                    setState(() {
                                      _reportTypes.remove(type);
                                    });
                                  },
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  deleteIconColor: theme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          TextField(
                            controller: _customTypeController,
                            onChanged: _onSearchChanged,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search tags (e.g. CBC, MRI, Prescription)...',
                              hintStyle: TextStyle(
                                color: theme.hintColor.withValues(alpha: 0.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              contentPadding: const EdgeInsets.all(20),
                              suffixIcon: _isLoadingTags 
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                  )
                                : IconButton(
                                    icon: Icon(Icons.add_circle, color: theme.colorScheme.primary),
                                    onPressed: () {
                                    _addCustomType(_customTypeController.text);
                                    setState(() {
                                      _suggestedTypes = [];
                                      _backendTags = [];
                                    });
                                  },
                                  ),
                            ),
                            onSubmitted: (val) {
                            _addCustomType(val);
                            setState(() {
                              _suggestedTypes = [];
                              _backendTags = [];
                            });
                          },
                          ),
                          const SizedBox(height: 12),
                          
                          if (_suggestedTypes.where((t) => !_reportTypes.contains(t)).isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              clipBehavior: Clip.none,
                              child: Row(
                                children: _suggestedTypes.where((t) => !_reportTypes.contains(t)).map((type) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Builder(
                                      builder: (context) {
                                        final isSystem = _backendTags.contains(type);
                                        return ActionChip(
                                          avatar: isSystem 
                                              ? Icon(Icons.check_circle_outline, size: 16, color: theme.colorScheme.primary) 
                                              : const Icon(Icons.add, size: 16, color: Colors.white),
                                          label: Text(
                                            type,
                                            style: TextStyle(
                                              color: isSystem ? theme.colorScheme.primary : Colors.white,
                                              fontWeight: isSystem ? FontWeight.w600 : FontWeight.w500,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _reportTypes.add(type);
                                              _customTypeController.clear();
                                              _suggestedTypes = [];
                                              _backendTags = [];
                                            });
                                          },
                                          backgroundColor: isSystem 
                                              ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                                              : Colors.white.withValues(alpha: 0.05),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(
                                              color: isSystem 
                                                  ? theme.colorScheme.primary.withValues(alpha: 0.3) 
                                                  : Colors.white.withValues(alpha: 0.5),
                                            ),
                                          ),
                                        );
                                      }
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          
                          const SizedBox(height: 32),
                          
                          Text(
                            'Encounter Date',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _encounterDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: theme.copyWith(
                                      colorScheme: theme.colorScheme.copyWith(
                                        primary: theme.colorScheme.primary,
                                        surface: theme.colorScheme.surface,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (date != null) {
                                setState(() => _encounterDate = date);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary),
                                  const SizedBox(width: 16),
                                  Text(
                                    DateFormat('MMMM d, yyyy').format(_encounterDate),
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: MediaQuery.of(context).padding.bottom + 24,
                      top: 24,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _submit,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
