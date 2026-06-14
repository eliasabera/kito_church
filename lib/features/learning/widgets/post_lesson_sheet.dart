import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/teacher_lessons_store_provider.dart';

void showPostLessonSheet(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _PostLessonSheet(
      onClose: () {
        final navigator = Navigator.of(sheetContext, rootNavigator: true);
        if (navigator.canPop()) {
          navigator.pop();
        }
      },
      onSuccess: (message) {
        final navigator = Navigator.of(sheetContext, rootNavigator: true);
        if (navigator.canPop()) {
          navigator.pop();
        }
        messenger.showSnackBar(SnackBar(content: Text(message)));
      },
    ),
  );
}

class _PostLessonSheet extends StatefulWidget {
  const _PostLessonSheet({
    required this.onClose,
    required this.onSuccess,
  });

  final VoidCallback onClose;
  final void Function(String message) onSuccess;

  @override
  State<_PostLessonSheet> createState() => _PostLessonSheetState();
}

class _PostLessonSheetState extends State<_PostLessonSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _minAge = 12;
  int _maxAge = 24;
  bool _hasQuiz = false;
  bool _hasAssignment = false;
  bool _submitting = false;
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = DateTime(
            picked.year,
            picked.month,
            picked.day,
            23,
            59,
          ));
    }
  }

  Future<void> _submit({required bool publish}) async {
    if (_submitting) return;

    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lessonTitleRequired)),
      );
      return;
    }
    if (_minAge > _maxAge) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidAgeRange)),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final store = TeacherLessonsStoreProvider.of(context);
      await store.postLesson(
        PostLessonDraft(
          title: title,
          minAge: _minAge,
          maxAge: _maxAge,
          deadline: _deadline,
          description: _descriptionController.text,
          hasQuiz: _hasQuiz,
          hasAssignment: _hasAssignment,
          publish: publish,
        ),
      );

      if (!mounted) return;
      widget.onSuccess(
        publish ? l10n.lessonPublished : l10n.lessonSavedAsDraft,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lessonSaveFailed)),
      );
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.text.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.postNewLesson,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _submitting ? null : widget.onClose,
                  icon: const Icon(Icons.close),
                  color: AppColors.text.withValues(alpha: 0.6),
                  tooltip: l10n.cancel,
                ),
              ],
            ),
            Text(
              l10n.postLessonHint,
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.55),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              enabled: !_submitting,
              decoration: InputDecoration(
                labelText: l10n.lessonTitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _descriptionController,
              enabled: !_submitting,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.description,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.classAgeRange,
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _AgeField(
                    label: l10n.minAge,
                    value: _minAge,
                    enabled: !_submitting,
                    onChanged: (v) => setState(() => _minAge = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AgeField(
                    label: l10n.maxAge,
                    value: _maxAge,
                    enabled: !_submitting,
                    onChanged: (v) => setState(() => _maxAge = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _submitting ? null : _pickDeadline,
              icon: const Icon(Icons.event_outlined, size: 18),
              label: Text(l10n.deadlineDate(
                '${_deadline.month}/${_deadline.day}/${_deadline.year}',
              )),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.includeQuiz),
              value: _hasQuiz,
              activeThumbColor: AppColors.primary,
              onChanged: _submitting ? null : (v) => setState(() => _hasQuiz = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.includeAssignment),
              value: _hasAssignment,
              activeThumbColor: AppColors.primary,
              onChanged:
                  _submitting ? null : (v) => setState(() => _hasAssignment = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => _submit(publish: false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(l10n.saveDraft),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : () => _submit(publish: true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : Text(l10n.publishLesson),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeField extends StatelessWidget {
  const _AgeField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final bool enabled;

  static const _ages = [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      key: ValueKey('$label-$value'),
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: _ages
          .map(
            (age) => DropdownMenuItem(
              value: age,
              child: Text('$age'),
            ),
          )
          .toList(),
      onChanged: enabled
          ? (v) {
              if (v != null) onChanged(v);
            }
          : null,
    );
  }
}
