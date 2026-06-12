import 'package:kitoapp/features/learning/models/quiz_question.dart';

class AssignmentContent {
  const AssignmentContent({
    required this.lessonId,
    required this.title,
    required this.instructions,
    this.attachmentName,
  });

  final String lessonId;
  final String title;
  final String instructions;
  final String? attachmentName;

  bool get isConfigured => title.trim().isNotEmpty && instructions.trim().isNotEmpty;
}

class QuizContent {
  const QuizContent({
    required this.lessonId,
    required this.title,
    required this.questions,
  });

  final String lessonId;
  final String title;
  final List<QuizQuestion> questions;

  bool get isConfigured =>
      title.trim().isNotEmpty && questions.isNotEmpty;
}

class QuizQuestionDraft {
  QuizQuestionDraft({
    this.question = '',
    List<String>? options,
    this.correctIndex = 0,
  }) : options = options ?? ['', '', '', ''];

  String question;
  List<String> options;
  int correctIndex;

  bool get isValid =>
      question.trim().isNotEmpty &&
      options.every((o) => o.trim().isNotEmpty);

  QuizQuestion toQuestion() {
    return QuizQuestion(
      question: question.trim(),
      options: options.map((o) => o.trim()).toList(),
      correctIndex: correctIndex,
    );
  }

  static QuizQuestionDraft fromQuestion(QuizQuestion question) {
    final options = List<String>.from(question.options);
    while (options.length < 4) {
      options.add('');
    }
    return QuizQuestionDraft(
      question: question.question,
      options: options.take(4).toList(),
      correctIndex: question.correctIndex,
    );
  }
}
