import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/biomarker_model.dart';
import '../providers/trends_provider.dart';

class MetricDetailScreen extends ConsumerStatefulWidget {
  final BiomarkerTrendModel trend;
  final BiomarkerTrendModel? secondaryTrend;

  const MetricDetailScreen({
    super.key,
    required this.trend,
    this.secondaryTrend,
  });

  @override
  ConsumerState<MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends ConsumerState<MetricDetailScreen> {
  bool _isPinned = false;
  final List<BiomarkerTrendModel> _comparedTrends = [];

  @override
  void initState() {
    super.initState();
    _checkPinned();
  }

  Future<void> _checkPinned() async {
    final prefs = await SharedPreferences.getInstance();
    final pinned = prefs.getStringList('pinned_metrics') ?? [];
    final name = widget.secondaryTrend != null
        ? 'Blood Pressure'
        : widget.trend.name;
    setState(() {
      _isPinned = pinned.contains(name);
    });
  }

  Future<void> _togglePin() async {
    final prefs = await SharedPreferences.getInstance();
    final pinned = prefs.getStringList('pinned_metrics') ?? [];
    final name = widget.secondaryTrend != null
        ? 'Blood Pressure'
        : widget.trend.name;

    if (_isPinned) {
      pinned.remove(name);
    } else {
      pinned.add(name);
    }

    await prefs.setStringList('pinned_metrics', pinned);
    setState(() {
      _isPinned = !_isPinned;
    });
  }

  void _showCompareSheet() {
    final allTrendsAsync = ref.read(biomarkerTrendsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return allTrendsAsync.when(
          data: (trends) {
            final available = trends.where((t) {
              if (t.name == widget.trend.name) return false;
              if (widget.secondaryTrend != null &&
                  t.name == widget.secondaryTrend!.name)
                return false;
              if (_comparedTrends.any((c) => c.name == t.name)) return false;
              if (widget.secondaryTrend != null &&
                  (t.name.toLowerCase().contains('systolic') ||
                      t.name.toLowerCase().contains('diastolic')))
                return false;
              return true;
            }).toList();

            return _CompareBottomSheet(
              availableTrends: available,
              onSelect: (t) {
                setState(() {
                  _comparedTrends.add(t);
                });
                Navigator.pop(context);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataPoints = List<TrendDataPoint>.from(widget.trend.dataPoints)
      ..sort((a, b) => a.date.compareTo(b.date));

    final latest = dataPoints.isNotEmpty ? dataPoints.last : null;
    final isAbnormal = latest?.isAbnormal == true;

    String displayValue = latest?.value.toStringAsFixed(1) ?? '--';
    if (widget.secondaryTrend != null) {
      final secDataPoints = List<TrendDataPoint>.from(
        widget.secondaryTrend!.dataPoints,
      )..sort((a, b) => a.date.compareTo(b.date));
      if (secDataPoints.isNotEmpty) {
        displayValue =
            '${latest?.value.toInt() ?? '-'}/${secDataPoints.last.value.toInt()}';
      }
    }

    final String titleName = widget.secondaryTrend != null
        ? 'Blood Pressure'
        : widget.trend.name;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          titleName,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            onPressed: _togglePin,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isAbnormal
                        ? Colors.red.withValues(alpha: 0.3)
                        : theme.colorScheme.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latest Result',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              displayValue,
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isAbnormal
                                    ? Colors.red
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            if (widget.trend.unit != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  widget.trend.unit!,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (latest != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isAbnormal
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isAbnormal ? 'Out of Range' : 'Normal',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isAbnormal
                                    ? Colors.red
                                    : theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            DateFormat.yMMMd().format(latest.date),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historical Trend',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showCompareSheet,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Compare',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),
              if (_comparedTrends.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _comparedTrends
                      .map(
                        (t) => Chip(
                          label: Text(
                            t.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onDeleted: () {
                            setState(() {
                              _comparedTrends.remove(t);
                            });
                          },
                          deleteIcon: const Icon(Icons.close, size: 16),
                          backgroundColor: theme.colorScheme.surface,
                          side: BorderSide(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 32),
              dataPoints.length > 1
                  ? _buildStackedCharts(theme)
                  : const SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          'Not enough data points to plot a meaningful trend.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackedCharts(ThemeData theme) {
    final List<BiomarkerTrendModel> allPlottedTrends = [widget.trend];
    if (widget.secondaryTrend != null) {
      allPlottedTrends.add(widget.secondaryTrend!);
    }
    allPlottedTrends.addAll(_comparedTrends);

    double overallMinX = double.infinity;
    double overallMaxX = double.negativeInfinity;

    for (var t in allPlottedTrends) {
      if (t.dataPoints.isEmpty) continue;
      final pts = List<TrendDataPoint>.from(t.dataPoints)
        ..sort((a, b) => a.date.compareTo(b.date));
      if (pts.first.date.millisecondsSinceEpoch < overallMinX)
        overallMinX = pts.first.date.millisecondsSinceEpoch.toDouble();
      if (pts.last.date.millisecondsSinceEpoch > overallMaxX)
        overallMaxX = pts.last.date.millisecondsSinceEpoch.toDouble();
    }

    if (overallMinX >= overallMaxX) {
      overallMinX -= 86400000;
      overallMaxX += 86400000;
    }

    final List<Widget> charts = [];

    charts.add(
      _buildSingleChart(
        title: widget.secondaryTrend != null
            ? 'Blood Pressure'
            : widget.trend.name,
        trends: widget.secondaryTrend != null
            ? [widget.trend, widget.secondaryTrend!]
            : [widget.trend],
        theme: theme,
        colorIndex: 0,
        minX: overallMinX,
        maxX: overallMaxX,
        showXAxis: _comparedTrends.isEmpty,
      ),
    );

    for (int i = 0; i < _comparedTrends.length; i++) {
      charts.add(const SizedBox(height: 32));
      charts.add(
        _buildSingleChart(
          title: _comparedTrends[i].name,
          trends: [_comparedTrends[i]],
          theme: theme,
          colorIndex: i + 2,
          minX: overallMinX,
          maxX: overallMaxX,
          showXAxis: i == _comparedTrends.length - 1,
        ),
      );
    }

    return Column(children: charts);
  }

  Widget _buildSingleChart({
    required String title,
    required List<BiomarkerTrendModel> trends,
    required ThemeData theme,
    required int colorIndex,
    required double minX,
    required double maxX,
    required bool showXAxis,
  }) {
    double tMin = double.infinity;
    double tMax = double.negativeInfinity;

    final barDataList = <LineChartBarData>[];

    for (int i = 0; i < trends.length; i++) {
      final pts = List<TrendDataPoint>.from(trends[i].dataPoints)
        ..sort((a, b) => a.date.compareTo(b.date));
      for (var p in pts) {
        if (p.value < tMin) tMin = p.value;
        if (p.value > tMax) tMax = p.value;
      }

      final color = colorIndex == 0
          ? (i == 0 ? theme.colorScheme.primary : theme.colorScheme.secondary)
          : Colors.primaries[(colorIndex + i) % Colors.primaries.length];

      final spots = pts
          .map((p) => FlSpot(p.date.millisecondsSinceEpoch.toDouble(), p.value))
          .toList();

      barDataList.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: i == 0
              ? BarAreaData(show: true, color: color.withValues(alpha: 0.1))
              : null,
        ),
      );

      // Bounds extraction
      if (i == 0) {
        final highSpots = <FlSpot>[];
        final lowSpots = <FlSpot>[];
        double? defaultHigh;
        double? defaultLow;
        for (var p in pts.reversed) {
          if (p.rangeHigh != null) defaultHigh ??= p.rangeHigh;
          if (p.rangeLow != null) defaultLow ??= p.rangeLow;
        }

        if (defaultHigh != null || defaultLow != null) {
          for (var p in pts) {
            final x = p.date.millisecondsSinceEpoch.toDouble();
            final high =
                p.rangeHigh ??
                defaultHigh ??
                ((p.rangeLow ?? defaultLow ?? 0.0) * 5.0).clamp(100.0, 9999.0);
            final low = p.rangeLow ?? defaultLow ?? 0.0;

            highSpots.add(FlSpot(x, high));
            lowSpots.add(FlSpot(x, low));

            if (p.rangeHigh != null && p.rangeHigh! > tMax) tMax = p.rangeHigh!;
            if (p.rangeLow != null && p.rangeLow! < tMin) tMin = p.rangeLow!;
          }
        }

        if (highSpots.isNotEmpty && lowSpots.isNotEmpty) {
          barDataList.add(
            LineChartBarData(
              spots: highSpots,
              isCurved: true,
              color: Colors.transparent,
              barWidth: 0,
              dotData: const FlDotData(show: false),
            ),
          );
          barDataList.add(
            LineChartBarData(
              spots: lowSpots,
              isCurved: true,
              color: Colors.transparent,
              barWidth: 0,
              dotData: const FlDotData(show: false),
            ),
          );
        }
      }
    }

    if (tMin == double.infinity) return const SizedBox.shrink();

    final padding = (tMax - tMin) * 0.2;
    tMin -= padding;
    tMax += padding;
    if (tMin >= tMax) {
      tMin -= 10;
      tMax += 10;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (colorIndex != 0) ...[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.primaries[colorIndex % Colors.primaries.length],
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              betweenBarsData: barDataList.length >= 3
                  ? [
                      BetweenBarsData(
                        fromIndex: barDataList.length - 2,
                        toIndex: barDataList.length - 1,
                        color: Colors.green.withValues(alpha: 0.15),
                      ),
                    ]
                  : [],
              minY: tMin,
              maxY: tMax,
              minX: minX,
              maxX: maxX,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: showXAxis,
                    reservedSize: showXAxis ? 30 : 0,
                    getTitlesWidget: (value, meta) {
                      if (!showXAxis) return const SizedBox.shrink();
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        value.toInt(),
                      );
                      if (value == minX || value == maxX) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat.MMM().format(date),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: barDataList,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) =>
                      theme.colorScheme.surfaceContainerHighest,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        spot.x.toInt(),
                      );
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)}\n${DateFormat.yMMMd().format(date)}',
                        theme.textTheme.labelMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: barDataList[spot.barIndex].color,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompareBottomSheet extends StatefulWidget {
  final List<BiomarkerTrendModel> availableTrends;
  final Function(BiomarkerTrendModel) onSelect;

  const _CompareBottomSheet({
    required this.availableTrends,
    required this.onSelect,
  });

  @override
  State<_CompareBottomSheet> createState() => _CompareBottomSheetState();
}

class _CompareBottomSheetState extends State<_CompareBottomSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = widget.availableTrends
        .where((t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_chart_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Compare Trends',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.search,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  hintText: 'Search to compare...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.outline,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No metrics found.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => widget.onSelect(t),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    t.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.add_circle,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
