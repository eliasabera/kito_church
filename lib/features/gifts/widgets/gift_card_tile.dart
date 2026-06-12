import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/gifts/models/gift_item.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class GiftCardTile extends StatelessWidget {
  const GiftCardTile({super.key, required this.gift});

  final GiftItem gift;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.yMMMd(locale).format(gift.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _GiftIcon(type: gift.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gift.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: gift.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            gift.description,
            style: TextStyle(
              color: AppColors.text.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.favorite_outline,
                size: 14,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.fromSponsor,
                style: TextStyle(
                  color: AppColors.text.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                gift.sponsorName,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _TypeChip(type: gift.type),
            ],
          ),
        ],
      ),
    );
  }
}

class _GiftIcon extends StatelessWidget {
  const _GiftIcon({required this.type});

  final GiftType type;

  @override
  Widget build(BuildContext context) {
    final isDigital = type == GiftType.digital;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isDigital ? Icons.mail_outline : Icons.inventory_2_outlined,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final GiftType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label =
        type == GiftType.digital ? l10n.digitalGift : l10n.physicalGift;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final GiftStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color, icon) = switch (status) {
      GiftStatus.pending => (
          l10n.pending,
          const Color(0xFFE65100),
          Icons.hourglass_top_outlined,
        ),
      GiftStatus.received => (
          l10n.received,
          const Color(0xFF2E7D32),
          Icons.check_circle_outline,
        ),
      GiftStatus.delivered => (
          l10n.delivered,
          AppColors.primary,
          Icons.local_shipping_outlined,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
