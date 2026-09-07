import 'package:flutter/material.dart';
import '../../../journey/data/models/journey_models.dart' hide TimelinePosition;
import 'package:healing_milestones/features/medical_vault/data/models/medical_vault_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../medical_vault/presentation/widgets/report_timeline_node.dart';

import '../../../journey/data/providers/journey_providers.dart';
import '../../../medical_vault/presentation/providers/medical_vault_providers.dart';

class CreateSnapshotWizardScreen extends ConsumerStatefulWidget {
  const CreateSnapshotWizardScreen({super.key});

  @override
  ConsumerState<CreateSnapshotWizardScreen> createState() =>
      _CreateSnapshotWizardScreenState();
}

class _CreateSnapshotWizardScreenState
    extends ConsumerState<CreateSnapshotWizardScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Page 1 State
  final _nameController = TextEditingController();

  // Page 2 State
  final Set<String> _selectedJourneyIds = {};

  // Page 3 State
  final Set<String> _selectedReportIds = {};
  DateTime? _filterDate;
  final Set<String> _filterTags = {};
  bool _isAllSelected = false;
  int _selectedDurationHours = 24;

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for the snapshot')),
      );
      return;
    }

    if (_currentPage == 2 && _selectedJourneyIds.isEmpty && _selectedReportIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one journey or medical record to create a snapshot.'),
        ),
      );
      return;
    }

    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _isLoading = true);
      try {
        final newView = await ref
            .read(mixViewsProvider.notifier)
            .createMixView(
              name: _nameController.text.trim(),
              journeyIds: _selectedJourneyIds.toList(),
              selectedReportIds: _selectedReportIds.toList(),
              durationHours: _selectedDurationHours,
            );
        if (!mounted) return;
        context.pushReplacement('/health-snapshot/view/${newView.id}');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create snapshot: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  void _applyLocalFilters() {
    final allRecords = ref.read(medicalRecordsProvider).value ?? [];

    if (_filterDate == null && _filterTags.isEmpty) {
      setState(() {
        _selectedReportIds.clear();
        _isAllSelected = false;
      });
      return;
    }

    final matchingIds = allRecords
        .where((r) {
          if (_filterDate != null) {
            final utcEnc = r.encounterDate.toUtc();
            final rDate = DateTime(utcEnc.year, utcEnc.month, utcEnc.day);
            final fDate = DateTime(
              _filterDate!.year,
              _filterDate!.month,
              _filterDate!.day,
            );
            if (rDate.isBefore(fDate)) return false;
          }
          if (_filterTags.isNotEmpty) {
            final hasMatch = r.reportTypes.any((t) => _filterTags.contains(t));
            if (!hasMatch) return false;
          }
          return true;
        })
        .map((r) => r.id)
        .toSet();

    setState(() {
      _selectedReportIds.clear();
      _selectedReportIds.addAll(matchingIds);
      _isAllSelected =
          (matchingIds.length == allRecords.length) && allRecords.isNotEmpty;
    });
  }

  Future<void> _showFilterBottomSheet(
    BuildContext context,
    ThemeData theme,
  ) async {
    DateTime? tempFilterDate = _filterDate;
    Set<String> tempFilterTags = Set.from(_filterTags);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final tagsAsync = ref.watch(uniqueMedicalTagsProvider);
            return tagsAsync.when(
              loading: () => const SizedBox(
                height: 250,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SizedBox(
                height: 250,
                child: Center(child: Text('Error: $e')),
              ),
              data: (availableTags) {
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    return SafeArea(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 20,
                                ),
                                height: 4,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Filters',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (tempFilterDate != null ||
                                      tempFilterTags.isNotEmpty)
                                    TextButton(
                                      onPressed: () {
                                        setModalState(() {
                                          tempFilterDate = null;
                                          tempFilterTags.clear();
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            theme.colorScheme.primary,
                                      ),
                                      child: const Text(
                                        'Clear All',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Text(
                                'By Date',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        tempFilterDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setModalState(() => tempFilterDate = date);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tempFilterDate != null
                                        ? theme.colorScheme.primary.withValues(
                                            alpha: 0.15,
                                          )
                                        : theme
                                              .colorScheme
                                              .surfaceContainerHighest
                                              .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: tempFilterDate != null
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.primary.withValues(alpha: 0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        color: tempFilterDate != null
                                            ? theme.colorScheme.primary
                                            : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          tempFilterDate == null
                                              ? 'Any Date'
                                              : 'After ${DateFormat('MMMM d, yyyy').format(tempFilterDate!)}',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                color: tempFilterDate != null
                                                    ? theme.colorScheme.primary
                                                    : theme
                                                          .colorScheme
                                                          .onSurface,
                                                fontWeight:
                                                    tempFilterDate != null
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                        ),
                                      ),
                                      if (tempFilterDate != null)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            setModalState(
                                              () => tempFilterDate = null,
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            if (availableTags.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Text(
                                  'By Tags',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 16,
                                  children: availableTags.map((tag) {
                                    final isSelected = tempFilterTags.contains(
                                      tag,
                                    );
                                    return GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          if (isSelected) {
                                            tempFilterTags.remove(tag);
                                          } else {
                                            tempFilterTags.add(tag);
                                          }
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                                    .withValues(alpha: 0.15)
                                              : theme
                                                    .colorScheme
                                                    .surfaceContainerHighest
                                                    .withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.primary.withValues(alpha: 0.2),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isSelected) ...[
                                              Icon(
                                                Icons.check_circle_rounded,
                                                size: 16,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              const SizedBox(width: 6),
                                            ],
                                            Text(
                                              tag.toUpperCase(),
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                    color: isSelected
                                                        ? theme
                                                              .colorScheme
                                                              .primary
                                                        : theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w800
                                                        : FontWeight.w600,
                                                    letterSpacing: 0.5,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 40),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _filterDate = tempFilterDate;
                                    _filterTags.clear();
                                    _filterTags.addAll(tempFilterTags);
                                  });
                                  _applyLocalFilters();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Apply Filters',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _prevPage,
        ),
        title: Text(
          _currentPage == 0
              ? 'Name Your Snapshot'
              : _currentPage == 1
              ? 'Select Journey'
              : 'Select Records',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Step ${_currentPage + 1} of 3',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Force using buttons
        onPageChanged: (idx) => setState(() => _currentPage = idx),
        children: [
          _buildBasicInfoPage(theme),
          _buildJourneysPage(theme),
          _buildReportsPage(theme),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _nextPage,
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _currentPage == 2 ? 'Generate Snapshot' : 'Next Step',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What is a Health Snapshot?',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Merge your journey and medical records into one timeline.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Snapshot Name Field
          Text(
            'Snapshot Name',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., Oncology Follow-up',
              hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Expiration Dropdown
          Text(
            'Security Expiration',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: _selectedDurationHours,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('1 Hour (Quick Share)'),
                  ),
                  DropdownMenuItem(value: 24, child: Text('24 Hours')),
                  DropdownMenuItem(value: 168, child: Text('7 Days')),
                  DropdownMenuItem(
                    value: 720,
                    child: Text('30 Days (Maximum)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDurationHours = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REPLACE _buildJourneysPage

  Widget _buildJourneysPage(ThemeData theme) {
    final journeysAsync = ref.watch(myJourneysProvider);

    return journeysAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (journeys) {
        if (journeys.isEmpty) {
          return const Center(child: Text('No journeys available.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Select Journeys',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                'Choose which journeys to include in this snapshot. You can skip this step if you only want to share medical records.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: journeys.length,
                itemBuilder: (context, index) {
                  final journey = journeys[index];
                  final isSelected = _selectedJourneyIds.contains(journey.id);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedJourneyIds.remove(journey.id);
                        } else {
                          _selectedJourneyIds.add(journey.id);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616).withValues(
                          alpha: 0.6,
                        ), // Matching Together screen card
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 12,
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          // Premium Folder + Visibility Badge
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.folder_rounded,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.8,
                                  ),
                                  size: 28,
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(
                                        0xFF161616,
                                      ), // Match card background
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        journey.visibility ==
                                                MilestoneVisibility.private
                                            ? Icons.lock_rounded
                                            : (journey.visibility ==
                                                      MilestoneVisibility
                                                          .anonymous
                                                  ? Icons.masks_rounded
                                                  : Icons.public_rounded),
                                        size: 10,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  journey.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children:
                                        (journey.categories.isNotEmpty
                                                ? journey.categories
                                                : ['General'])
                                            .map(
                                              (cat) => Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 6.0,
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    border: Border.all(
                                                      color: theme
                                                          .colorScheme
                                                          .primary
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '#${cat.toUpperCase()}',
                                                    style: theme
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          letterSpacing: 0.5,
                                                          fontSize: 9,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportsPage(ThemeData theme) {
    final recordsAsync = ref.watch(medicalRecordsProvider);

    return recordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (allRecords) {
        final records = allRecords;

        final grouped = <DateTime, List<MedicalRecord>>{};
        for (final record in records) {
          final utcEnc = record.encounterDate.toUtc();
          final date = DateTime(utcEnc.year, utcEnc.month, utcEnc.day);
          grouped.putIfAbsent(date, () => []).add(record);
        }

        final sortedDates = grouped.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedReportIds.length} selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: _isAllSelected 
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: _isAllSelected 
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            final newVal = !_isAllSelected;
                            if (newVal) {
                              setState(() {
                                _selectedReportIds.addAll(records.map((r) => r.id));
                                _isAllSelected = true;
                              });
                            } else {
                              setState(() {
                                _selectedReportIds.removeAll(records.map((r) => r.id));
                                _isAllSelected = false;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0, right: 10, top: 0, bottom: 0),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: 0.8,
                                  child: Checkbox(
                                    value: _isAllSelected,
                                    activeColor: theme.colorScheme.primary,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (val) {
                                      if (val == true) {
                                        setState(() {
                                          _selectedReportIds.addAll(records.map((r) => r.id));
                                          _isAllSelected = true;
                                        });
                                      } else {
                                        setState(() {
                                          _selectedReportIds.removeAll(records.map((r) => r.id));
                                          _isAllSelected = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'All',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: _isAllSelected 
                                        ? theme.colorScheme.primary 
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            iconSize: 18,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: (_filterDate != null || _filterTags.isNotEmpty) 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.onSurfaceVariant,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: (_filterDate != null || _filterTags.isNotEmpty)
                                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                : Colors.transparent,
                            ),
                            onPressed: () => _showFilterBottomSheet(context, theme),
                          ),
                          if (_filterDate != null || _filterTags.isNotEmpty)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.colorScheme.surface, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: records.isEmpty
                  ? Center(
                      child: Text(
                        allRecords.isEmpty
                            ? 'No medical reports found.'
                            : 'No reports match your filters.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: sortedDates.length,
                      itemBuilder: (context, index) {
                        final date = sortedDates[index];
                        final dateRecords = grouped[date]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              child: Text(
                                DateFormat('MMMM d, yyyy').format(date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            ...List.generate(dateRecords.length, (i) {
                              final r = dateRecords[i];
                              final isSelected = _selectedReportIds.contains(
                                r.id,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedReportIds.remove(r.id);
                                        _isAllSelected = false;
                                      } else {
                                        _selectedReportIds.add(r.id);
                                      }
                                    });
                                  },
                                  child: ReportTimelineNode(
                                    report: r,
                                    position: dateRecords.length == 1
                                        ? TimelinePosition.standalone
                                        : (i == 0
                                              ? TimelinePosition.start
                                              : (i == dateRecords.length - 1
                                                    ? TimelinePosition.end
                                                    : TimelinePosition.middle)),
                                    isSelected: isSelected,
                                    showEditMenu: false,
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
