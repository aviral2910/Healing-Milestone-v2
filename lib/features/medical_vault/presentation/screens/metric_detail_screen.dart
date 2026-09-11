import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/models/biomarker_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trends_provider.dart';

class MetricDetailScreen extends ConsumerStatefulWidget {
  final BiomarkerTrendModel trend;
  final BiomarkerTrendModel? secondaryTrend; // For Diastolic if it's BP

  const MetricDetailScreen({super.key, required this.trend, this.secondaryTrend});

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
    setState(() {
      _isPinned = pinned.contains(widget.trend.name);
    });
  }

  Future<void> _togglePin() async {
    final prefs = await SharedPreferences.getInstance();
    final pinned = prefs.getStringList('pinned_metrics') ?? [];
    if (_isPinned) {
      pinned.remove(widget.trend.name);
    } else {
      pinned.add(widget.trend.name);
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return allTrendsAsync.when(
              data: (trends) {
                // Filter out the current trend and currently compared ones
                final available = trends.where((t) {
                  if (t.name == widget.trend.name) return false;
                  if (widget.secondaryTrend != null && t.name == widget.secondaryTrend!.name) return false;
                  if (_comparedTrends.any((c) => c.name == t.name)) return false;
                  // Don't show raw systolic/diastolic if we are already viewing BP
                  if (widget.secondaryTrend != null && (t.name.toLowerCase().contains('systolic') || t.name.toLowerCase().contains('diastolic'))) return false;
                  return true;
                }).toList();

                if (available.isEmpty) {
                  return const Center(child: Text('No other metrics to compare.'));
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Compare with...',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: available.length,
                        itemBuilder: (context, index) {
                          final t = available[index];
                          return ListTile(
                            title: Text(t.name),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () {
                              setState(() {
                                _comparedTrends.add(t);
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            );
          },
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
      final secDataPoints = List<TrendDataPoint>.from(widget.secondaryTrend!.dataPoints)
        ..sort((a, b) => a.date.compareTo(b.date));
      if (secDataPoints.isNotEmpty) {
        displayValue = '${latest?.value.toInt() ?? '-'}/${secDataPoints.last.value.toInt()}';
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.secondaryTrend != null ? 'Blood Pressure' : widget.trend.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? theme.colorScheme.primary : null,
            ),
            onPressed: _togglePin,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isAbnormal
                      ? theme.colorScheme.errorContainer.withValues(alpha: 0.5)
                      : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
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
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              displayValue,
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isAbnormal ? theme.colorScheme.error : theme.colorScheme.primary,
                              ),
                            ),
                            if (widget.trend.unit != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  widget.trend.unit!,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isAbnormal ? theme.colorScheme.error : theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isAbnormal ? 'Out of Range' : 'Normal',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isAbnormal ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            DateFormat.yMMMd().format(latest.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _showCompareSheet,
                    icon: const Icon(Icons.add),
                    label: const Text('Compare'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
              if (_comparedTrends.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _comparedTrends.map((t) => Chip(
                    label: Text(t.name),
                    onDeleted: () {
                      setState(() {
                        _comparedTrends.remove(t);
                      });
                    },
                    deleteIcon: const Icon(Icons.close, size: 18),
                  )).toList(),
                ),
              ],
              const SizedBox(height: 24),
              dataPoints.length > 1
                  ? _buildStackedCharts(theme)
                  : const SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          'Not enough data points to plot a meaningful trend.',
                          style: TextStyle(color: Colors.grey),
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
    final allPlottedTrends = <BiomarkerTrendModel>[];
    allPlottedTrends.add(widget.trend);
    if (widget.secondaryTrend != null) {
      allPlottedTrends.add(widget.secondaryTrend!);
    }
    allPlottedTrends.addAll(_comparedTrends);

    double overallMinX = double.infinity;
    double overallMaxX = double.negativeInfinity;
    
    for (var t in allPlottedTrends) {
      if (t.dataPoints.isEmpty) continue;
      final pts = List<TrendDataPoint>.from(t.dataPoints)..sort((a, b) => a.date.compareTo(b.date));
      if (pts.first.date.millisecondsSinceEpoch < overallMinX) overallMinX = pts.first.date.millisecondsSinceEpoch.toDouble();
      if (pts.last.date.millisecondsSinceEpoch > overallMaxX) overallMaxX = pts.last.date.millisecondsSinceEpoch.toDouble();
    }
    
    if (overallMinX >= overallMaxX) {
      overallMinX -= 86400000;
      overallMaxX += 86400000;
    }

    final List<Widget> charts = [];
    
    charts.add(
      _buildSingleChart(
        title: widget.secondaryTrend != null ? 'Blood Pressure' : widget.trend.name,
        trends: widget.secondaryTrend != null ? [widget.trend, widget.secondaryTrend!] : [widget.trend],
        theme: theme,
        colorIndex: 0,
        minX: overallMinX,
        maxX: overallMaxX,
        showXAxis: _comparedTrends.isEmpty,
      )
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
        )
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
      final pts = List<TrendDataPoint>.from(trends[i].dataPoints)..sort((a, b) => a.date.compareTo(b.date));
      for (var p in pts) {
        if (p.value < tMin) tMin = p.value;
        if (p.value > tMax) tMax = p.value;
      }
      
      final color = colorIndex == 0 
          ? (i == 0 ? theme.colorScheme.primary : theme.colorScheme.secondary)
          : Colors.primaries[(colorIndex + i) % Colors.primaries.length];

      final spots = pts.map((p) => FlSpot(p.date.millisecondsSinceEpoch.toDouble(), p.value)).toList();
      
      barDataList.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: i == 0 ? BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.1),
        ) : null,
      ));
      
      // If this is the primary trend, let's extract the Range High/Low spots
      if (i == 0) {
        final highSpots = <FlSpot>[];
        final lowSpots = <FlSpot>[];
        // 1. Find standard bounds for this metric across all time
        double? defaultHigh;
        double? defaultLow;
        for (var p in pts.reversed) {
          if (p.rangeHigh != null) defaultHigh ??= p.rangeHigh;
          if (p.rangeLow != null) defaultLow ??= p.rangeLow;
        }

        // 2. Draw the river continuously across all data points
        if (defaultHigh != null || defaultLow != null) {
          for (var p in pts) {
            final x = p.date.millisecondsSinceEpoch.toDouble();
            final high = p.rangeHigh ?? defaultHigh ?? ((p.rangeLow ?? defaultLow ?? 0.0) * 5.0).clamp(100.0, 9999.0);
            final low = p.rangeLow ?? defaultLow ?? 0.0;
            
            highSpots.add(FlSpot(x, high));
            lowSpots.add(FlSpot(x, low));
            
            if (p.rangeHigh != null && p.rangeHigh! > tMax) tMax = p.rangeHigh!;
            if (p.rangeLow != null && p.rangeLow! < tMin) tMin = p.rangeLow!;
          }
        }
        
        if (highSpots.isNotEmpty && lowSpots.isNotEmpty) {
          // Add High Line
          barDataList.add(LineChartBarData(
            spots: highSpots,
            isCurved: true,
            color: Colors.transparent,
            barWidth: 0,
            dotData: const FlDotData(show: false),
          ));
          // Add Low Line
          barDataList.add(LineChartBarData(
            spots: lowSpots,
            isCurved: true,
            color: Colors.transparent,
            barWidth: 0,
            dotData: const FlDotData(show: false),
          ));
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
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.primaries[colorIndex % Colors.primaries.length])),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              betweenBarsData: barDataList.length >= 3 
                  ? [
                      BetweenBarsData(
                        fromIndex: barDataList.length - 2, // High Line
                        toIndex: barDataList.length - 1,   // Low Line
                        color: Colors.green.withValues(alpha: 0.15),
                      )
                    ]
                  : [],
              minY: tMin,
              maxY: tMax,
              minX: minX,
              maxX: maxX,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), strokeWidth: 1, dashArray: [5, 5]),
                getDrawingVerticalLine: (value) => FlLine(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), strokeWidth: 1, dashArray: [5, 5]),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: showXAxis,
                    reservedSize: showXAxis ? 30 : 0,
                    getTitlesWidget: (value, meta) {
                      if (!showXAxis) return const SizedBox.shrink();
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      if (value == minX || value == maxX) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(DateFormat.MMM().format(date), style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
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
                  getTooltipColor: (spot) => theme.colorScheme.surfaceContainerHighest,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
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