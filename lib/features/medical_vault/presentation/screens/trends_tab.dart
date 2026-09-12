import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/trends_provider.dart';
import '../../data/models/biomarker_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'metric_detail_screen.dart';
import 'category_detail_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class TrendsTab extends ConsumerStatefulWidget {
  final Widget? bottomWidget;
  const TrendsTab({super.key, this.bottomWidget});

  @override
  ConsumerState<TrendsTab> createState() => _TrendsTabState();
}

class _TrendsTabState extends ConsumerState<TrendsTab> {
  List<String> _pinnedMetrics = [];
  String _searchQuery = '';

  List<BiomarkerTrendModel> _getConcerningBiomarkers(
    List<BiomarkerTrendModel> trends,
  ) {
    final now = DateTime.now();
    return trends.where((t) {
      if (t.dataPoints.isEmpty) return false;
      final latest = t.dataPoints.reduce(
        (a, b) => a.date.isAfter(b.date) ? a : b,
      );
      if (latest.isAbnormal == true) {
        if (now.difference(latest.date).inDays <= 180) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  Widget _buildConcerningBubble(
    List<BiomarkerTrendModel> concerning,
    ThemeData theme,
  ) {
    if (concerning.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            _showConcerningBottomSheet(context, concerning, theme);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.error.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  '${concerning.length} ${concerning.length == 1 ? 'Metric Needs' : 'Metrics Need'} Review',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConcerningBottomSheet(
    BuildContext context,
    List<BiomarkerTrendModel> concerning,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(
                        alpha: 0.4,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.assignment_late_outlined,
                      color: theme.colorScheme.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requires Attention',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Out of optimal range in recent reports',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...concerning.map((trend) {
                final latest = trend.dataPoints.reduce(
                  (a, b) => a.date.isAfter(b.date) ? a : b,
                );
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MetricDetailScreen(
                          trend: trend,
                          secondaryTrend: null,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trend.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM d, yyyy').format(latest.date),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${latest.value.toStringAsFixed(1)} ${trend.unit ?? ''}',
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

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
          final concerning = _getConcerningBiomarkers(trends);
          // Removed empty state early return so categories always show

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

          final allCategories = [
            'Lipids & Heart Health',
            'Metabolic',
            'Vitals & Measurements',
            'Liver Function (LFT)',
            'Kidney Function (KFT)',
            'Blood Count (CBC)',
            'Electrolytes & Minerals',
            'Vitamins & Hormones',
            'Other Biomarkers',
          ];
          for (final c in allCategories) {
            categories.putIfAbsent(c, () => []);
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
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.15,
                              ),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.search,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                                size: 20,
                              ),
                              hintText: 'Search biomarkers...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Explore Categories
                      if (_searchQuery.isEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Explore Categories',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height:
                              110, // Reduced height since icons/text are smaller
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            scrollDirection: Axis.horizontal,
                            itemCount: sortedCategoryKeys
                                .where((k) => k != 'Other Biomarkers')
                                .length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 16),
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
                                    builder: (_) => CategoryDetailScreen(
                                      category: 'Other Biomarkers',
                                      bundleList:
                                          categories['Other Biomarkers']!,
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
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
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
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Other Biomarkers',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${categories['Other Biomarkers']!.length} additional metrics',
                                            style: TextStyle(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant
                                                  .withValues(alpha: 0.6),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: theme.colorScheme.outline,
                                      size: 14,
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
                              vertical: 6,
                            ),
                            child: _buildMetricCard(
                              bundle['primary'],
                              bundle['secondary'],
                              theme,
                            ),
                          );
                        }),
                      ] else if (pinned.isNotEmpty) ...[
                        // Pinned List
                        ...pinned.map((bundle) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: _buildPinnedCard(
                              bundle['primary'],
                              bundle['secondary'],
                              theme,
                            ),
                          );
                        }),
                      ] else ...[
                        // Pinned Favorites Empty State
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.push_pin_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Pinned Metrics',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap the star icon on any chart to pin your most important health metrics here.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      if (widget.bottomWidget != null) widget.bottomWidget!,
                    ],
                  ),
                ),
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

    final shortName = category.contains('(')
        ? category.split('(')[1].replaceAll(')', '')
        : category;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryDetailScreen(
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
        width: 100,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                shortName,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedCard(
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAbnormal
              ? Colors.red.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(trend, secondaryTrend),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
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
                              color: isAbnormal
                                  ? Colors.red
                                  : theme.colorScheme.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        displayValue,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isAbnormal
                              ? Colors.red
                              : theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trend.unit != null) ...[
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          unitString,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: _buildSparkline(
                    dataPoints,
                    theme,
                    isAbnormal,
                    catColor,
                    isExpanded: true,
                  ),
                ),
              ],
            ),
          ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAbnormal
              ? Colors.red.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(trend, secondaryTrend),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon indicator
                Container(
                  padding: const EdgeInsets.all(8),
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
                    color: isAbnormal ? Colors.red : theme.colorScheme.primary,
                    size: 16,
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            displayValue,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
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
                                  fontSize: 10,
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
                    height: 35,
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
    _loadPinned();
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_graph_rounded,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Trends Yet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload a lab report with numeric results and verify the AI extraction to start tracking your health trends automatically.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (widget.bottomWidget != null) widget.bottomWidget!,
        ],
      ),
    );
  }

  Widget _buildSparkline(
    List<TrendDataPoint> dataPoints,
    ThemeData theme,
    bool isAbnormal,
    Color catColor, {
    bool isExpanded = false,
  }) {
    if (dataPoints.length < 2) return const SizedBox.shrink();

    double minY = dataPoints.first.value;
    double maxY = dataPoints.first.value;
    for (var p in dataPoints) {
      if (p.value < minY) minY = p.value;
      if (p.value > maxY) maxY = p.value;
    }

    final rLow = dataPoints.last.rangeLow;
    final rHigh = dataPoints.last.rangeHigh;
    if (isExpanded && rLow != null && rHigh != null) {
      if (rLow < minY) minY = rLow;
      if (rHigh > maxY) maxY = rHigh;
    }

    final padding = (maxY - minY) * 0.15;
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
        gridData: FlGridData(
          show: isExpanded && (rLow == null || rHigh == null),
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 2 == 0 ? 1 : (maxY - minY) / 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          show: isExpanded,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: dataPoints.length > 1
                  ? (dataPoints.last.date.millisecondsSinceEpoch -
                            dataPoints.first.date.millisecondsSinceEpoch) /
                        (dataPoints.length > 3 ? 3 : dataPoints.length)
                            .toDouble()
                  : 86400000,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max)
                  return const SizedBox.shrink();
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MMM d').format(date),
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        rangeAnnotations: (isExpanded && rLow != null && rHigh != null)
            ? RangeAnnotations(
                horizontalRangeAnnotations: [
                  HorizontalRangeAnnotation(
                    y1: rLow,
                    y2: rHigh,
                    color: Colors.green.withValues(alpha: 0.1),
                  ),
                ],
              )
            : const RangeAnnotations(),
        extraLinesData: (isExpanded && rLow != null && rHigh != null)
            ? ExtraLinesData(
                extraLinesOnTop: false,
                horizontalLines: [
                  HorizontalLine(
                    y: rLow,
                    color: Colors.green.withValues(alpha: 0.4),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                  HorizontalLine(
                    y: rHigh,
                    color: Colors.green.withValues(alpha: 0.4),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ],
              )
            : const ExtraLinesData(),
        lineTouchData: const LineTouchData(
          enabled: false,
        ), // Keep false to allow card tap
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: isAbnormal ? Colors.red : theme.colorScheme.primary,
            barWidth: isExpanded ? 3 : 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: isExpanded,
              getDotPainter: (spot, percent, barData, index) {
                final p = dataPoints[index];

                bool isHigh = false;
                bool isLow = false;

                if (rHigh != null && p.value > rHigh) {
                  isHigh = true;
                } else if (rLow != null && p.value < rLow) {
                  isLow = true;
                } else if (p.isAbnormal == true) {
                  isHigh = true;
                }

                if (isHigh) {
                  return FlDotCirclePainter(
                    radius: 4.5,
                    color: Colors.red,
                    strokeWidth: 0,
                    strokeColor: Colors.red,
                  );
                } else if (isLow) {
                  return FlDotCirclePainter(
                    radius: 4.5,
                    color: theme.colorScheme.surface,
                    strokeWidth: 2,
                    strokeColor: Colors.red,
                  );
                } else {
                  return FlDotCirclePainter(
                    radius: 3.5,
                    color: theme.colorScheme.primary,
                    strokeWidth: 0,
                    strokeColor: theme.colorScheme.primary,
                  );
                }
              },
            ),
            belowBarData: BarAreaData(
              show: isExpanded,
              gradient: LinearGradient(
                colors: [
                  (isAbnormal ? Colors.red : theme.colorScheme.primary)
                      .withValues(alpha: 0.3),
                  (isAbnormal ? Colors.red : theme.colorScheme.primary)
                      .withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
