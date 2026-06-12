import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/prayer_requests/models/prayer_request.dart';
import 'package:kitoapp/features/prayer_requests/services/prayer_requests_store.dart';
import 'package:kitoapp/features/prayer_requests/widgets/prayer_comments_sheet.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/prayer_requests_store_provider.dart';

class PrayerRequestTile extends StatelessWidget {
  const PrayerRequestTile({
    super.key,
    required this.request,
    required this.role,
    this.showAuthor = false,
  });

  final PrayerRequest request;
  final UserRole role;
  final bool showAuthor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = PrayerRequestsStoreProvider.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.MMMd(locale).format(request.date);
    final isAnswered = request.status == PrayerRequestStatus.answered;
    final userId = PrayerRequestsStore.userIdForRole(role);
    final isLiked = store.isLikedBy(request.id, userId);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAnswered
              ? const Color(0xFF2E7D32).withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: 0.12),
        ),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isAnswered
                          ? const Color(0xFF2E7D32)
                          : AppColors.primary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isAnswered
                      ? Icons.check_circle_outline
                      : Icons.volunteer_activism_outlined,
                  color: isAnswered
                      ? const Color(0xFF2E7D32)
                      : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showAuthor) ...[
                      Text(
                        request.authorName,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.45),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(
                label: isAnswered ? l10n.answered : l10n.praying,
                color:
                    isAnswered ? const Color(0xFF2E7D32) : AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.message,
            style: TextStyle(
              color: AppColors.text.withValues(alpha: 0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                label: request.likeCount > 0
                    ? l10n.likesCount(request.likeCount)
                    : l10n.like,
                color: isLiked ? const Color(0xFFE53935) : AppColors.primary,
                onTap: () => store.toggleLike(request.id, userId),
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: request.comments.isNotEmpty
                    ? l10n.commentsCount(request.comments.length)
                    : l10n.comment,
                color: AppColors.primary,
                onTap: () => showPrayerCommentsSheet(
                  context,
                  request: request,
                  role: role,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
