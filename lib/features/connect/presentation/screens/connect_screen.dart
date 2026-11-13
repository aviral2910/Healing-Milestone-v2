import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/providers/feature_onboarding_provider.dart';
import '../../../../shared/widgets/feature_onboarding_screen.dart';

enum _RosterSortOption { newestFirst, oldestFirst, nameAsc, expiringSoonest }

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  bool _isLoading = true;
  bool _showGuide = false;
  bool _isDeletingSelected = false;
  List<dynamic> _rosterItems = [];
  String? _error;
  String _searchQuery = '';
  _RosterSortOption _sortOption = _RosterSortOption.newestFirst;
  final Set<String> _selectedIds = {};
  Timer? _debounce;

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  static const List<FeatureOnboardingSlide> _hmConnectSlides = [
    FeatureOnboardingSlide(
      icon: Icons.monitor_heart_outlined,
      badge: 'HM Connect',
      title: 'Shared Snapshot Roster',
      description:
          'Scan a patient or family member\'s Health Snapshot QR code and access it anytime from one place.',
      highlights: [
        'Instant access to shared timelines and lab reports',
        'Ideal for doctors, caregivers, and family members',
      ],
    ),
    FeatureOnboardingSlide(
      icon: Icons.bookmark_added_outlined,
      badge: 'Save & Organize',
      title: 'Bookmark With Custom Aliases',
      description:
          'Save snapshots with a recognizable label and search your roster in seconds.',
      highlights: [
        'Tap the bookmark icon on any shared snapshot to save it',
        'Filter quickly by patient name or custom alias',
      ],
    ),
    FeatureOnboardingSlide(
      icon: Icons.verified_user_outlined,
      badge: 'Live Privacy',
      title: 'Always Respects Snapshot Expiry',
      description:
          'Shared access stays synced with the owner\'s timer and revocations.',
      highlights: [
        'Clear active and expired status badges on every card',
        'Remove saved snapshots from your roster anytime',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchRoster();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchRoster() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = ref.read(apiClientProvider).dio;
      final response = await dio.get(
        '/api/connect/roster',
        queryParameters: {
          'limit': 100,
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        },
      );
      if (!mounted) return;
      setState(() {
        _rosterItems = (response.data['items'] ?? response.data) as List;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load roster.';
        _isLoading = false;
      });
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAllToggle() {
    setState(() {
      if (_selectedIds.length == _rosterItems.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(_rosterItems.map((item) => item['id'].toString()));
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  Future<void> _confirmAndDeleteSelected() async {
    if (_selectedIds.isEmpty || _isDeletingSelected) return;
    final count = _selectedIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(count == 1 ? 'Remove Snapshot?' : 'Remove $count Snapshots?'),
        content: Text(
          count == 1
              ? 'Remove this snapshot from your HM Connect roster?'
              : 'Remove these $count snapshots from your HM Connect roster?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isDeletingSelected = true);
    final idsToDelete = _selectedIds.toList();
    final deletedIds = <String>{};
    final dio = ref.read(apiClientProvider).dio;

    await Future.wait(
      idsToDelete.map((id) async {
        try {
          await dio.delete('/api/connect/roster/$id');
          deletedIds.add(id);
        } catch (_) {}
      }),
    );

    if (!mounted) return;
    setState(() {
      _rosterItems.removeWhere(
        (item) => deletedIds.contains(item['id'].toString()),
      );
      _selectedIds.removeAll(deletedIds);
      _isDeletingSelected = false;
    });

    final failedCount = idsToDelete.length - deletedIds.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failedCount == 0
              ? 'Removed ${deletedIds.length} ${deletedIds.length == 1 ? 'snapshot' : 'snapshots'}'
              : 'Removed ${deletedIds.length}, failed to remove $failedCount',
        ),
      ),
    );
  }

  DateTime? _parseItemAddedAt(Map<String, dynamic> item) {
    final addedStr = (item['created_at'] ?? item['added_at']) as String?;
    return addedStr != null ? DateTime.tryParse(addedStr) : null;
  }

  DateTime? _parseItemExpiresAt(Map<String, dynamic> item) {
    final mixView = item['mix_view'] as Map<String, dynamic>?;
    final expiresStr = (mixView?['expires_at'] ?? item['expires_at']) as String?;
    return expiresStr != null ? DateTime.tryParse(expiresStr) : null;
  }

  String _itemDisplayTitle(Map<String, dynamic> item) {
    final mixView = item['mix_view'] as Map<String, dynamic>?;
    final alias = (item['patient_alias'] as String?)?.trim();
    if (alias != null && alias.isNotEmpty) return alias;
    return (mixView?['author_name'] ??
            item['author_name'] ??
            'Unknown Patient')
        .toString();
  }

  List<dynamic> _sortedRosterItems() {
    final items = List<dynamic>.from(_rosterItems);
    items.sort((a, b) {
      final mapA = a as Map<String, dynamic>;
      final mapB = b as Map<String, dynamic>;
      switch (_sortOption) {
        case _RosterSortOption.newestFirst:
          final da = _parseItemAddedAt(mapA) ?? DateTime.fromMillisecondsSinceEpoch(0);
          final db = _parseItemAddedAt(mapB) ?? DateTime.fromMillisecondsSinceEpoch(0);
          return db.compareTo(da);
        case _RosterSortOption.oldestFirst:
          final da = _parseItemAddedAt(mapA) ?? DateTime.fromMillisecondsSinceEpoch(0);
          final db = _parseItemAddedAt(mapB) ?? DateTime.fromMillisecondsSinceEpoch(0);
          return da.compareTo(db);
        case _RosterSortOption.nameAsc:
          return _itemDisplayTitle(mapA).toLowerCase().compareTo(
            _itemDisplayTitle(mapB).toLowerCase(),
          );
        case _RosterSortOption.expiringSoonest:
          final ea = _parseItemExpiresAt(mapA);
          final eb = _parseItemExpiresAt(mapB);
          if (ea == null && eb == null) return 0;
          if (ea == null) return 1;
          if (eb == null) return -1;
          return ea.compareTo(eb);
      }
    });
    return items;
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _fetchRoster);
  }

  Future<void> _openQrScanner() async {
    final scannedId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const _SnapshotQrScannerScreen(),
      ),
    );

    if (scannedId != null && scannedId.isNotEmpty && mounted) {
      await context.push('/snapshot/$scannedId');
      if (mounted) _fetchRoster();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSeenOnboarding = ref.watch(
      featureOnboardingProvider.select((s) => s.hasSeenHmConnect),
    );

    if (!hasSeenOnboarding || _showGuide) {
      return FeatureOnboardingScreen(
        appBarTitle: 'HM Connect',
        slides: _hmConnectSlides,
        finalCtaLabel: 'Open HM Connect',
        onComplete: () {
          ref.read(featureOnboardingProvider.notifier).markHmConnectSeen();
          if (_showGuide) {
            setState(() => _showGuide = false);
          }
        },
      );
    }

    final buttonFg = theme.colorScheme.primary.computeLuminance() > 0.25
        ? Colors.black
        : Colors.white;

    final sortedItems = _sortedRosterItems();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 22),
                onPressed: _clearSelection,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => context.pop(),
              ),
        title: Text(
          _isSelectionMode ? '${_selectedIds.length} selected' : 'HM Connect',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: _isSelectionMode
            ? [
                IconButton(
                  tooltip: _selectedIds.length == _rosterItems.length
                      ? 'Deselect all'
                      : 'Select all',
                  icon: Icon(
                    _selectedIds.length == _rosterItems.length
                        ? Icons.deselect_rounded
                        : Icons.select_all_rounded,
                  ),
                  onPressed: _selectAllToggle,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    tooltip: 'Delete selected',
                    icon: _isDeletingSelected
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.delete_outline_rounded,
                            color: theme.colorScheme.error,
                          ),
                    onPressed: _isDeletingSelected
                        ? null
                        : _confirmAndDeleteSelected,
                  ),
                ),
              ]
            : [
                IconButton(
                  tooltip: 'How HM Connect works',
                  icon: Icon(
                    Icons.help_outline_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 21,
                  ),
                  onPressed: () => setState(() => _showGuide = true),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    tooltip: 'Scan Snapshot QR',
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    onPressed: _openQrScanner,
                  ),
                ),
              ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: TextField(
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search by patient name or alias...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: PopupMenuButton<_RosterSortOption>(
                    tooltip: 'Sort roster',
                    initialValue: _sortOption,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    icon: Icon(
                      Icons.sort_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    onSelected: (value) {
                      setState(() => _sortOption = value);
                    },
                    itemBuilder: (context) => [
                      _buildSortMenuItem(
                        _RosterSortOption.newestFirst,
                        'Newest Added',
                        Icons.schedule_rounded,
                        theme,
                      ),
                      _buildSortMenuItem(
                        _RosterSortOption.oldestFirst,
                        'Oldest Added',
                        Icons.history_rounded,
                        theme,
                      ),
                      _buildSortMenuItem(
                        _RosterSortOption.nameAsc,
                        'Name (A–Z)',
                        Icons.sort_by_alpha_rounded,
                        theme,
                      ),
                      _buildSortMenuItem(
                        _RosterSortOption.expiringSoonest,
                        'Expiring Soonest',
                        Icons.hourglass_bottom_rounded,
                        theme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchRoster,
              color: theme.colorScheme.primary,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(
                            _error!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    )
                  : _rosterItems.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 44,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Saved Snapshots',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _openQrScanner,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: buttonFg,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.qr_code_scanner_rounded),
                              label: const Text(
                                'Scan Snapshot QR',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      itemCount: sortedItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = sortedItems[index] as Map<String, dynamic>;
                        final itemId = item['id'].toString();
                        final isSelected = _selectedIds.contains(itemId);
                        final mixView =
                            item['mix_view'] as Map<String, dynamic>?;
                        final addedStr =
                            (item['created_at'] ?? item['added_at']) as String?;
                        final expiresStr =
                            (mixView?['expires_at'] ?? item['expires_at'])
                                as String?;

                        final addedAt = addedStr != null
                            ? DateTime.tryParse(addedStr)?.toLocal()
                            : null;
                        final expiresAt = expiresStr != null
                            ? DateTime.tryParse(expiresStr)?.toLocal()
                            : null;
                        final isExpired =
                            expiresAt != null &&
                            expiresAt.isBefore(DateTime.now());

                        final displayTitle =
                            (item['patient_alias'] as String?)
                                    ?.trim()
                                    .isNotEmpty ==
                                true
                            ? item['patient_alias'] as String
                            : (mixView?['author_name'] ??
                                      item['author_name'] ??
                                      'Unknown Patient')
                                  as String;
                        final snapshotName =
                            (mixView?['name'] ??
                                    item['snapshot_title'] ??
                                    'Health Snapshot')
                                as String;
                        final authorName =
                            (mixView?['author_name'] ?? item['author_name'])
                                as String?;
                        final subtitleText = (authorName != null &&
                                authorName.isNotEmpty &&
                                authorName != displayTitle)
                            ? authorName
                            : (snapshotName != displayTitle
                                  ? snapshotName
                                  : null);

                        return Material(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(
                                  alpha: 0.08,
                                )
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onLongPress: () => _toggleSelection(itemId),
                            onTap: () async {
                              if (_isSelectionMode) {
                                _toggleSelection(itemId);
                                return;
                              }
                              await context.push(
                                '/snapshot/${item['mix_view_id']}',
                              );
                              if (mounted) _fetchRoster();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  width: isSelected ? 1.5 : 1,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor.withValues(
                                          alpha: 0.2,
                                        ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.primary.withValues(
                                            alpha: 0.14,
                                          ),
                                    foregroundColor: isSelected
                                        ? buttonFg
                                        : theme.colorScheme.primary,
                                    radius: 24,
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 22,
                                          )
                                        : Text(
                                            displayTitle.isNotEmpty
                                                ? displayTitle
                                                      .substring(0, 1)
                                                      .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                displayTitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                            if (expiresAt != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      (isExpired
                                                              ? theme
                                                                    .colorScheme
                                                                    .error
                                                              : theme
                                                                    .colorScheme
                                                                    .primary)
                                                          .withValues(
                                                            alpha: 0.12,
                                                          ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        100,
                                                      ),
                                                ),
                                                child: Text(
                                                  isExpired
                                                      ? 'Expired'
                                                      : 'Until ${DateFormat('MMM d').format(expiresAt)}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: isExpired
                                                        ? theme
                                                              .colorScheme
                                                              .error
                                                        : theme
                                                            .colorScheme
                                                            .primary,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (subtitleText != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            subtitleText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                        if (addedAt != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Added ${DateFormat('MMM d, yyyy').format(addedAt)}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                      .withValues(alpha: 0.7),
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_RosterSortOption> _buildSortMenuItem(
    _RosterSortOption value,
    String label,
    IconData icon,
    ThemeData theme,
  ) {
    final isCurrent = _sortOption == value;
    return PopupMenuItem<_RosterSortOption>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isCurrent
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (isCurrent)
            Icon(
              Icons.check_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
        ],
      ),
    );
  }
}

class _SnapshotQrScannerScreen extends StatefulWidget {
  const _SnapshotQrScannerScreen();

  @override
  State<_SnapshotQrScannerScreen> createState() =>
      _SnapshotQrScannerScreenState();
}

class _SnapshotQrScannerScreenState extends State<_SnapshotQrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _extractSnapshotId(String raw) {
    final trimmed = raw.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      final idx = uri.pathSegments.indexOf('snapshot');
      if (idx != -1 && idx + 1 < uri.pathSegments.length) {
        return uri.pathSegments[idx + 1];
      }
    }
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (uuidRegex.hasMatch(trimmed)) return trimmed;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan Snapshot QR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: Colors.white,
            ),
            onPressed: () async {
              await _controller.toggleTorch();
              if (mounted) setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_handled) return;
              for (final barcode in capture.barcodes) {
                final val = barcode.rawValue;
                if (val == null) continue;
                final id = _extractSnapshotId(val);
                if (id != null && id.isNotEmpty) {
                  _handled = true;
                  Navigator.of(context).pop(id);
                  break;
                }
              }
            },
          ),
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.72),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: 56,
            left: 24,
            right: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: const Text(
                  'Point camera at a Health Snapshot QR code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
