import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/services/teacher_lessons_store.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class TeacherLessonFilterBar extends StatelessWidget {
  const TeacherLessonFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TeacherLessonFilter value;
  final ValueChanged<TeacherLessonFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final options = [
      (TeacherLessonFilter.all, l10n.all),
      (TeacherLessonFilter.active, l10n.lessonStatusActive),
      (TeacherLessonFilter.published, l10n.lessonStatusPublished),
      (TeacherLessonFilter.draft, l10n.lessonStatusDraft),
      (TeacherLessonFilter.closed, l10n.lessonStatusClosed),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _FilterChip(
              label: options[i].$2,
              selected: value == options[i].$1,
              onTap: () => onChanged(options[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.background : AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
