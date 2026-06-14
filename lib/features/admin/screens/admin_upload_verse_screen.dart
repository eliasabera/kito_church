import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/widgets/upload_verse_sheet.dart';
import 'package:kitoapp/features/bible_verse/services/daily_verse_store.dart';
import 'package:kitoapp/features/bible_verse/widgets/daily_verse_detail_sheet.dart';
import 'package:kitoapp/features/bible_verse/widgets/daily_verse_history_tile.dart';
import 'package:kitoapp/features/bible_verse/widgets/daily_verse_summary_card.dart';
import 'package:kitoapp/features/bible_verse/widgets/daily_verse_today_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/models/bible_verse.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/daily_verse_store_provider.dart';

class AdminUploadVerseContent extends StatefulWidget {
  const AdminUploadVerseContent({super.key});

  @override
  State<AdminUploadVerseContent> createState() =>
      _AdminUploadVerseContentState();
}

class _AdminUploadVerseContentState extends State<AdminUploadVerseContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchVerses());
  }

  Future<void> _fetchVerses() async {
    if (!mounted) return;
    await DailyVerseStoreProvider.of(context).load();
  }

  Future<void> _confirmDeleteVerse(DailyVerseStore store, String id) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Verse'),
        content: const Text('Are you sure you want to delete this verse?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await store.deleteVerse(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Verse deleted' : l10n.reportGenerateFailed),
      ),
    );
  }

  void _openEditVerse(DailyVerseStore store, BibleVerse verse) {
    showAddEditVerseSheet(context, store: store, existing: verse);
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

        final uploadedVerses = store.allVerses;
        final today = store.todayVerse;
        final showTodayCard = today != null &&
            store.isScheduledToday(today.scheduledDate);

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: RefreshIndicator(
            onRefresh: store.load,
            color: AppColors.primary,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 88),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: DailyVerseSummaryCard(summary: store.summary),
                        ),
                        if (store.isLoading && uploadedVerses.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ],
                        if (store.error != null) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              store.error!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                        if (showTodayCard) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DailyVerseTodayCard(
                              verse: today,
                              onTap: () =>
                                  showDailyVerseDetailSheet(context, today),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _openEditVerse(store, today),
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: const Text('Edit Verse'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _confirmDeleteVerse(store, today.id),
                                  icon:
                                      const Icon(Icons.delete_outline, size: 18),
                                  label: Text(l10n.delete),
                                ),
                              ],
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
                        if (uploadedVerses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.noPreviousVerses,
                                  style: TextStyle(
                                    color:
                                        AppColors.text.withValues(alpha: 0.45),
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
                                for (final verse in uploadedVerses)
                                  DailyVerseHistoryTile(
                                    verse: verse,
                                    onTap: () => showDailyVerseDetailSheet(
                                      context,
                                      verse,
                                    ),
                                    onEdit: () => _openEditVerse(store, verse),
                                    onDelete: () =>
                                        _confirmDeleteVerse(store, verse.id),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class AdminUploadVerseScreen extends StatelessWidget {
  const AdminUploadVerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = DailyVerseStoreProvider.of(context);

    return AppScaffold(
      title: l10n.uploadVerse,
      body: const AdminUploadVerseContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showUploadVerseSheet(context, store: store),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.upload_outlined),
        label: Text(l10n.uploadVerse),
      ),
    );
  }
}
