import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/trends_provider.dart';

class TrendsTab extends ConsumerWidget {
  const TrendsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(biomarkerTrendsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(biomarkerTrendsProvider.notifier).refresh(),
      child: trendsAsync.when(
        data: (trends) {
          if (trends.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: trends.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _TrendCard(trend: trends[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading trends: $e')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_graph_rounded, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No trends yet',
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

class _TrendCard extends StatelessWidget {
  final dynamic trend;

  const _TrendCard({required this.trend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataPoints = List.from(trend.dataPoints)..sort((a, b) => a.date.compareTo(b.date));
    
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    final latest = dataPoints.last;
    final isAbnormal = latest.isAbnormal ?? false;
    final unitString = trend.unit != null ? ' ${trend.unit}' : '';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    trend.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAbnormal ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAbnormal ? 'Abnormal' : 'Normal',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isAbnormal ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${latest.value}$unitString',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isAbnormal ? theme.colorScheme.error : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Latest: ${DateFormat.yMMMd().format(latest.date)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            if (dataPoints.length > 1) SizedBox(
              height: 120,
              child: _buildChart(dataPoints, theme),
            ) else const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Need more data points to show a trend line.')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<dynamic> dataPoints, ThemeData theme) {
    // Determine min/max values for Y axis to scale nicely
    double minY = dataPoints.first.value;
    double maxY = dataPoints.first.value;
    for (var p in dataPoints) {
      if (p.value < minY) minY = p.value;
      if (p.value > maxY) maxY = p.value;
    }
    
    // Add 10% padding to min/max
    final padding = (maxY - minY) * 0.1;
    minY = minY - padding;
    maxY = maxY + padding;
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < dataPoints.length; i++) {
      spots.add(FlSpot(i.toDouble(), dataPoints[i].value));
    }

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: -0.2,
        maxX: (dataPoints.length - 1) + 0.2,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= dataPoints.length || value != value.toInt()) return const SizedBox.shrink();
                final p = dataPoints[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat.MMMd().format(p.date),
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final p = dataPoints[index];
                final isAbnormal = p.isAbnormal ?? false;
                return FlDotCirclePainter(
                  radius: 4,
                  color: isAbnormal ? theme.colorScheme.error : theme.colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => theme.colorScheme.inverseSurface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final p = dataPoints[spot.x.toInt()];
                return LineTooltipItem(
                  '${p.value}\n${DateFormat.yMMMd().format(p.date)}',
                  theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
