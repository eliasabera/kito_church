import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/learning_item.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class LessonGridCard extends StatelessWidget {
  const LessonGridCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final LearningItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardImage(item: item),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppColors.text.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.teacherName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.text.withValues(alpha: 0.55),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusLabel(item.status, l10n),
                      style: TextStyle(
                        color: item.status == LearningItemStatus.completed
                            ? AppColors.primary
                            : AppColors.text.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
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

  String _statusLabel(LearningItemStatus status, AppLocalizations l10n) {
    return switch (status) {
      LearningItemStatus.newItem => l10n.newLabel,
      LearningItemStatus.pending => l10n.pending,
      LearningItemStatus.completed => l10n.completed,
    };
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.item});

  final LearningItem item;

  @override
  Widget build(BuildContext context) {
    if (item.imageUrl != null) {
      return AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(
          item.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _IconHeader(type: item.type),
        ),
      );
    }

    return _IconHeader(type: item.type);
  }
}

class _IconHeader extends StatelessWidget {
  const _IconHeader({required this.type});

  final LearningItemType type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      LearningItemType.lesson => Icons.menu_book_outlined,
      LearningItemType.assignment => Icons.assignment_outlined,
      LearningItemType.quiz => Icons.quiz_outlined,
    };

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: ColoredBox(
        color: AppColors.primary.withValues(alpha: 0.08),
        child: Icon(icon, color: AppColors.primary, size: 28),
      ),
    );
  }
}
