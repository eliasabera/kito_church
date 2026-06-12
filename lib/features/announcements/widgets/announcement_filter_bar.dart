import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/announcements/models/announcement_item.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class AnnouncementFilterBar extends StatelessWidget {
  const AnnouncementFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AnnouncementCategory? value;
  final ValueChanged<AnnouncementCategory?> onChanged;

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
          child: DropdownButton<AnnouncementCategory?>(
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
              DropdownMenuItem(value: null, child: Text(l10n.all)),
              DropdownMenuItem(
                value: AnnouncementCategory.church,
                child: Text(l10n.churchAnnouncements),
              ),
              DropdownMenuItem(
                value: AnnouncementCategory.events,
                child: Text(l10n.events),
              ),
              DropdownMenuItem(
                value: AnnouncementCategory.academic,
                child: Text(l10n.academic),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
