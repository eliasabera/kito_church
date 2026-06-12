import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/services/learning_progress_store.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class LearningStatsBar extends StatelessWidget {
  const LearningStatsBar({super.key, required this.stats});

  final LearningPathStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF004A85)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _OverallRing(percent: stats.overallPercent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.overallProgress,
                    style: TextStyle(
                      color: AppColors.background.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stats.overallPercent}%',
                    style: const TextStyle(
                      color: AppColors.background,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.totalStudyTime(stats.totalTimeMinutes),
                    style: TextStyle(
                      color: AppColors.background.withValues(alpha: 0.75),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatPill(
                        icon: Icons.menu_book_outlined,
                        label: l10n.lessons,
                        done: stats.lessonsCompleted,
                        total: stats.lessonsTotal,
                      ),
                      const SizedBox(width: 6),
                      _StatPill(
                        icon: Icons.quiz_outlined,
                        label: l10n.quizzes,
                        done: stats.quizzesCompleted,
                        total: stats.quizzesTotal,
                      ),
                      const SizedBox(width: 6),
                      _StatPill(
                        icon: Icons.assignment_outlined,
                        label: l10n.assignments,
                        done: stats.assignmentsCompleted,
                        total: stats.assignmentsTotal,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverallRing extends StatelessWidget {
  const _OverallRing({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 6,
              backgroundColor: AppColors.background.withValues(alpha: 0.2),
              color: AppColors.background,
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.done,
    required this.total,
  });

  final IconData icon;
  final String label;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final complete = done >= total && total > 0;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: AppColors.background),
            const SizedBox(height: 2),
            Text(
              '$done/$total',
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.background.withValues(alpha: 0.8),
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (complete)
              const Icon(Icons.check, size: 10, color: AppColors.background),
          ],
        ),
      ),
    );
  }
}
