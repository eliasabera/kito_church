import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/data/student_learning_data.dart';
import 'package:kitoapp/features/learning/models/learning_item.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';

class LearningItemDetailScreen extends StatelessWidget {
  const LearningItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  void _openAction(BuildContext context, LearningItem item) {
    final route = switch (item.type) {
      LearningItemType.lesson => StudentRoutes.lessonReader(item.id),
      LearningItemType.assignment => StudentRoutes.assignmentSubmit(item.id),
      LearningItemType.quiz => StudentRoutes.quizPractice(item.id),
    };
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = StudentLearningData.findById(itemId);

    if (item == null) {
      return AppScaffold(
        title: l10n.learning,
        body: Center(child: Text(l10n.noLearningItems)),
      );
    }

    final title = switch (item.type) {
      LearningItemType.lesson => l10n.lessons,
      LearningItemType.assignment => l10n.assignments,
      LearningItemType.quiz => l10n.quizzes,
    };

    final actionLabel = switch (item.type) {
      LearningItemType.lesson => l10n.readLesson,
      LearningItemType.assignment => l10n.submitWork,
      LearningItemType.quiz => l10n.takeQuiz,
    };

    return AppScaffold(
      title: title,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailImage(item: item),
            const SizedBox(height: 16),
            Text(
              item.title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.person_outline,
              label: l10n.teacherName,
              value: item.teacherName,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.info_outline,
              label: l10n.status,
              value: _statusLabel(item.status, l10n),
            ),
            if (item.dueDate != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: l10n.dueOn,
                value: item.dueDate!,
              ),
            ],
            const SizedBox(height: 20),
            Text(
              l10n.description,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description ?? item.subtitle,
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.75),
                fontSize: 14,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => _openAction(context, item),
              child: Text(actionLabel),
            ),
          ],
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

class _DetailImage extends StatelessWidget {
  const _DetailImage({required this.item});

  final LearningItem item;

  @override
  Widget build(BuildContext context) {
    if (item.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            item.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _PlaceholderImage(type: item.type),
          ),
        ),
      );
    }

    return _PlaceholderImage(type: item.type);
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({required this.type});

  final LearningItemType type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      LearningItemType.lesson => Icons.menu_book_rounded,
      LearningItemType.assignment => Icons.assignment_rounded,
      LearningItemType.quiz => Icons.quiz_rounded,
    };

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Icon(icon, size: 56, color: AppColors.primary),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.text.withValues(alpha: 0.55),
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
