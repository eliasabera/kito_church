import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/features/learning/models/learning_item.dart';
import 'package:kitoapp/features/learning/models/lesson_unit.dart';
import 'package:kitoapp/features/learning/models/quiz_question.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';
import 'package:kitoapp/features/learning/services/teacher_assessments_store.dart';
import 'package:kitoapp/features/learning/services/teacher_lessons_store.dart';

/// Builds the student learning path from teacher-published Supabase content.
class StudentLearningCatalogStore extends ChangeNotifier {
  StudentLearningCatalogStore({
    required TeacherLessonsStore lessonsStore,
    required TeacherAssessmentsStore assessmentsStore,
  })  : _lessonsStore = lessonsStore,
        _assessmentsStore = assessmentsStore {
    _lessonsStore.addListener(notifyListeners);
    _assessmentsStore.addListener(notifyListeners);
  }

  final TeacherLessonsStore _lessonsStore;
  final TeacherAssessmentsStore _assessmentsStore;

  bool get isLoading =>
      _lessonsStore.isLoading || _assessmentsStore.isLoading;

  bool get hasPublishedLessons => _lessonsStore.publishedLessons.isNotEmpty;

  static String quizIdForLesson(String lessonId) => 'qz-$lessonId';

  static String assignmentIdForLesson(String lessonId) => 'as-$lessonId';

  List<LessonWeek> get weeks {
    return _teacherWeeks()
      ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
  }

  LearningItem? findById(String id) {
    for (final week in weeks) {
      if (week.lesson.id == id) return week.lesson;
      if (week.quiz?.id == id) return week.quiz;
      if (week.assignment?.id == id) return week.assignment;
    }
    return null;
  }

  LessonWeek? weekForLessonId(String lessonId) {
    for (final week in weeks) {
      if (week.lesson.id == lessonId) return week;
    }
    return null;
  }

  LessonWeek? weekContainingItem(String itemId) {
    for (final week in weeks) {
      if (week.lesson.id == itemId) return week;
      if (week.quiz?.id == itemId) return week;
      if (week.assignment?.id == itemId) return week;
    }
    return null;
  }

  LessonWeek? weekForNumber(int weekNumber) {
    for (final week in weeks) {
      if (week.weekNumber == weekNumber) return week;
    }
    return null;
  }

  String lessonContentFor(String lessonId) {
    final teacherLesson = _lessonsStore.lessonById(lessonId);
    if (teacherLesson != null) {
      final description = teacherLesson.description?.trim();
      if (description != null && description.isNotEmpty) {
        return description;
      }
      return 'Lesson: ${teacherLesson.title}\n\n'
          'Read this week\'s material and complete the connected quiz or assignment when ready.';
    }
    return '';
  }

  List<QuizQuestion> quizQuestionsFor(String quizId) {
    final lessonId = _lessonIdFromQuizId(quizId);
    if (lessonId != null) {
      final content = _assessmentsStore.quizContentFor(lessonId);
      if (content != null && content.questions.isNotEmpty) {
        return content.questions;
      }
    }
    return const [];
  }

  String assignmentInstructionsFor(String assignmentId) {
    final lessonId = _lessonIdFromAssignmentId(assignmentId);
    if (lessonId != null) {
      final content = _assessmentsStore.assignmentContentFor(lessonId);
      if (content != null && content.instructions.trim().isNotEmpty) {
        return content.instructions.trim();
      }
    }
    final item = findById(assignmentId);
    return item?.description ??
        'Complete this assignment and submit your work before the deadline.';
  }

  @override
  void dispose() {
    _lessonsStore.removeListener(notifyListeners);
    _assessmentsStore.removeListener(notifyListeners);
    super.dispose();
  }

  List<LessonWeek> _teacherWeeks() {
    return _lessonsStore.publishedLessons.map(_weekFromTeacherLesson).toList();
  }

  LessonWeek _weekFromTeacherLesson(TeacherLesson lesson) {
    final quizId = quizIdForLesson(lesson.id);
    final assignmentId = assignmentIdForLesson(lesson.id);
    final quizContent = _assessmentsStore.quizContentFor(lesson.id);
    final assignmentContent = _assessmentsStore.assignmentContentFor(lesson.id);
    final dueLabel = DateFormat.MMMd().format(lesson.deadline);

    return LessonWeek(
      weekNumber: lesson.weekNumber,
      title: lesson.title,
      postedDate: lesson.postedDate,
      sessionDate: lesson.postedDate.add(const Duration(days: 1)),
      deadline: lesson.deadline,
      lesson: LearningItem(
        id: lesson.id,
        title: lesson.title,
        subtitle: 'Week ${lesson.weekNumber}',
        teacherName: 'Teacher',
        description: lesson.description,
        type: LearningItemType.lesson,
        status: LearningItemStatus.newItem,
        dueDate: dueLabel,
      ),
      quiz: lesson.hasQuiz
          ? LearningItem(
              id: quizId,
              title: quizContent?.title.trim().isNotEmpty == true
                  ? quizContent!.title
                  : 'Week ${lesson.weekNumber} Quiz',
              subtitle: quizContent?.questions.isNotEmpty == true
                  ? '${quizContent!.questions.length} questions'
                  : l10nPlaceholderQuizSubtitle,
              teacherName: 'Teacher',
              description: 'Quiz for ${lesson.title}',
              type: LearningItemType.quiz,
              status: LearningItemStatus.newItem,
              dueDate: dueLabel,
            )
          : null,
      assignment: lesson.hasAssignment
          ? LearningItem(
              id: assignmentId,
              title: assignmentContent?.title.trim().isNotEmpty == true
                  ? assignmentContent!.title
                  : 'Week ${lesson.weekNumber} Assignment',
              subtitle: l10nPlaceholderAssignmentSubtitle,
              teacherName: 'Teacher',
              description: assignmentContent?.instructions,
              type: LearningItemType.assignment,
              status: LearningItemStatus.pending,
              dueDate: dueLabel,
            )
          : null,
    );
  }

  static const l10nPlaceholderQuizSubtitle = 'Quiz';
  static const l10nPlaceholderAssignmentSubtitle = 'Assignment';

  String? _lessonIdFromQuizId(String quizId) {
    if (quizId.startsWith('qz-')) return quizId.substring(3);
    for (final week in weeks) {
      if (week.quiz?.id == quizId) return week.lesson.id;
    }
    return null;
  }

  String? _lessonIdFromAssignmentId(String assignmentId) {
    if (assignmentId.startsWith('as-')) return assignmentId.substring(3);
    for (final week in weeks) {
      if (week.assignment?.id == assignmentId) return week.lesson.id;
    }
    return null;
  }
}
