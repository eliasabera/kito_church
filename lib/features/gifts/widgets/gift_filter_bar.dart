import 'package:flutter/material.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

enum GiftFilter { all, digital, physical, pending, received, delivered }

class GiftFilterBar extends StatelessWidget {
  const GiftFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final GiftFilter value;
  final ValueChanged<GiftFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<GiftFilter>(
            value: value,
            isExpanded: true,
            isDense: true,
            icon: const Icon(
              Icons.expand_more,
              color: AppColors.primary,
              size: 20,
            ),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            borderRadius: BorderRadius.circular(10),
            items: [
              DropdownMenuItem(value: GiftFilter.all, child: Text(l10n.all)),
              DropdownMenuItem(
                value: GiftFilter.digital,
                child: Text(l10n.digitalGift),
              ),
              DropdownMenuItem(
                value: GiftFilter.physical,
                child: Text(l10n.physicalGift),
              ),
              DropdownMenuItem(
                value: GiftFilter.pending,
                child: Text(l10n.pending),
              ),
              DropdownMenuItem(
                value: GiftFilter.received,
                child: Text(l10n.received),
              ),
              DropdownMenuItem(
                value: GiftFilter.delivered,
                child: Text(l10n.delivered),
              ),
            ],
            onChanged: (filter) {
              if (filter != null) onChanged(filter);
            },
          ),
        ),
      ),
    );
  }

  static GiftType? typeFor(GiftFilter filter) {
    return switch (filter) {
      GiftFilter.digital => GiftType.digital,
      GiftFilter.physical => GiftType.physical,
      _ => null,
    };
  }

  static GiftStatus? statusFor(GiftFilter filter) {
    return switch (filter) {
      GiftFilter.pending => GiftStatus.pending,
      GiftFilter.received => GiftStatus.received,
      GiftFilter.delivered => GiftStatus.delivered,
      _ => null,
    };
  }
}
