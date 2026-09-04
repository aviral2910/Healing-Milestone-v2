import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../providers/medical_vault_providers.dart';
import '../../data/repositories/medical_vault_repository.dart';
import 'package:healing_milestones/shared/widgets/app_loader.dart';


import '../../data/models/medical_vault_models.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditReportOverlay extends ConsumerStatefulWidget {
  final MedicalRecord report;
  const EditReportOverlay({super.key, required this.report});

  static Future<void> show(BuildContext context, MedicalRecord report) {
    return showGeneralDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent, // Using BackdropFilter instead
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return EditReportOverlay(report: report);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  ConsumerState<EditReportOverlay> createState() => _EditReportOverlayState();
}

class _EditReportOverlayState extends ConsumerState<EditReportOverlay> {
  final _customTypeController = TextEditingController();
  List<String> _reportTypes = [];
  List<String> _suggestedTypes = [];
  List<String> _backendTags = [];
  Timer? _debounce;
  bool _isLoadingTags = false;



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

  late DateTime _encounterDate;
  List<PlatformFile> _selectedFiles = [];
  List<MedicalRecordFile> _existingFiles = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _reportTypes = List.from(widget.report.reportTypes);
    _encounterDate = widget.report.encounterDate;
    _existingFiles = List.from(widget.report.files);
  }

  void _addCustomType(String value) {
    final custom = value.trim();
    if (custom.isEmpty) return;

    // Check if it matches a suggested type case-insensitively
    final suggestedMatch = _suggestedTypes.where((s) => s.toLowerCase() == custom.toLowerCase()).toList();
    final typeToAdd = suggestedMatch.isNotEmpty ? suggestedMatch.first : custom;

    // Check if we already have it in the selected list
    final alreadyAdded = _reportTypes.any((t) => t.toLowerCase() == typeToAdd.toLowerCase());

    setState(() {
      if (!alreadyAdded) {
        _reportTypes.add(typeToAdd);
      }
      _customTypeController.clear();
    });
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(result);
      });
    }
  }

  void _showFullScreenGallery(int initialIndex) {
    Navigator.of(context, rootNavigator: false).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        barrierDismissible: true,
        pageBuilder: (context, _, __) {
        final pageController = PageController(initialPage: initialIndex);
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: _existingFiles.length + _selectedFiles.length,
                itemBuilder: (context, index) {
                  final isExisting = index < _existingFiles.length;
                  final fileName = isExisting ? _existingFiles[index].fileName : _selectedFiles[index - _existingFiles.length].name;
                  final filePath = isExisting ? _existingFiles[index].url : _selectedFiles[index - _existingFiles.length].path;
                  final isImage = fileName.toLowerCase().endsWith('.jpg') || 
                                  fileName.toLowerCase().endsWith('.jpeg') || 
                                  fileName.toLowerCase().endsWith('.png');
                  
                  if (isImage && filePath != null) {
                    return InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 5.0,
                      panEnabled: true,
                      scaleEnabled: true,
                      child: Center(
                        child: isExisting ? CachedNetworkImage(imageUrl: filePath, fit: BoxFit.contain) : Image.file(File(filePath), fit: BoxFit.contain),
                      ),
                    );
                  }
                  if (filePath != null && fileName.toLowerCase().endsWith('.pdf')) {
                    return isExisting 
                        ? SfPdfViewer.network(filePath, canShowScrollHead: false, canShowScrollStatus: false, pageSpacing: 2)
                        : SfPdfViewer.file(File(filePath), canShowScrollHead: false, canShowScrollStatus: false, pageSpacing: 2);
                  }
                  
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.insert_drive_file_rounded, size: 80, color: Colors.white.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(fileName, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  );
                },
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

            ],
          ),
        );
      },
    ));
  }

  void _removeFile(int index) {
    setState(() {
      if (index < _existingFiles.length) {
        _existingFiles.removeAt(index);
      } else {
        _selectedFiles.removeAt(index - _existingFiles.length);
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _encounterDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _encounterDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_customTypeController.text.trim().isNotEmpty) {
      _addCustomType(_customTypeController.text);
    }
    if (_reportTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one report type')));
      return;
    }
    if (_existingFiles.isEmpty && _selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one file')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      await ref.read(medicalRecordsProvider.notifier).uploadReport(
        files: _selectedFiles,
        reportTypes: _reportTypes,
        encounterDate: _encounterDate,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report uploaded securely!')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryGlow = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Full screen glassmorphism background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.surface,
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close_rounded, size: 24),
                                style: IconButton.styleFrom(
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withValues(alpha: 0.15),
                                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Upload Report',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Report Types Input
                        Text(
                          'Report Types',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Selected Tags
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
                        // Type Input Field
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
                        // Suggestions horizontally scrollable
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
                        const SizedBox(height: 24),

                        // Report Date
                        Text(
                          'Report Date',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.dividerColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Date of Test / Scan',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: theme.hintColor.withValues(alpha: 0.7),
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat('MMMM d, yyyy').format(_encounterDate),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.edit_calendar_rounded, color: theme.colorScheme.onSurface, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // File Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Attachments',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _pickFiles,
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Add Files', style: TextStyle(fontWeight: FontWeight.w600)),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // File Previews
                        if (_existingFiles.isEmpty && _selectedFiles.isEmpty)
                          InkWell(
                            onTap: _pickFiles,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.3),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.upload_file_rounded,
                                    size: 48,
                                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tap to select files',
                                    style: TextStyle(
                                      color: theme.hintColor.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              clipBehavior: Clip.none,
                              itemCount: _existingFiles.length + _selectedFiles.length,
                              itemBuilder: (context, index) {
                                final isExisting = index < _existingFiles.length;
                                final fileName = isExisting ? _existingFiles[index].fileName : _selectedFiles[index - _existingFiles.length].name;
                                final filePath = isExisting ? _existingFiles[index].url : _selectedFiles[index - _existingFiles.length].path;
                                final isImage = fileName.toLowerCase().endsWith('.jpg') || 
                                                fileName.toLowerCase().endsWith('.jpeg') || 
                                                fileName.toLowerCase().endsWith('.png');
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 110,
                                      margin: const EdgeInsets.only(right: 16, top: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                                        color: theme.colorScheme.surface,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: isImage && filePath != null
                                            ? InkWell(
                                                onTap: () => _showFullScreenGallery(index),
                                                child: isExisting 
                                                    ? CachedNetworkImage(imageUrl: filePath, fit: BoxFit.cover)
                                                    : Image.file(File(filePath), fit: BoxFit.cover),
                                              )
                                            : InkWell(
                                                onTap: () => _showFullScreenGallery(index),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.picture_as_pdf_rounded,
                                                    size: 48,
                                                    color: Colors.redAccent.withValues(alpha: 0.8),
                                                  ),
                                                ),
                                              )
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 8,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _removeFile(index),
                                          customBorder: const CircleBorder(),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.surface,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.1),
                                                  blurRadius: 4,
                                                )
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 16,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 48),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryGlow,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 8,
                              shadowColor: primaryGlow.withValues(alpha: 0.4),
                            ),
                            onPressed: _isUploading ? null : _submit,
                            child: _isUploading 
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: AppLoader.small(),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
