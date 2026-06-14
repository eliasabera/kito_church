import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/admin/models/managed_gift.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class ManagedGiftTile extends StatelessWidget {
  const ManagedGiftTile({
    super.key,
    required this.gift,
    required this.onAnnounce,
    required this.onUpdateStatus,
  });

  final ManagedGift gift;
  final VoidCallback onAnnounce;
  final ValueChanged<GiftStatus> onUpdateStatus;

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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: gift.announced
              ? AppColors.primary.withValues(alpha: 0.12)
              : const Color(0xFFFF9800).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  gift.type == GiftType.digital
                      ? Icons.mail_outline
                      : Icons.inventory_2_outlined,
                  color: AppColors.primary,
                ),
              ),
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
              _AnnouncementBadge(announced: gift.announced),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                size: 14,
                color: AppColors.text.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  gift.studentName,
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!gift.announced)
                FilledButton.icon(
                  onPressed: onAnnounce,
                  icon: const Icon(Icons.campaign_outlined, size: 16),
                  label: Text(l10n.announceGift),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                _StatusMenu(
                  status: gift.status,
                  onChanged: onUpdateStatus,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnnouncementBadge extends StatelessWidget {
  const _AnnouncementBadge({required this.announced});

  final bool announced;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = announced ? const Color(0xFF2E7D32) : const Color(0xFFE65100);
    final label = announced ? l10n.announced : l10n.awaitingAnnouncement;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusMenu extends StatelessWidget {
  const _StatusMenu({required this.status, required this.onChanged});

  final GiftStatus status;
  final ValueChanged<GiftStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<GiftStatus>(
      initialValue: status,
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _statusLabel(status, l10n),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more, size: 16, color: AppColors.primary),
          ],
        ),
      ),
      itemBuilder: (context) => GiftStatus.values
          .map(
            (value) => PopupMenuItem(
              value: value,
              child: Text(_statusLabel(value, l10n)),
            ),
          )
          .toList(),
    );
  }

  String _statusLabel(GiftStatus status, AppLocalizations l10n) {
    return switch (status) {
      GiftStatus.pending => l10n.pending,
      GiftStatus.received => l10n.received,
      GiftStatus.delivered => l10n.delivered,
    };
  }
}
