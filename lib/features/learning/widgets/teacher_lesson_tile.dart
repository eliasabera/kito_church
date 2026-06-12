import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class TeacherLessonTile extends StatelessWidget {
  const TeacherLessonTile({
    super.key,
    required this.lesson,
    this.onTap,
  });

  final TeacherLesson lesson;
  final VoidCallback? onTap;

  static Color statusColor(TeacherLessonStatus status) {
    return switch (status) {
      TeacherLessonStatus.draft => const Color(0xFF9E9E9E),
      TeacherLessonStatus.published => const Color(0xFF3D8FD1),
      TeacherLessonStatus.active => AppColors.primary,
      TeacherLessonStatus.closed => const Color(0xFF004A85),
    };
  }

  static String statusLabel(TeacherLessonStatus status, AppLocalizations l10n) {
    return switch (status) {
      TeacherLessonStatus.draft => l10n.lessonStatusDraft,
      TeacherLessonStatus.published => l10n.lessonStatusPublished,
      TeacherLessonStatus.active => l10n.lessonStatusActive,
      TeacherLessonStatus.closed => l10n.lessonStatusClosed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final posted = DateFormat.MMMd(locale).format(lesson.postedDate);
    final deadline = DateFormat.MMMd(locale).format(lesson.deadline);
    final color = statusColor(lesson.status);
    final showProgress = lesson.status != TeacherLessonStatus.draft;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
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
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'W${lesson.weekNumber}',
                          style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.ageRange(lesson.minAge, lesson.maxAge),
                            style: TextStyle(
                              color: AppColors.text.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel(lesson.status, l10n),
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.calendar_today_outlined,
                      label: l10n.postedOn(posted),
                    ),
                    const SizedBox(width: 8),
                    _MetaChip(
                      icon: Icons.event_outlined,
                      label: l10n.deadlineOn(deadline),
                    ),
                  ],
                ),
                if (lesson.hasQuiz || lesson.hasAssignment) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (lesson.hasQuiz)
                        _AttachmentChip(
                          icon: Icons.quiz_outlined,
                          label: l10n.quizzes,
                        ),
                      if (lesson.hasAssignment)
                        _AttachmentChip(
                          icon: Icons.assignment_outlined,
                          label: l10n.assignments,
                        ),
                    ],
                  ),
                ],
                if (showProgress) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: lesson.studentsTotal == 0
                                ? 0
                                : lesson.studentsCompleted /
                                    lesson.studentsTotal,
                            minHeight: 6,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.studentsCompletedCount(
                          lesson.studentsCompleted,
                          lesson.studentsTotal,
                        ),
                        style: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.55),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.text.withValues(alpha: 0.4)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.text.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
