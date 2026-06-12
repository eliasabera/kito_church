import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/gifts/data/gifts_data.dart';
import 'package:kitoapp/features/gifts/widgets/gift_card_tile.dart';
import 'package:kitoapp/features/gifts/widgets/gift_filter_bar.dart';
import 'package:kitoapp/features/gifts/widgets/gift_summary_card.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';

class GiftsContent extends StatefulWidget {
  const GiftsContent({super.key});

  @override
  State<GiftsContent> createState() => _GiftsContentState();
}

class _GiftsContentState extends State<GiftsContent> {
  GiftFilter _filter = GiftFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = GiftsData.summary;
    final gifts = GiftsData.itemsFor(
      type: GiftFilterBar.typeFor(_filter),
      status: GiftFilterBar.statusFor(_filter),
    );

    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GiftSummaryCard(summary: summary),
          ),
          GiftFilterBar(
            value: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.myGifts,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: gifts.isEmpty
                ? Center(
                    child: Text(
                      l10n.noGifts,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.45),
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: gifts.length,
                    itemBuilder: (context, index) {
                      return GiftCardTile(gift: gifts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class GiftsScreen extends StatelessWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.gifts,
      body: const GiftsContent(),
    );
  }
}
