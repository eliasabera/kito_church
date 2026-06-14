import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/ranking/models/ranking_entry.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class MyRankSummary extends StatelessWidget {
  const MyRankSummary({super.key, required this.summary});

  final StudentRankSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rank = summary.classRank;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myRanking,
            style: TextStyle(
              color: AppColors.background.withValues(alpha: 0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rank > 0 ? '#$rank' : '—',
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  l10n.classRank,
                  style: TextStyle(
                    color: AppColors.background.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.finalScore,
                    style: TextStyle(
                      color: AppColors.background.withValues(alpha: 0.75),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    summary.finalScore.toStringAsFixed(0),
                    style: const TextStyle(
                      color: AppColors.background,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
