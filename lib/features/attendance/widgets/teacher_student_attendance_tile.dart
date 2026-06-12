import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/attendance/models/attendance_record.dart';
import 'package:kitoapp/features/attendance/models/student_attendance_entry.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class TeacherStudentAttendanceTile extends StatelessWidget {
  const TeacherStudentAttendanceTile({
    super.key,
    required this.student,
    required this.onMark,
    this.readOnly = false,
  });

  final StudentAttendanceEntry student;
  final void Function(AttendanceStatus status) onMark;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final initial = student.name.isNotEmpty ? student.name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _StatusBadge(
                            label: _physicalLabel(student, l10n),
                            color: _physicalColor(student),
                          ),
                          if (student.onlineMarked)
                            _StatusBadge(
                              label: l10n.heatmapOnline,
                              color: const Color(0xFF3D8FD1),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!readOnly) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MarkButton(
                      label: l10n.present,
                      icon: Icons.check_circle_outline,
                      selected:
                          student.physicalStatus == AttendanceStatus.present,
                      color: AppColors.primary,
                      onTap: () => onMark(AttendanceStatus.present),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MarkButton(
                      label: l10n.late,
                      icon: Icons.schedule,
                      selected: student.physicalStatus == AttendanceStatus.late,
                      color: const Color(0xFF3D8FD1),
                      onTap: () => onMark(AttendanceStatus.late),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MarkButton(
                      label: l10n.absent,
                      icon: Icons.cancel_outlined,
                      selected:
                          student.physicalStatus == AttendanceStatus.absent,
                      color: const Color(0xFF9E9E9E),
                      onTap: () => onMark(AttendanceStatus.absent),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _physicalLabel(StudentAttendanceEntry student, AppLocalizations l10n) {
    if (!student.isMarked) return l10n.notMarked;
    return switch (student.physicalStatus) {
      AttendanceStatus.present => l10n.present,
      AttendanceStatus.late => l10n.late,
      AttendanceStatus.absent => l10n.absent,
      null => l10n.notMarked,
    };
  }

  Color _physicalColor(StudentAttendanceEntry student) {
    if (!student.isMarked) return const Color(0xFFB8D4EF);
    return switch (student.physicalStatus) {
      AttendanceStatus.present => AppColors.primary,
      AttendanceStatus.late => const Color(0xFF3D8FD1),
      AttendanceStatus.absent => const Color(0xFF9E9E9E),
      null => const Color(0xFFB8D4EF),
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MarkButton extends StatelessWidget {
  const _MarkButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? color
                  : AppColors.primary.withValues(alpha: 0.15),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? color : AppColors.text.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : AppColors.text.withValues(alpha: 0.55),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
