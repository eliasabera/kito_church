import 'package:flutter/material.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class ScoringCategoryTile extends StatelessWidget {
  const ScoringCategoryTile({
    super.key,
    required this.category,
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.maxValue,
    required this.onChanged,
  });

  final ScoringCategory category;
  final String label;
  final String hint;
  final IconData icon;
  final double value;
  final double maxValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      hint,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${value.round()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withValues(alpha: 0.15),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value.clamp(0, maxValue),
              min: 0,
              max: maxValue > 0 ? maxValue : 1,
              divisions: maxValue > 0 ? maxValue.round() : 1,
              onChanged: maxValue > 0 ? onChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}

IconData scoringCategoryIcon(ScoringCategory category) {
  return switch (category) {
    ScoringCategory.attendance => Icons.event_available_outlined,
    ScoringCategory.quiz => Icons.quiz_outlined,
    ScoringCategory.assignment => Icons.assignment_outlined,
  };
}

String scoringCategoryLabel(
  ScoringCategory category,
  AppLocalizations l10n,
) {
  return switch (category) {
    ScoringCategory.attendance => l10n.attendance,
    ScoringCategory.quiz => l10n.quizzes,
    ScoringCategory.assignment => l10n.assignments,
  };
}

String scoringCategoryHint(
  ScoringCategory category,
  AppLocalizations l10n,
) {
  return switch (category) {
    ScoringCategory.attendance => l10n.scoringAttendanceHint,
    ScoringCategory.quiz => l10n.scoringQuizHint,
    ScoringCategory.assignment => l10n.scoringAssignmentHint,
  };
}
