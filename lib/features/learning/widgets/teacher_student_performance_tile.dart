import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class TeacherStudentPerformanceTile extends StatelessWidget {
  const TeacherStudentPerformanceTile({
    super.key,
    required this.entry,
  });

  final StudentPerformanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final needsAttention = entry.needsAttention;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: needsAttention
                ? const Color(0xFFE65100).withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.1),
          ),
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
          children: [
            Row(
              children: [
                _RankBadge(rank: entry.rank),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.overallScoreLabel(entry.overallScore),
                        style: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (needsAttention)
                  Icon(
                    Icons.flag_outlined,
                    size: 18,
                    color: const Color(0xFFE65100).withValues(alpha: 0.8),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Metric(
                  label: l10n.attendancePercent,
                  value: '${entry.attendancePercent}%',
                ),
                _Metric(
                  label: l10n.lessons,
                  value: l10n.lessonsProgress(
                    entry.lessonsCompleted,
                    entry.lessonsTotal,
                  ),
                ),
                _Metric(
                  label: l10n.quizzes,
                  value: '${entry.quizAvgScore}%',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.assignmentsProgress(
                entry.assignmentsSubmitted,
                entry.assignmentsTotal,
              ),
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final color = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.primary,
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: rank <= 3 ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(
            color: rank <= 3 ? color.withValues(alpha: 0.9) : AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text.withValues(alpha: 0.45),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
