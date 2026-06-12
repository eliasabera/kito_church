import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/attendance/models/student_attendance_entry.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class TeacherAttendanceHeader extends StatelessWidget {
  const TeacherAttendanceHeader({
    super.key,
    required this.sessions,
    required this.selectedSession,
    required this.summary,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onSessionSelected,
    required this.onPreviousSession,
    required this.onNextSession,
  });

  final List<TeacherAttendanceSession> sessions;
  final TeacherAttendanceSession selectedSession;
  final TeacherSessionSummary summary;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<String> onSessionSelected;
  final VoidCallback onPreviousSession;
  final VoidCallback onNextSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel =
        DateFormat.MMMd(locale).format(selectedSession.sessionDate);
    final ordered = sessions;
    final selectedIndex =
        ordered.indexWhere((s) => s.id == selectedSession.id);
    final canGoNewer = selectedIndex > 0;
    final canGoOlder = selectedIndex >= 0 && selectedIndex < ordered.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onToggleExpanded,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: canGoOlder ? onPreviousSession : null,
                        icon: const Icon(Icons.chevron_left),
                        color: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${l10n.weekNumber(selectedSession.weekNumber)} · $dateLabel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${summary.attendancePercent}% · ${selectedSession.lessonTitle}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.text.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: canGoNewer ? onNextSession : null,
                        icon: const Icon(Icons.chevron_right),
                        color: AppColors.primary,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        onPressed: onToggleExpanded,
                        icon: Icon(
                          expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        color: AppColors.primary,
                        tooltip: expanded
                            ? l10n.collapseDetails
                            : l10n.expandDetails,
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: sessions.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 6),
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            final selected = session.id == selectedSession.id;
                            final label = DateFormat.MMMd(locale)
                                .format(session.sessionDate);

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => onSessionSelected(session.id),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.primary
                                            .withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'W${session.weekNumber} $label',
                                    style: TextStyle(
                                      color: selected
                                          ? AppColors.background
                                          : AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatChip(
                            label: l10n.present,
                            value: '${summary.present}',
                          ),
                          const SizedBox(width: 6),
                          _StatChip(
                            label: l10n.late,
                            value: '${summary.late}',
                          ),
                          const SizedBox(width: 6),
                          _StatChip(
                            label: l10n.absent,
                            value: '${summary.absent}',
                          ),
                          const SizedBox(width: 6),
                          _StatChip(
                            label: l10n.heatmapOnline,
                            value: '${summary.online}',
                          ),
                        ],
                      ),
                      if (!selectedSession.isEditable) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: AppColors.text.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  l10n.sessionLockedHint,
                                  style: TextStyle(
                                    color: AppColors.text.withValues(alpha: 0.6),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                crossFadeState: expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.5),
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
