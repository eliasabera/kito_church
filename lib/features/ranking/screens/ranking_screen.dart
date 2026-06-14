import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/ranking/widgets/my_rank_summary.dart';
import 'package:kitoapp/features/ranking/widgets/ranking_leaderboard_tile.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/student_ranking_store_provider.dart';

class RankingContent extends StatefulWidget {
  const RankingContent({super.key});

  @override
  State<RankingContent> createState() => _RankingContentState();
}

class _RankingContentState extends State<RankingContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StudentRankingStoreProvider.of(context).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = StudentRankingStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final entries = store.leaderboard;
        final summary = store.summary;

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: store.load,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (summary != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: MyRankSummary(summary: summary),
                  )
                else if (store.isLoading)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
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
                  child: store.isLoading && entries.isEmpty
                      ? const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : entries.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    l10n.noStudentsFound,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.text
                                          .withValues(alpha: 0.5),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                return RankingLeaderboardTile(
                                  entry: entries[index],
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
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
