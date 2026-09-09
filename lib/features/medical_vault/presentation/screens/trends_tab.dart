import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
    if (name.contains('cholesterol') || name.contains('hdl') || name.contains('ldl') || name.contains('triglyceride')) {
      return 'Lipids & Heart Health';
    }
    if (name.contains('glucose') || name.contains('hba1c') || name.contains('insulin')) {
      return 'Metabolic';
    }
    if (name.contains('pressure') || name.contains('heart rate') || name.contains('weight') || name.contains('bmi')) {
      return 'Vitals & Measurements';
    }
    if (name.contains('alt') || name.contains('ast') || name.contains('alp') || name.contains('bilirubin') || name.contains('protein')) {
      return 'Liver & Kidneys';
    }
    if (name.contains('white blood') || name.contains('red blood') || name.contains('hemoglobin') || name.contains('platelet') || name.contains('hematocrit')) {
      return 'Complete Blood Count (CBC)';
    }
    return 'Other Biomarkers';
  }

  @override
  Widget build(BuildContext context) {
    final trendsAsync = ref.watch(biomarkerTrendsProvider);

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
            if (t.name.toLowerCase().contains('systolic')) sysTrend = t;
            else if (t.name.toLowerCase().contains('diastolic')) diaTrend = t;
            else processedTrends[t.name] = t;
          }

          // Grouping
          final pinned = <dynamic>[];
          final categories = <String, List<dynamic>>{};

          void addTrend(BiomarkerTrendModel t, [BiomarkerTrendModel? secondary]) {
            final bundle = {'primary': t, 'secondary': secondary};
            final name = secondary != null ? 'Blood Pressure' : t.name;
            
            if (_pinnedMetrics.contains(name)) {
              pinned.add(bundle);
            }
            final cat = _getCategory(name);
            categories.putIfAbsent(cat, () => []).add(bundle);
          }

          for (final t in processedTrends.values) {
            addTrend(t);
          }
          if (sysTrend != null) {
            addTrend(sysTrend, diaTrend);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pinned.isNotEmpty) ...[
                _buildSectionHeader('📌 Pinned Favorites', context),
                const SizedBox(height: 12),
                ...pinned.map((bundle) => _SummaryTile(
                      trend: bundle['primary'],
                      secondaryTrend: bundle['secondary'],
                      onTap: () => _openDetail(bundle['primary'], bundle['secondary']),
                    )),
                const SizedBox(height: 24),
              ],
              ...categories.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(entry.key, context),
                    const SizedBox(height: 12),
                    ...entry.value.map((bundle) => _SummaryTile(
                          trend: bundle['primary'],
                          secondaryTrend: bundle['secondary'],
                          onTap: () => _openDetail(bundle['primary'], bundle['secondary']),
                        )),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading trends: $e')),
      ),
    );
  }

  void _openDetail(BiomarkerTrendModel trend, BiomarkerTrendModel? secondary) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MetricDetailScreen(trend: trend, secondaryTrend: secondary),
    ));
    _loadPinned(); // Refresh in case they unpinned
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_graph_rounded, size: 80, color: Theme.of(context).colorScheme.surfaceContainerHighest),
            const SizedBox(height: 24),
            Text(
              'No Trends Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a lab report with numeric results and verify the AI extraction to start tracking your health trends automatically.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final BiomarkerTrendModel trend;
  final BiomarkerTrendModel? secondaryTrend;
  final VoidCallback onTap;

  const _SummaryTile({required this.trend, this.secondaryTrend, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataPoints = List<TrendDataPoint>.from(trend.dataPoints)..sort((a, b) => a.date.compareTo(b.date));
    
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    final latest = dataPoints.last;
    final isAbnormal = latest.isAbnormal == true;
    final unitString = trend.unit != null ? ' ${trend.unit}' : '';

    String displayValue = latest.value.toStringAsFixed(1);
    if (secondaryTrend != null) {
      final secData = List<TrendDataPoint>.from(secondaryTrend!.dataPoints)..sort((a, b) => a.date.compareTo(b.date));
      if (secData.isNotEmpty) {
        displayValue = '${latest.value.toInt()}/${secData.last.value.toInt()}';
      }
    }

    final name = secondaryTrend != null ? 'Blood Pressure' : trend.name;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          displayValue,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isAbnormal ? theme.colorScheme.error : null,
                          ),
                        ),
                        if (trend.unit != null)
                          Text(
                            unitString,
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 40,
                  child: _buildSparkline(dataPoints, theme, isAbnormal),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSparkline(List<TrendDataPoint> dataPoints, ThemeData theme, bool isAbnormal) {
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
        minX: dataPoints.first.date.millisecondsSinceEpoch.toDouble() == dataPoints.last.date.millisecondsSinceEpoch.toDouble() 
            ? dataPoints.first.date.millisecondsSinceEpoch.toDouble() - 86400000 
            : dataPoints.first.date.millisecondsSinceEpoch.toDouble(),
        maxX: dataPoints.first.date.millisecondsSinceEpoch.toDouble() == dataPoints.last.date.millisecondsSinceEpoch.toDouble() 
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
            color: isAbnormal ? theme.colorScheme.error : theme.colorScheme.primary.withValues(alpha: 0.5),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
