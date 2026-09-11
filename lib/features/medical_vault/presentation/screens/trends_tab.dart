import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/trends_provider.dart';
import '../../data/models/biomarker_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'metric_detail_screen.dart';

class TrendsTab extends ConsumerStatefulWidget {
  const TrendsTab({super.key});

  @override
  ConsumerState<TrendsTab> createState() => _TrendsTabState();
}

class _TrendsTabState extends ConsumerState<TrendsTab> {
  List<String> _pinnedMetrics = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPinned();
  }

  Future<void> _loadPinned() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pinnedMetrics = prefs.getStringList('pinned_metrics') ?? [];
    });
  }

  String _getCategory(String name) {
    name = name.toLowerCase();
    if (name.contains('cholesterol') ||
        name.contains('hdl') ||
        name.contains('ldl') ||
        name.contains('triglyceride')) {
      return 'Lipids & Heart Health';
    }
    if (name.contains('glucose') ||
        name.contains('hba1c') ||
        name.contains('insulin')) {
      return 'Metabolic';
    }
    if (name.contains('pressure') ||
        name.contains('heart rate') ||
        name.contains('weight') ||
        name.contains('bmi')) {
      return 'Vitals & Measurements';
    }
    if (name.contains('alt') ||
        name.contains('ast') ||
        name.contains('alp') ||
        name.contains('bilirubin') ||
        name.contains('protein')) {
      return 'Liver & Kidneys';
    }
    if (name.contains('white blood') ||
        name.contains('red blood') ||
        name.contains('hemoglobin') ||
        name.contains('platelet') ||
        name.contains('hematocrit') ||
        name.contains('mcv') ||
        name.contains('mchc')) {
      return 'CBC';
    }
    return 'Other Biomarkers';
  }

  IconData _getCategoryIconData(String category) {
    switch (category) {
      case 'Lipids & Heart Health':
        return Icons.favorite_rounded;
      case 'Metabolic':
        return Icons.bolt_rounded;
      case 'Vitals & Measurements':
        return Icons.monitor_heart_rounded;
      case 'Liver & Kidneys':
        return Icons.science_rounded;
      case 'CBC':
        return Icons.water_drop_rounded;
      default:
        return Icons.biotech_rounded;
    }
  }

  // Restoring the colorful icons!
  Color _getCategoryColor(String category, ThemeData theme) {
    switch (category) {
      case 'Lipids & Heart Health':
        return Colors.pinkAccent;
      case 'Metabolic':
        return Colors.orange;
      case 'Vitals & Measurements':
        return Colors.blue;
      case 'Liver & Kidneys':
        return Colors.teal;
      case 'CBC':
        return Colors.redAccent;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trendsAsync = ref.watch(biomarkerTrendsProvider);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        await _loadPinned();
        ref.invalidate(biomarkerTrendsProvider);
      },
      child: trendsAsync.when(
        data: (trends) {
          if (trends.isEmpty) {
            return _buildEmptyState(context);
          }

          // Pre-process for Dual BP
          final processedTrends = <String, BiomarkerTrendModel>{};
          BiomarkerTrendModel? sysTrend;
          BiomarkerTrendModel? diaTrend;

          for (final t in trends) {
            if (t.name.toLowerCase().contains('systolic'))
              sysTrend = t;
            else if (t.name.toLowerCase().contains('diastolic'))
              diaTrend = t;
            else
              processedTrends[t.name] = t;
          }

          // Grouping
          final pinned = <dynamic>[];
          final categories = <String, List<dynamic>>{};

          void addTrend(
            BiomarkerTrendModel t, [
            BiomarkerTrendModel? secondary,
          ]) {
            final bundle = {'primary': t, 'secondary': secondary};
            final name = secondary != null ? 'Blood Pressure' : t.name;

            if (_pinnedMetrics.contains(name)) {
              pinned.add(bundle);
            }
            final cat = _getCategory(name);
            categories.putIfAbsent(cat, () => []).add(bundle);
          }

          for (final t in processedTrends.values) {
            if (_searchQuery.isEmpty ||
                t.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
              addTrend(t);
            }
          }
          if (sysTrend != null) {
            if (_searchQuery.isEmpty ||
                'blood pressure'.contains(_searchQuery.toLowerCase())) {
              addTrend(sysTrend, diaTrend);
            }
          }

          final sortedCategoryKeys = categories.keys.toList()
            ..sort((a, b) {
              if (a == 'Other Biomarkers') return 1;
              if (b == 'Other Biomarkers') return -1;
              return a.compareTo(b);
            });

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.search,
                            color: theme.colorScheme.primary,
                          ),
                          hintText: 'Search biomarkers...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Explore Categories (Grid of Cards)
                  if (_searchQuery.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Explore Categories',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 120, // Clean height
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: sortedCategoryKeys
                            .where((k) => k != 'Other Biomarkers')
                            .length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final key = sortedCategoryKeys
                              .where((k) => k != 'Other Biomarkers')
                              .toList()[index];
                          final count = categories[key]!.length;
                          return _buildCategorySquare(
                            key,
                            count,
                            categories[key]!,
                            theme,
                          );
                        },
                      ),
                    ),

                    // Long Rectangular Card for Other Biomarkers
                    if (categories.containsKey('Other Biomarkers')) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _CategoryDetailScreen(
                                  category: 'Other Biomarkers',
                                  bundleList: categories['Other Biomarkers']!,
                                  color: _getCategoryColor(
                                    'Other Biomarkers',
                                    theme,
                                  ),
                                  icon: Icons.biotech_rounded,
                                  onOpenDetail: _openDetail,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(
                                      'Other Biomarkers',
                                      theme,
                                    ).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.biotech_rounded,
                                    color: _getCategoryColor(
                                      'Other Biomarkers',
                                      theme,
                                    ),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Other Biomarkers',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${categories['Other Biomarkers']!.length} additional metrics',
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: theme.colorScheme.outline,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 36),
                  ],

                  // Pinned or Search Results
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Search Results'
                              : 'Pinned Favorites',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_searchQuery.isNotEmpty) ...[
                    // Just show a flat list of everything if searching
                    ...categories.values.expand((element) => element).map((
                      bundle,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: _buildMetricCard(
                          bundle['primary'],
                          bundle['secondary'],
                          theme,
                        ),
                      );
                    }),
                  ] else if (pinned.isNotEmpty) ...[
                    // Pinned List in modern cards
                    ...pinned.map((bundle) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: _buildMetricCard(
                          bundle['primary'],
                          bundle['secondary'],
                          theme,
                        ),
                      );
                    }),
                  ] else ...[
                    // Pinned Favorites Empty State - Premium Rectangular Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.push_pin_rounded,
                                color: theme.colorScheme.primary,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No Pinned Metrics',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the star icon on any chart to pin your most important health metrics here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  if (_searchQuery.isEmpty) ...[
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'All Biomarkers',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sortedCategoryKeys.map((key) {
                      final bundleList = categories[key]!;
                      final color = _getCategoryColor(key, theme);
                      final icon = _getCategoryIconData(key);
                      final shortName = key.contains('(')
                          ? key.split('(')[1].replaceAll(')', '')
                          : key;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(19),
                            clipBehavior: Clip.antiAlias,
                            child: Theme(
                              data: theme.copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: color, size: 24),
                                ),
                                title: Text(
                                  shortName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  '${bundleList.length} metrics tracked',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                                childrenPadding: const EdgeInsets.only(
                                  bottom: 16,
                                ),
                                children: bundleList.map((bundle) {
                                  return _buildMetricRow(
                                    bundle['primary'],
                                    bundle['secondary'],
                                    theme,
                                    color,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading trends: $e')),
      ),
    );
  }

  Widget _buildCategorySquare(
    String category,
    int count,
    List<dynamic> bundleList,
    ThemeData theme,
  ) {
    final color = _getCategoryColor(category, theme);
    final icon = _getCategoryIconData(category);

    // Convert 'Complete Blood Count (CBC)' to 'CBC' for the small card
    final shortName = category.contains('(')
        ? category.split('(')[1].replaceAll(')', '')
        : category;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _CategoryDetailScreen(
              category: category,
              bundleList: bundleList,
              color: color,
              icon: icon,
              onOpenDetail: _openDetail,
            ),
          ),
        );
      },
      child: Container(
        width: 110, // Increased width slightly for better text fitting
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                shortName,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontWeight: FontWeight.w600, // Less bold to fit better
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BiomarkerTrendModel trend,
    BiomarkerTrendModel? secondaryTrend,
    ThemeData theme,
  ) {
    final dataPoints = List<TrendDataPoint>.from(trend.dataPoints)
      ..sort((a, b) => a.date.compareTo(b.date));
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    final latest = dataPoints.last;
    final isAbnormal = latest.isAbnormal == true;
    final unitString = trend.unit != null ? ' ${trend.unit}' : '';
    final name = secondaryTrend != null ? 'Blood Pressure' : trend.name;

    String displayValue = latest.value.toStringAsFixed(1);
    if (secondaryTrend != null) {
      final secData = List<TrendDataPoint>.from(secondaryTrend.dataPoints)
        ..sort((a, b) => a.date.compareTo(b.date));
      if (secData.isNotEmpty) {
        displayValue = '${latest.value.toInt()}/${secData.last.value.toInt()}';
      }
    }

    final catColor = _getCategoryColor(_getCategory(name), theme);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAbnormal
              ? Colors.red.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(trend, secondaryTrend),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAbnormal
                        ? Colors.red.withValues(alpha: 0.15)
                        : catColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAbnormal
                        ? Icons.warning_rounded
                        : _getCategoryIconData(_getCategory(name)),
                    color: isAbnormal ? Colors.red : catColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            displayValue,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isAbnormal
                                  ? Colors.red
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          if (trend.unit != null) ...[
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                unitString,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 45,
                    child: _buildSparkline(
                      dataPoints,
                      theme,
                      isAbnormal,
                      catColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BiomarkerTrendModel trend,
    BiomarkerTrendModel? secondaryTrend,
    ThemeData theme,
    Color catColor,
  ) {
    final dataPoints = List<TrendDataPoint>.from(trend.dataPoints)
      ..sort((a, b) => a.date.compareTo(b.date));
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    final latest = dataPoints.last;
    final isAbnormal = latest.isAbnormal == true;
    final unitString = trend.unit != null ? ' ${trend.unit}' : '';
    final name = secondaryTrend != null ? 'Blood Pressure' : trend.name;

    String displayValue = latest.value.toStringAsFixed(1);
    if (secondaryTrend != null) {
      final secData = List<TrendDataPoint>.from(secondaryTrend.dataPoints)
        ..sort((a, b) => a.date.compareTo(b.date));
      if (secData.isNotEmpty) {
        displayValue = '${latest.value.toInt()}/${secData.last.value.toInt()}';
      }
    }

    return InkWell(
      onTap: () => _openDetail(trend, secondaryTrend),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        displayValue,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isAbnormal
                              ? Colors.red
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (trend.unit != null) ...[
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            unitString,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 40,
                child: _buildSparkline(dataPoints, theme, isAbnormal, catColor),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.outline,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(
    BiomarkerTrendModel trend,
    BiomarkerTrendModel? secondary,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MetricDetailScreen(trend: trend, secondaryTrend: secondary),
      ),
    );
    _loadPinned(); // Refresh in case they unpinned
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_graph_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Trends Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload a lab report with numeric results and verify the AI extraction to start tracking your health trends automatically.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparkline(
    List<TrendDataPoint> dataPoints,
    ThemeData theme,
    bool isAbnormal,
    Color catColor,
  ) {
    if (dataPoints.length < 2) return const SizedBox.shrink();

    double minY = dataPoints.first.value;
    double maxY = dataPoints.first.value;
    for (var p in dataPoints) {
      if (p.value < minY) minY = p.value;
      if (p.value > maxY) maxY = p.value;
    }

    final padding = (maxY - minY) * 0.1;
    minY = minY - padding;
    maxY = maxY + padding;
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    final spots = dataPoints
        .map((p) => FlSpot(p.date.millisecondsSinceEpoch.toDouble(), p.value))
        .toList();

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX:
            dataPoints.first.date.millisecondsSinceEpoch.toDouble() ==
                dataPoints.last.date.millisecondsSinceEpoch.toDouble()
            ? dataPoints.first.date.millisecondsSinceEpoch.toDouble() - 86400000
            : dataPoints.first.date.millisecondsSinceEpoch.toDouble(),
        maxX:
            dataPoints.first.date.millisecondsSinceEpoch.toDouble() ==
                dataPoints.last.date.millisecondsSinceEpoch.toDouble()
            ? dataPoints.last.date.millisecondsSinceEpoch.toDouble() + 86400000
            : dataPoints.last.date.millisecondsSinceEpoch.toDouble(),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: isAbnormal ? Colors.red : catColor.withValues(alpha: 0.5),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

// Sub-screen for opening a Category
class _CategoryDetailScreen extends StatelessWidget {
  final String category;
  final List<dynamic> bundleList;
  final Color color;
  final IconData icon;
  final Function(BiomarkerTrendModel, BiomarkerTrendModel?) onOpenDetail;

  const _CategoryDetailScreen({
    required this.category,
    required this.bundleList,
    required this.color,
    required this.icon,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: bundleList.length,
        itemBuilder: (context, index) {
          final bundle = bundleList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: _buildDetailCard(
              bundle['primary'],
              bundle['secondary'],
              theme,
              context,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(
    BiomarkerTrendModel trend,
    BiomarkerTrendModel? secondaryTrend,
    ThemeData theme,
    BuildContext context,
  ) {
    final dataPoints = List<TrendDataPoint>.from(trend.dataPoints)
      ..sort((a, b) => a.date.compareTo(b.date));
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    final latest = dataPoints.last;
    final isAbnormal = latest.isAbnormal == true;
    final unitString = trend.unit != null ? ' ${trend.unit}' : '';
    final name = secondaryTrend != null ? 'Blood Pressure' : trend.name;

    String displayValue = latest.value.toStringAsFixed(1);
    if (secondaryTrend != null) {
      final secData = List<TrendDataPoint>.from(secondaryTrend.dataPoints)
        ..sort((a, b) => a.date.compareTo(b.date));
      if (secData.isNotEmpty) {
        displayValue = '${latest.value.toInt()}/${secData.last.value.toInt()}';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAbnormal
              ? Colors.red.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onOpenDetail(trend, secondaryTrend);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAbnormal
                        ? Colors.red.withValues(alpha: 0.15)
                        : color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAbnormal ? Icons.warning_rounded : icon,
                    color: isAbnormal ? Colors.red : color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            displayValue,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isAbnormal
                                  ? Colors.red
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          if (trend.unit != null) ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                unitString,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines:
                                    1, // Prevent unit from wrapping weirdly
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: theme.colorScheme.outline,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
