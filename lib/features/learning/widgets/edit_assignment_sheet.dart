import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment_content.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/teacher_assessments_store_provider.dart';
import 'package:kitoapp/shared/widgets/teacher_lessons_store_provider.dart';

void showEditAssignmentSheet(
  BuildContext context, {
  String? lessonId,
  AssignmentContent? existing,
}) {
  final messenger = ScaffoldMessenger.of(context);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _EditAssignmentSheet(
      lessonId: lessonId ?? existing?.lessonId,
      existing: existing,
      onClose: () {
        final navigator = Navigator.of(sheetContext, rootNavigator: true);
        if (navigator.canPop()) navigator.pop();
      },
      onSuccess: (message) {
        final navigator = Navigator.of(sheetContext, rootNavigator: true);
        if (navigator.canPop()) navigator.pop();
        messenger.showSnackBar(SnackBar(content: Text(message)));
      },
    ),
  );
}

class _EditAssignmentSheet extends StatefulWidget {
  const _EditAssignmentSheet({
    required this.onClose,
    required this.onSuccess,
    this.lessonId,
    this.existing,
  });

  final VoidCallback onClose;
  final void Function(String message) onSuccess;
  final String? lessonId;
  final AssignmentContent? existing;

  @override
  State<_EditAssignmentSheet> createState() => _EditAssignmentSheetState();
}

class _EditAssignmentSheetState extends State<_EditAssignmentSheet> {
  final _titleController = TextEditingController();
  final _instructionsController = TextEditingController();
  String? _selectedLessonId;
  String? _attachmentName;
  bool _submitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _selectedLessonId = widget.lessonId ?? widget.existing?.lessonId;
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _instructionsController.text = widget.existing!.instructions;
      _attachmentName = widget.existing!.attachmentName;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _attachFile() {
    setState(() {
      _attachmentName = 'assignment_material.pdf';
    });
  }

  void _removeAttachment() {
    setState(() => _attachmentName = null);
  }

  void _save() {
    if (_submitting) return;

    final l10n = AppLocalizations.of(context);
    final lessonId = _selectedLessonId;
    if (lessonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectLessonRequired)),
      );
      return;
    }

    final title = _titleController.text.trim();
    final instructions = _instructionsController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.assignmentTitleRequired)),
      );
      return;
    }
    if (instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.instructionsRequired)),
      );
      return;
    }

    setState(() => _submitting = true);

    TeacherAssessmentsStoreProvider.of(context).saveAssignment(
      AssignmentContent(
        lessonId: lessonId,
        title: title,
        instructions: instructions,
        attachmentName: _attachmentName,
      ),
    );

    widget.onSuccess(l10n.assessmentSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = TeacherAssessmentsStoreProvider.of(context);
    final lessons = store.lessonsAvailableForAssignment(
      editingLessonId: _selectedLessonId,
    );
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
                    _isEditing ? l10n.editAssignment : l10n.createAssignment,
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
                ),
              ],
            ),
            Text(
              l10n.assignmentEditorHint,
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.55),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            if (!_isEditing) ...[
              _LessonPicker(
                lessons: lessons,
                value: _selectedLessonId,
                enabled: !_submitting,
                onChanged: (value) => setState(() => _selectedLessonId = value),
              ),
              const SizedBox(height: 14),
            ] else if (_selectedLessonId != null) ...[
              Builder(
                builder: (context) {
                  final lesson = TeacherLessonsStoreProvider.of(context)
                      .lessonById(_selectedLessonId!);
                  if (lesson == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _LessonReadOnly(lesson: lesson),
                      const SizedBox(height: 14),
                    ],
                  );
                },
              ),
            ],
            TextField(
              controller: _titleController,
              enabled: !_submitting,
              decoration: InputDecoration(
                labelText: l10n.assignmentTitleLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _instructionsController,
              enabled: !_submitting,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: l10n.assignmentInstructions,
                hintText: l10n.assignmentInstructionsHint,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_attachmentName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.attach_file,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _attachmentName!,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _submitting ? null : _removeAttachment,
                      icon: const Icon(Icons.close, size: 18),
                      color: AppColors.text.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _submitting ? null : _attachFile,
                icon: const Icon(Icons.attach_file, size: 18),
                label: Text(l10n.attachAssignmentFile),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _save,
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
                  : Text(l10n.saveAssessment),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonPicker extends StatelessWidget {
  const _LessonPicker({
    required this.lessons,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final List<TeacherLesson> lessons;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DropdownButtonFormField<String>(
      key: ValueKey('assignment-lesson-$value'),
      initialValue: value,
      decoration: InputDecoration(
        labelText: l10n.selectLesson,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: lessons
          .map(
            (lesson) => DropdownMenuItem(
              value: lesson.id,
              child: Text(l10n.lessonWeekOption(lesson.weekNumber, lesson.title)),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _LessonReadOnly extends StatelessWidget {
  const _LessonReadOnly({required this.lesson});

  final TeacherLesson lesson;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectLesson,
            style: TextStyle(
              color: AppColors.text.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.lessonWeekOption(lesson.weekNumber, lesson.title),
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
