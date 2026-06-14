import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/notifications/models/app_notification.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    this.onApprove,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback? onApprove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final timeLabel = DateFormat.yMMMd(locale).add_jm().format(
          notification.createdAt,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.background
            : AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notification.isRead
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconFor(notification.type),
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.75),
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          color: AppColors.text.withValues(alpha: 0.45),
                          fontSize: 11,
                        ),
                      ),
                      if (onApprove != null) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonal(
                            onPressed: onApprove,
                            child: Text(l10n.approve),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(AppNotificationType type) {
    return switch (type) {
      AppNotificationType.weeklyLesson => Icons.auto_stories_outlined,
      AppNotificationType.giftArrived => Icons.card_giftcard_outlined,
      AppNotificationType.dailyVerse => Icons.menu_book_outlined,
      AppNotificationType.accountApproved => Icons.verified_outlined,
      AppNotificationType.registrationPending => Icons.person_add_outlined,
    };
  }
}
