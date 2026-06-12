import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/data/student_learning_data.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/learning_progress_provider.dart';

class AssignmentSubmissionScreen extends StatefulWidget {
  const AssignmentSubmissionScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<AssignmentSubmissionScreen> createState() =>
      _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState
    extends State<AssignmentSubmissionScreen> {
  final _answerController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_answerController.text.trim().isEmpty) return;
    LearningProgressProvider.of(context).completeAssignment(widget.itemId);
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).assignmentSubmitted,
          style: const TextStyle(color: AppColors.background),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = StudentLearningData.findById(widget.itemId);

    if (item == null) {
      return AppScaffold(
        title: l10n.assignments,
        body: Center(child: Text(l10n.noLearningItems)),
      );
    }

    final store = LearningProgressProvider.of(context);
    if (!store.isAssignmentAccessible(widget.itemId)) {
      return AppScaffold(
        title: l10n.assignmentSubmission,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.activityLocked,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text.withValues(alpha: 0.7),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      title: l10n.assignmentSubmission,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${l10n.teacherName}: ${item.teacherName}',
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
            if (item.dueDate != null) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.dueOn}: ${item.dueDate}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              item.description ?? item.subtitle,
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.yourAnswer,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _answerController,
              maxLines: 8,
              enabled: !_submitted,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: l10n.typeYourAnswer,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _submitted
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.comingSoon),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
              icon: const Icon(Icons.attach_file, size: 18),
              label: Text(l10n.attachFile),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitted
                  ? () => Navigator.of(context).pop()
                  : (_answerController.text.trim().isEmpty ? null : _submit),
              child: Text(_submitted ? l10n.completed : l10n.submitWork),
            ),
          ],
        ),
      ),
    );
  }
}
