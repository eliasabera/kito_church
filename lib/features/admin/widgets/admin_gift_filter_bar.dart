import 'package:flutter/material.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class AdminGiftFilterBar extends StatelessWidget {
  const AdminGiftFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AdminGiftFilter value;
  final ValueChanged<AdminGiftFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      (AdminGiftFilter.all, l10n.all),
      (AdminGiftFilter.awaitingAnnouncement, l10n.awaitingAnnouncement),
      (AdminGiftFilter.announced, l10n.announced),
      (AdminGiftFilter.pending, l10n.pending),
      (AdminGiftFilter.delivered, l10n.delivered),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(option.$2),
                selected: value == option.$1,
                onSelected: (_) => onChanged(option.$1),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: value == option.$1
                      ? AppColors.primary
                      : AppColors.text.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: value == option.$1
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : AppColors.text.withValues(alpha: 0.12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
