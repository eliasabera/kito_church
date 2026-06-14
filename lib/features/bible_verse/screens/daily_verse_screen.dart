import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/bible_verse/widgets/daily_verse_detail_sheet.dart';
import 'package:kitoapp/features/bible_verse/widgets/daily_verse_history_tile.dart';
import 'package:kitoapp/features/bible_verse/widgets/daily_verse_summary_card.dart';
import 'package:kitoapp/features/bible_verse/widgets/daily_verse_today_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/daily_verse_store_provider.dart';

class DailyVerseContent extends StatefulWidget {
  const DailyVerseContent({super.key});

  @override
  State<DailyVerseContent> createState() => _DailyVerseContentState();
}

class _DailyVerseContentState extends State<DailyVerseContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DailyVerseStoreProvider.of(context).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = DailyVerseStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.allVerses.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final today = store.todayVerse;
        final previous = store.previousVerses;

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: RefreshIndicator(
            onRefresh: store.load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: DailyVerseSummaryCard(summary: store.summary),
                ),
                if (today != null) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DailyVerseTodayCard(
                      verse: today,
                      onTap: () => showDailyVerseDetailSheet(context, today),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.previousVerses,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.previousVersesHint,
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (previous.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          l10n.noPreviousVerses,
                          style: TextStyle(
                            color: AppColors.text.withValues(alpha: 0.45),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        for (final verse in previous)
                          DailyVerseHistoryTile(
                            verse: verse,
                            onTap: () =>
                                showDailyVerseDetailSheet(context, verse),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }
}

class DailyVerseScreen extends StatelessWidget {
  const DailyVerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.dailyVerse,
      body: const DailyVerseContent(),
    );
  }
}
