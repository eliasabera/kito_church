import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/ranking/data/student_ranking_data.dart';
import 'package:kitoapp/features/ranking/models/ranking_entry.dart';
import 'package:kitoapp/features/ranking/widgets/my_rank_summary.dart';
import 'package:kitoapp/features/ranking/widgets/ranking_leaderboard_tile.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';

class RankingContent extends StatelessWidget {
  const RankingContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries =
        StudentRankingData.leaderboardFor(RankingLevel.classRank);

    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: MyRankSummary(summary: StudentRankingData.summary),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.leaderboard,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return RankingLeaderboardTile(entry: entries[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.ranking,
      body: const RankingContent(),
    );
  }
}
