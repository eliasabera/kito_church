import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class ScoringOverviewCard extends StatelessWidget {
  const ScoringOverviewCard({
    super.key,
    required this.totalWeight,
    required this.isValid,
  });

  final double totalWeight;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF004A85)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.scoringOverview,
            style: TextStyle(
              color: AppColors.background.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${totalWeight.round()}%',
                style: TextStyle(
                  color: isValid
                      ? AppColors.background
                      : AppColors.background.withValues(alpha: 0.85),
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  l10n.totalWeight,
                  style: TextStyle(
                    color: AppColors.background.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(
                    alpha: isValid ? 0.2 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.background.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isValid ? Icons.check_circle_outline : Icons.warning_amber,
                      size: 14,
                      color: AppColors.background.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isValid ? l10n.validWeights : l10n.weightMustEqual100,
                      style: TextStyle(
                        color: AppColors.background.withValues(alpha: 0.95),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (totalWeight.clamp(0, 100)) / 100,
              minHeight: 6,
              backgroundColor: AppColors.background.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isValid
                    ? AppColors.background
                    : AppColors.background.withValues(alpha: 0.75),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${totalWeight.round()} / 100%',
            style: TextStyle(
              color: AppColors.background.withValues(alpha: 0.75),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
