import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment_content.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/teacher_assessments_store_provider.dart';
import 'package:kitoapp/shared/widgets/teacher_lessons_store_provider.dart';

void showEditQuizSheet(
  BuildContext context, {
  String? lessonId,
  QuizContent? existing,
}) {
  final messenger = ScaffoldMessenger.of(context);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _EditQuizSheet(
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

class _EditQuizSheet extends StatefulWidget {
  const _EditQuizSheet({
    required this.onClose,
    required this.onSuccess,
    this.lessonId,
    this.existing,
  });

  final VoidCallback onClose;
  final void Function(String message) onSuccess;
  final String? lessonId;
  final QuizContent? existing;

  @override
  State<_EditQuizSheet> createState() => _EditQuizSheetState();
}

class _EditQuizSheetState extends State<_EditQuizSheet> {
  final _titleController = TextEditingController();
  String? _selectedLessonId;
  final List<QuizQuestionDraft> _questions = [];
  bool _submitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _selectedLessonId = widget.lessonId ?? widget.existing?.lessonId;
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _questions.addAll(
        widget.existing!.questions.map(QuizQuestionDraft.fromQuestion),
      );
    } else {
      _questions.add(QuizQuestionDraft());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() => _questions.add(QuizQuestionDraft()));
  }

  void _removeQuestion(int index) {
    if (_questions.length <= 1) return;
    setState(() => _questions.removeAt(index));
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
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.quizTitleRequired)),
      );
      return;
    }

    if (_questions.isEmpty || !_questions.every((q) => q.isValid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.quizQuestionsInvalid)),
      );
      return;
    }

    setState(() => _submitting = true);

    TeacherAssessmentsStoreProvider.of(context).saveQuiz(
      QuizContent(
        lessonId: lessonId,
        title: title,
        questions: _questions.map((q) => q.toQuestion()).toList(),
      ),
    );

    widget.onSuccess(l10n.assessmentSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = TeacherAssessmentsStoreProvider.of(context);
    final lessons = store.lessonsAvailableForQuiz(
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
                    _isEditing ? l10n.editQuiz : l10n.createQuiz,
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
              l10n.quizEditorHint,
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
                labelText: l10n.quizTitleLabel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  l10n.quizQuestions,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _submitting ? null : _addQuestion,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addQuestion),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _questions.length; i++)
              _QuestionCard(
                key: ValueKey('question-$i'),
                index: i,
                draft: _questions[i],
                canRemove: _questions.length > 1,
                enabled: !_submitting,
                onChanged: () => setState(() {}),
                onRemove: () => _removeQuestion(i),
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

class _QuestionCard extends StatefulWidget {
  const _QuestionCard({
    super.key,
    required this.index,
    required this.draft,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
    this.enabled = true,
  });

  final int index;
  final QuizQuestionDraft draft;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final bool enabled;

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late final TextEditingController _questionController;
  late final List<TextEditingController> _optionControllers;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.draft.question);
    _optionControllers = widget.draft.options
        .map((option) => TextEditingController(text: option))
        .toList();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l10n.questionNumber(widget.index + 1),
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (widget.canRemove)
                IconButton(
                  onPressed: widget.enabled ? widget.onRemove : null,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.text.withValues(alpha: 0.45),
                ),
            ],
          ),
          TextField(
            enabled: widget.enabled,
            controller: _questionController,
            onChanged: (value) {
              widget.draft.question = value;
              widget.onChanged();
            },
            decoration: InputDecoration(
              labelText: l10n.questionText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < widget.draft.options.length; i++) ...[
            Row(
              children: [
                Radio<int>(
                  value: i,
                  groupValue: widget.draft.correctIndex,
                  activeColor: AppColors.primary,
                  onChanged: widget.enabled
                      ? (value) {
                          if (value != null) {
                            setState(() => widget.draft.correctIndex = value);
                            widget.onChanged();
                          }
                        }
                      : null,
                ),
                Expanded(
                  child: TextField(
                    enabled: widget.enabled,
                    controller: _optionControllers[i],
                    onChanged: (value) {
                      widget.draft.options[i] = value;
                      widget.onChanged();
                    },
                    decoration: InputDecoration(
                      labelText: l10n.optionLabel(i + 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            l10n.correctAnswerHint,
            style: TextStyle(
              color: AppColors.text.withValues(alpha: 0.45),
              fontSize: 11,
            ),
          ),
        ],
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
      key: ValueKey('quiz-lesson-$value'),
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
