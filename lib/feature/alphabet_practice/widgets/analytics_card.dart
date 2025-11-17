import 'package:flutter/material.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final List<AnalyticsStat> stats;
  final Widget? chart;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.stats,
    this.chart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Stats grid
            ...stats.map((stat) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildStatRow(context, stat),
                )),

            // Optional chart
            if (chart != null) ...[
              const SizedBox(height: 16),
              chart!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, AnalyticsStat stat) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: stat.color?.withAlpha(51) ??
                theme.colorScheme.primaryContainer.withAlpha(77),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            stat.icon,
            size: 20,
            color: stat.color ?? theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label,
                style: theme.textTheme.bodyMedium,
              ),
              if (stat.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  stat.subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(179),
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          stat.value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: stat.color ?? theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class AnalyticsStat {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;

  const AnalyticsStat({
    required this.label,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
  });
}
