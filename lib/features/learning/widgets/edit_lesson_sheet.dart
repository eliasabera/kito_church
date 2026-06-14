import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';
import 'package:kitoapp/features/learning/widgets/teacher_lesson_tile.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/teacher_lessons_store_provider.dart';

void showEditLessonSheet(BuildContext context, TeacherLesson lesson) {
  final messenger = ScaffoldMessenger.of(context);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _EditLessonSheet(
      lesson: lesson,
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

class _EditLessonSheet extends StatefulWidget {
  const _EditLessonSheet({
    required this.lesson,
    required this.onClose,
    required this.onSuccess,
  });

  final TeacherLesson lesson;
  final VoidCallback onClose;
  final void Function(String message) onSuccess;

  @override
  State<_EditLessonSheet> createState() => _EditLessonSheetState();
}

class _EditLessonSheetState extends State<_EditLessonSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late int _minAge;
  late int _maxAge;
  late bool _hasQuiz;
  late bool _hasAssignment;
  late DateTime _deadline;
  late TeacherLessonStatus _status;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final lesson = widget.lesson;
    _titleController = TextEditingController(text: lesson.title);
    _descriptionController =
        TextEditingController(text: lesson.description ?? '');
    _minAge = lesson.minAge;
    _maxAge = lesson.maxAge;
    _hasQuiz = lesson.hasQuiz;
    _hasAssignment = lesson.hasAssignment;
    _deadline = lesson.deadline;
    _status = lesson.status;
  }

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
      firstDate: DateTime(2020),
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

  Future<void> _submit() async {
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
      await store.updateLesson(
        widget.lesson.id,
        EditLessonDraft(
          title: title,
          minAge: _minAge,
          maxAge: _maxAge,
          deadline: _deadline,
          status: _status,
          description: _descriptionController.text,
          hasQuiz: _hasQuiz,
          hasAssignment: _hasAssignment,
        ),
      );

      if (!mounted) return;
      widget.onSuccess(l10n.lessonUpdated);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lessonUpdateFailed)),
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
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
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
                    l10n.editLesson,
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
              l10n.weekNumber(widget.lesson.weekNumber),
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.55),
                fontSize: 12,
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
                    onChanged: (value) => setState(() => _minAge = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AgeField(
                    label: l10n.maxAge,
                    value: _maxAge,
                    enabled: !_submitting,
                    onChanged: (value) => setState(() => _maxAge = value),
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
            DropdownButtonFormField<TeacherLessonStatus>(
              key: ValueKey(_status),
              initialValue: _status,
              decoration: InputDecoration(
                labelText: l10n.changeStatus,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: TeacherLessonStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        TeacherLessonTile.statusLabel(status, l10n),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.includeQuiz),
              value: _hasQuiz,
              activeThumbColor: AppColors.primary,
              onChanged:
                  _submitting ? null : (value) => setState(() => _hasQuiz = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.includeAssignment),
              value: _hasAssignment,
              activeThumbColor: AppColors.primary,
              onChanged: _submitting
                  ? null
                  : (value) => setState(() => _hasAssignment = value),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
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
                  : Text(l10n.save),
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
          ? (value) {
              if (value != null) onChanged(value);
            }
          : null,
    );
  }
}
