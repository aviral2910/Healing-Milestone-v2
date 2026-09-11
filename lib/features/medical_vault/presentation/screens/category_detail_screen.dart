import 'package:flutter/material.dart';
import '../../data/models/biomarker_model.dart';
import 'package:fl_chart/fl_chart.dart';

// Sub-screen for opening a Category
class CategoryDetailScreen extends StatefulWidget {
  final String category;
  final List<dynamic> bundleList;
  final Color color;
  final IconData icon;
  final Function(BiomarkerTrendModel, BiomarkerTrendModel?) onOpenDetail;

  const CategoryDetailScreen({
    required this.category,
    required this.bundleList,
    required this.color,
    required this.icon,
    required this.onOpenDetail,
  });

  @override
  State<CategoryDetailScreen> createState() => CategoryDetailScreenState();
}

class CategoryDetailScreenState extends State<CategoryDetailScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredList = widget.bundleList.where((bundle) {
      if (_searchQuery.isEmpty) return true;
      final primary = bundle['primary'] as BiomarkerTrendModel;
      final name = primary.name.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                    size: 20,
                  ),
                  hintText: 'Search in ${widget.category}...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final bundle = filteredList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 6,
                  ),
                  child: _buildDetailCard(
                    bundle['primary'],
                    bundle['secondary'],
                    theme,
                    context,
                  ),
                );
              },
            ),
          ),
        ],
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
          onTap: () {
            widget.onOpenDetail(trend, secondaryTrend);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isAbnormal
                        ? Colors.red.withValues(alpha: 0.15)
                        : widget.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAbnormal ? Icons.warning_rounded : widget.icon,
                    color: isAbnormal ? Colors.red : widget.color,
                    size: 16,
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
                            const SizedBox(width: 6),
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
                const SizedBox(width: 12),
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
    );
  }
}
