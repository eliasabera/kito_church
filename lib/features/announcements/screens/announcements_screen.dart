import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/announcements/data/announcements_data.dart';
import 'package:kitoapp/features/announcements/models/announcement_item.dart';
import 'package:kitoapp/features/announcements/widgets/announcement_card_tile.dart';
import 'package:kitoapp/features/announcements/widgets/announcement_filter_bar.dart';
import 'package:kitoapp/features/announcements/widgets/announcement_summary_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';

class AnnouncementsContent extends StatefulWidget {
  const AnnouncementsContent({super.key});

  @override
  State<AnnouncementsContent> createState() => _AnnouncementsContentState();
}

class _AnnouncementsContentState extends State<AnnouncementsContent> {
  AnnouncementCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = AnnouncementsData.summary;
    final items = AnnouncementsData.itemsFor(_filter);

    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AnnouncementSummaryCard(summary: summary),
          ),
          AnnouncementFilterBar(
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
                ? Center(
                    child: Text(
                      l10n.noAnnouncements,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.45),
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return AnnouncementCardTile(
                        item: item,
                        onTap: () => showAnnouncementDetailSheet(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
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
