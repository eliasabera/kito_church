import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/announcements/widgets/announcement_card_tile.dart';
import 'package:kitoapp/features/announcements/widgets/announcement_filter_bar.dart';
import 'package:kitoapp/features/announcements/widgets/announcement_summary_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/announcements_store_provider.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/features/announcements/models/announcement_item.dart';

class AnnouncementsContent extends StatefulWidget {
  const AnnouncementsContent({super.key});

  @override
  State<AnnouncementsContent> createState() => _AnnouncementsContentState();
}

class _AnnouncementsContentState extends State<AnnouncementsContent> {
  String? _filter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnnouncementsStoreProvider.of(context).loadFromSupabase(
        publishedOnly: true,
      );
    });
  }

  void _openDetail(AnnouncementItem item) {
    final store = AnnouncementsStoreProvider.of(context);
    showAnnouncementDetailSheet(context, item);
    store.markAsRead(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = AnnouncementsStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isLoading && store.publishedItems.isEmpty) {
          return const ColoredBox(
            color: AppColors.background,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final summary = store.studentSummary;
        final items = store.publishedItemsFor(categoryId: _filter);

        return ColoredBox(
          color: AppColors.primary.withValues(alpha: 0.03),
          child: RefreshIndicator(
            onRefresh: () =>
                store.loadFromSupabase(publishedOnly: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: AnnouncementSummaryCard(summary: summary),
                ),
                AnnouncementFilterBar(
                  categories: store.categories,
                  value: _filter,
                  onChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.recentAnnouncements,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: items.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.sizeOf(context).height * 0.35,
                              child: Center(
                                child: Text(
                                  l10n.noAnnouncements,
                                  style: TextStyle(
                                    color: AppColors.text
                                        .withValues(alpha: 0.45),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return AnnouncementCardTile(
                              item: item,
                              categoryName:
                                  store.categoryNameFor(item.categoryId),
                              onTap: () => _openDetail(item),
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

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.announcements,
      body: const AnnouncementsContent(),
    );
  }
}
