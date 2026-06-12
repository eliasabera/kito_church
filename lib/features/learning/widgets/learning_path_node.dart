import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/lesson_unit.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class LearningPathNode extends StatelessWidget {
  const LearningPathNode({
    super.key,
    required this.node,
    required this.isCurrent,
    required this.onTap,
  });

  final PathNode node;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLesson = node.type == PathNodeType.lesson;
    final size = isLesson ? 72.0 : 58.0;

    final (icon, label) = switch (node.type) {
      PathNodeType.lesson => (Icons.menu_book_rounded, l10n.lessons),
      PathNodeType.quiz => (Icons.quiz_rounded, l10n.quizzes),
      PathNodeType.assignment => (Icons.assignment_rounded, l10n.assignments),
    };

    final Color bgColor;
    final Color borderColor;
    final Color iconColor;

    if (node.isLocked) {
      bgColor = const Color(0xFFE8E8E8);
      borderColor = const Color(0xFFBDBDBD);
      iconColor = const Color(0xFF9E9E9E);
    } else if (node.isCompleted) {
      bgColor = const Color(0xFFE3EEF7);
      borderColor = const Color(0xFF004A85);
      iconColor = const Color(0xFF004A85);
    } else if (isCurrent) {
      bgColor = AppColors.primary;
      borderColor = const Color(0xFF004A85);
      iconColor = AppColors.background;
    } else {
      bgColor = AppColors.background;
      borderColor = AppColors.primary;
      iconColor = AppColors.primary;
    }

    final statusLabel = node.isLocked
        ? l10n.locked
        : node.isCompleted
            ? l10n.completed
            : isCurrent
                ? l10n.start
                : l10n.newLabel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: isLesson ? 4 : 3),
                boxShadow: isCurrent && !node.isLocked
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: node.isLocked
                  ? Icon(Icons.lock, color: iconColor, size: isLesson ? 28 : 22)
                  : node.isCompleted
                      ? Icon(
                          Icons.check_rounded,
                          color: iconColor,
                          size: isLesson ? 32 : 26,
                        )
                      : Icon(icon, color: iconColor, size: isLesson ? 30 : 24),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: node.isCompleted
                ? AppColors.primary.withValues(alpha: 0.1)
                : isCurrent
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(
              color: node.isCompleted
                  ? AppColors.primary
                  : isCurrent
                      ? AppColors.primary
                      : AppColors.text.withValues(alpha: 0.4),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 100,
          child: Text(
            isLesson ? node.item.title : label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: node.isLocked
                  ? AppColors.text.withValues(alpha: 0.35)
                  : AppColors.text.withValues(alpha: 0.75),
              fontSize: isLesson ? 11 : 10,
              fontWeight: isLesson ? FontWeight.w600 : FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
