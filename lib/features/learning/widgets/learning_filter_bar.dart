import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/learning_item.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class LearningFilterBar extends StatelessWidget {
  const LearningFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final LearningItemType? value;
  final ValueChanged<LearningItemType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<LearningItemType?>(
            value: value,
            isExpanded: true,
            isDense: true,
            icon: const Icon(
              Icons.expand_more,
              color: AppColors.primary,
              size: 20,
            ),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            borderRadius: BorderRadius.circular(10),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.all)),
              DropdownMenuItem(
                value: LearningItemType.lesson,
                child: Text(l10n.lessons),
              ),
              DropdownMenuItem(
                value: LearningItemType.assignment,
                child: Text(l10n.assignments),
              ),
              DropdownMenuItem(
                value: LearningItemType.quiz,
                child: Text(l10n.quizzes),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
