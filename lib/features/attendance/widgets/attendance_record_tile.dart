import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/attendance/models/attendance_record.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class AttendanceRecordTile extends StatelessWidget {
  const AttendanceRecordTile({
    super.key,
    required this.record,
    this.onTap,
    this.showMakeupAction = false,
  });

  final AttendanceRecord record;
  final VoidCallback? onTap;
  final bool showMakeupAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.MMMd(locale).format(record.date);
    final weekdayLabel = DateFormat.E(locale).format(record.date);
    final canInteract = showMakeupAction && record.needsMakeup && onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canInteract ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: canInteract
                ? AppColors.primary.withValues(alpha: 0.04)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canInteract
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.primary.withValues(alpha: 0.12),
              width: canInteract ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _DateBadge(date: dateLabel, weekday: weekdayLabel),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.sessionLabel,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _TypeChip(
                          label: record.type == AttendanceType.physical
                              ? l10n.physicalAttendance
                              : l10n.onlineAttendance,
                          icon: record.type == AttendanceType.physical
                              ? Icons.church_outlined
                              : Icons.videocam_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: record.status),
                ],
              ),
              if (canInteract) ...[
                const SizedBox(height: 10),
                _MakeupActionRow(record: record),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MakeupActionRow extends StatelessWidget {
  const _MakeupActionRow({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, icon, color) = record.canMarkOnline
        ? (
            l10n.markOnlineAttendance,
            Icons.how_to_reg_outlined,
            AppColors.primary,
          )
        : record.lessonCompleted
            ? (
                l10n.markOnlineAttendance,
                Icons.how_to_reg_outlined,
                AppColors.primary,
              )
            : (
                l10n.learnAndMark,
                Icons.menu_book_outlined,
                const Color(0xFFE65100),
              );

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            record.canMarkOnline
                ? l10n.readyToMarkAttendance
                : record.lessonCompleted
                    ? l10n.readyToMarkAttendance
                    : l10n.completeLessonToMark,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(Icons.chevron_right, size: 18, color: color),
      ],
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date, required this.weekday});

  final String date;
  final String weekday;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            weekday,
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.text.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.text.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color, icon) = switch (status) {
      AttendanceStatus.present => (
          l10n.present,
          const Color(0xFF2E7D32),
          Icons.check_circle_outline,
        ),
      AttendanceStatus.absent => (
          l10n.absent,
          const Color(0xFFC62828),
          Icons.cancel_outlined,
        ),
      AttendanceStatus.late => (
          l10n.late,
          const Color(0xFFF57C00),
          Icons.schedule_outlined,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
