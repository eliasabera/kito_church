import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/attendance/models/attendance_session.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class AttendanceHeatmap extends StatelessWidget {
  const AttendanceHeatmap({
    super.key,
    required this.cells,
    this.onCellTap,
  });

  final List<HeatmapCell> cells;
  final void Function(HeatmapCell cell)? onCellTap;

  static Color colorFor(WeekAttendanceStatus status) {
    return switch (status) {
      WeekAttendanceStatus.present => AppColors.primary,
      WeekAttendanceStatus.online => const Color(0xFF3D8FD1),
      WeekAttendanceStatus.late => const Color(0xFF7EB8E8),
      WeekAttendanceStatus.pending => const Color(0xFFB8D4EF),
      WeekAttendanceStatus.missed => const Color(0xFFD0D0D0),
      WeekAttendanceStatus.future => const Color(0xFFE8EEF4),
      WeekAttendanceStatus.noLesson => const Color(0xFFF0F0F0),
    };
  }

  static String labelFor(WeekAttendanceStatus status, AppLocalizations l10n) {
    return switch (status) {
      WeekAttendanceStatus.present => l10n.heatmapPresent,
      WeekAttendanceStatus.online => l10n.heatmapOnline,
      WeekAttendanceStatus.late => l10n.heatmapLate,
      WeekAttendanceStatus.pending => l10n.heatmapPending,
      WeekAttendanceStatus.missed => l10n.heatmapMissed,
      WeekAttendanceStatus.future => l10n.heatmapFuture,
      WeekAttendanceStatus.noLesson => l10n.heatmapNoLesson,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.attendanceHeatmap,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.attendanceHeatmapHint,
          style: TextStyle(
            color: AppColors.text.withValues(alpha: 0.5),
            fontSize: 12,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: cells.length,
          itemBuilder: (context, index) {
            final cell = cells[index];
            return _HeatmapCellTile(
              cell: cell,
              onTap: onCellTap == null ? null : () => onCellTap!(cell),
            );
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: WeekAttendanceStatus.values.map((status) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorFor(status),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  labelFor(status, l10n),
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _HeatmapCellTile extends StatelessWidget {
  const _HeatmapCellTile({required this.cell, this.onTap});

  final HeatmapCell cell;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = AttendanceHeatmap.colorFor(cell.status);
    final day = cell.sessionDate.day;
    final month = _monthShort(cell.sessionDate.month);

    return Tooltip(
      message: cell.weekNumber != null
          ? '${l10n.weekNumber(cell.weekNumber!)} · ${AttendanceHeatmap.labelFor(cell.status, l10n)}'
          : '$month $day · ${AttendanceHeatmap.labelFor(cell.status, l10n)}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (cell.weekNumber != null)
                  Text(
                    'W${cell.weekNumber}',
                    style: TextStyle(
                      color: _textColorFor(cell.status),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                Text(
                  '$month $day',
                  style: TextStyle(
                    color: _textColorFor(cell.status),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _textColorFor(WeekAttendanceStatus status) {
    return switch (status) {
      WeekAttendanceStatus.present ||
      WeekAttendanceStatus.online ||
      WeekAttendanceStatus.late =>
        AppColors.background,
      _ => AppColors.text.withValues(alpha: 0.55),
    };
  }

  String _monthShort(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}
