import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/attendance/models/student_attendance_entry.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class TeacherSessionSummaryCard extends StatelessWidget {
  const TeacherSessionSummaryCard({
    super.key,
    required this.summary,
    required this.lessonTitle,
    required this.weekNumber,
  });

  final TeacherSessionSummary summary;
  final String lessonTitle;
  final int weekNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.weekNumber(weekNumber),
                      style: TextStyle(
                        color: AppColors.background.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lessonTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${summary.attendancePercent}%',
                    style: const TextStyle(
                      color: AppColors.background,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  Text(
                    l10n.attendancePercent,
                    style: TextStyle(
                      color: AppColors.background.withValues(alpha: 0.75),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: summary.total == 0
                  ? 0
                  : (summary.total - summary.unmarked) / summary.total,
              minHeight: 6,
              backgroundColor: AppColors.background.withValues(alpha: 0.2),
              color: AppColors.background,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CountPill(
                label: l10n.present,
                value: '${summary.present}',
              ),
              const SizedBox(width: 6),
              _CountPill(
                label: l10n.late,
                value: '${summary.late}',
              ),
              const SizedBox(width: 6),
              _CountPill(
                label: l10n.absent,
                value: '${summary.absent}',
              ),
              const SizedBox(width: 6),
              _CountPill(
                label: l10n.heatmapOnline,
                value: '${summary.online}',
              ),
            ],
          ),
          if (summary.unmarked > 0) ...[
            const SizedBox(height: 10),
            Text(
              l10n.studentsUnmarked(summary.unmarked),
              style: TextStyle(
                color: AppColors.background.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.background.withValues(alpha: 0.8),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
