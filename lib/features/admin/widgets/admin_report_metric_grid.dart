import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/data/admin_reports_data.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class AdminReportMetricGrid extends StatelessWidget {
  const AdminReportMetricGrid({
    super.key,
    required this.summary,
    required this.attendanceTrend,
    required this.scoreTrend,
    required this.completionTrend,
    required this.activeStudentsTrend,
  });

  final AdminReportsSummary summary;
  final List<int> attendanceTrend;
  final List<int> scoreTrend;
  final List<int> completionTrend;
  final List<int> activeStudentsTrend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final metrics = [
      _MetricData(
        icon: Icons.event_available_outlined,
        label: l10n.attendance,
        value: '${summary.avgAttendancePercent}%',
        subtitle: l10n.attendancePercent,
        trend: attendanceTrend,
      ),
      _MetricData(
        icon: Icons.leaderboard_outlined,
        label: l10n.scores,
        value: '${summary.avgScore}',
        subtitle: l10n.avgScore,
        trend: scoreTrend,
      ),
      _MetricData(
        icon: Icons.school_outlined,
        label: l10n.learning,
        value: '${summary.completionRate}%',
        subtitle: l10n.completionRate,
        trend: completionTrend,
      ),
      _MetricData(
        icon: Icons.people_outline,
        label: l10n.totalStudents,
        value: '${summary.activeStudents}/${summary.totalStudents}',
        subtitle: l10n.activeStudents,
        trend: activeStudentsTrend,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.keyMetrics,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 128,
            ),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              return _MetricCard(data: metrics[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.trend,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final List<int> trend;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 16, color: AppColors.primary),
              ),
              const Spacer(),
              _Sparkline(values: data.trend),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                data.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text.withValues(alpha: 0.5),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return const SizedBox.shrink();

    return SizedBox(
      width: 48,
      height: 20,
      child: CustomPaint(
        painter: _SparklinePainter(values: values),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values});

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    final min = values.reduce((a, b) => a < b ? a : b).toDouble();
    final max = values.reduce((a, b) => a > b ? a : b).toDouble();
    final range = (max - min).clamp(1, double.infinity);

    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - min) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values;
}
