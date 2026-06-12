import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/learning/data/student_learning_data.dart';
import 'package:kitoapp/features/learning/models/quiz_question.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/app_scaffold.dart';
import 'package:kitoapp/shared/widgets/learning_progress_provider.dart';

class QuizPracticeScreen extends StatefulWidget {
  const QuizPracticeScreen({super.key, required this.itemId});

  final String itemId;

  @override
  State<QuizPracticeScreen> createState() => _QuizPracticeScreenState();
}

class _QuizPracticeScreenState extends State<QuizPracticeScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  final List<int?> _answers = [];
  bool _showResult = false;

  List<QuizQuestion> get _questions =>
      StudentLearningData.quizQuestionsFor(widget.itemId);

  void _selectOption(int index) {
    setState(() => _selectedOption = index);
  }

  void _next() {
    final questions = _questions;
    if (_selectedOption == null) return;

    _answers.add(_selectedOption);
    if (_currentIndex < questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
    } else {
      setState(() => _showResult = true);
    }
  }

  int get _score {
    var correct = 0;
    for (var i = 0; i < _answers.length; i++) {
      if (_answers[i] == _questions[i].correctIndex) correct++;
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = StudentLearningData.findById(widget.itemId);
    final questions = _questions;

    if (item == null || questions.isEmpty) {
      return AppScaffold(
        title: l10n.quizzes,
        body: Center(child: Text(l10n.noLearningItems)),
      );
    }

    final store = LearningProgressProvider.of(context);
    if (!store.isQuizAccessible(widget.itemId)) {
      return AppScaffold(
        title: l10n.quizPractice,
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

    if (_showResult) {
      return AppScaffold(
        title: l10n.quizPractice,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_outlined,
                    size: 64, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  l10n.quizScore(_score, questions.length),
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    store.completeQuiz(widget.itemId);
                    context.pop();
                  },
                  child: Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = questions[_currentIndex];

    return AppScaffold(
      title: l10n.quizPractice,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.questionProgress(_currentIndex + 1, questions.length),
              style: TextStyle(
                color: AppColors.text.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / questions.length,
              minHeight: 4,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),
            Text(
              question.question,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final selected = _selectedOption == index;
                  return Material(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => _selectOption(index),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            FilledButton(
              onPressed: _selectedOption == null ? null : _next,
              child: Text(
                _currentIndex < questions.length - 1
                    ? l10n.next
                    : l10n.finishQuiz,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
