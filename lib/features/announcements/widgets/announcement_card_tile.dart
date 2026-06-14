import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/announcements/models/announcement_item.dart';
import 'package:kitoapp/features/announcements/widgets/announcement_category_style.dart';
import 'package:kitoapp/features/announcements/services/announcement_document_launcher.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/announcement_image.dart';

class AnnouncementCardTile extends StatelessWidget {
  const AnnouncementCardTile({
    super.key,
    required this.item,
    required this.categoryName,
    this.onTap,
  });

  final AnnouncementItem item;
  final String categoryName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.MMMd(locale).format(item.date);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isNew
                ? AppColors.primary.withValues(alpha: 0.04)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.isNew
                  ? AppColors.primary.withValues(alpha: 0.3)
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryIcon(
                categoryId: item.categoryId,
                categoryName: categoryName,
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
                            item.title,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (item.isNew)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              l10n.newLabel,
                              style: const TextStyle(
                                color: AppColors.background,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.45),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (item.hasImage) ...[
                      AnnouncementImage(item: item, height: 120),
                      const SizedBox(height: 8),
                    ],
                    if (item.hasDocument) ...[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => AnnouncementDocumentLauncher.openDocument(
                            context,
                            item,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(
                                  AnnouncementDocumentLauncher.iconFor(item),
                                  size: 14,
                                  color:
                                      AppColors.primary.withValues(alpha: 0.75),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.documentName ?? l10n.readDocument,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.85),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 12,
                                  color:
                                      AppColors.primary.withValues(alpha: 0.6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      item.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 13,
                          color: AppColors.text.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${l10n.postedBy} ${item.author}',
                          style: TextStyle(
                            color: AppColors.text.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.readMore,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final color = AnnouncementCategoryStyle.colorFor(categoryId);
    final icon = AnnouncementCategoryStyle.iconFor(categoryId);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

void showAnnouncementDetailSheet(
  BuildContext context,
  AnnouncementItem item,
) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  final dateLabel = DateFormat.yMMMd(locale).format(item.date);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$dateLabel · ${l10n.postedBy} ${item.author}',
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                if (item.hasImage) ...[
                  AnnouncementImage(item: item, height: 180, borderRadius: 14),
                  const SizedBox(height: 16),
                ],
                Text(
                  item.message,
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.85),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                if (item.hasDocument) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          AnnouncementDocumentLauncher.openDocument(context, item),
                      icon: Icon(AnnouncementDocumentLauncher.iconFor(item)),
                      label: Text(l10n.readDocument),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}
