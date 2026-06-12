import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/attendance/models/attendance_record.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class AttendanceStatsBar extends StatelessWidget {
  const AttendanceStatsBar({super.key, required this.summary});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              label: l10n.physicalAttendance,
              completed: summary.physicalPresent,
              total: summary.physicalTotal,
              icon: Icons.church_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatTile(
              label: l10n.onlineAttendance,
              completed: summary.onlinePresent,
              total: summary.onlineTotal,
              icon: Icons.videocam_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatTile(
              label: l10n.late,
              completed: summary.lateCount,
              total: summary.total,
              icon: Icons.schedule_outlined,
              showProgress: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.completed,
    required this.total,
    required this.icon,
    this.showProgress = true,
  });

  final String label;
  final int completed;
  final int total;
  final IconData icon;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.65),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            showProgress
                ? l10n.completedCount(completed, total)
                : completed.toString(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
