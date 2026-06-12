import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/attendance/data/teacher_attendance_data.dart';
import 'package:kitoapp/features/learning/data/teacher_assessments_data.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment_content.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';
import 'package:kitoapp/features/learning/services/teacher_lessons_store.dart';

class TeacherAssessmentsStore extends ChangeNotifier {
  TeacherAssessmentsStore({required TeacherLessonsStore lessonsStore})
      : _lessonsStore = lessonsStore {
    _assignments = Map.of(TeacherAssessmentsData.initialAssignments);
    _quizzes = Map.of(TeacherAssessmentsData.initialQuizzes);
    _lessonsStore.addListener(_onLessonsChanged);
  }

  final TeacherLessonsStore _lessonsStore;
  late Map<String, AssignmentContent> _assignments;
  late Map<String, QuizContent> _quizzes;

  @override
  void dispose() {
    _lessonsStore.removeListener(_onLessonsChanged);
    super.dispose();
  }

  void _onLessonsChanged() => notifyListeners();

  AssignmentContent? assignmentContentFor(String lessonId) =>
      _assignments[lessonId];

  QuizContent? quizContentFor(String lessonId) => _quizzes[lessonId];

  List<TeacherAssignment> get assignments => _buildAssignments();

  List<TeacherQuiz> get quizzes => _buildQuizzes();

  TeacherAssignmentsSummary get assignmentsSummary {
    final list = assignments;
    return TeacherAssignmentsSummary(
      total: list.length,
      pendingReview: list.fold(0, (sum, a) => sum + a.pendingReview),
      submitted: list.fold(0, (sum, a) => sum + a.submitted),
      studentsTotal: list.isEmpty ? 0 : list.first.total,
    );
  }

  TeacherQuizzesSummary get quizzesSummary {
    final list = quizzes;
    if (list.isEmpty) {
      return const TeacherQuizzesSummary(
        total: 0,
        avgClassScore: 0,
        attempted: 0,
        studentsTotal: 0,
      );
    }
    final avg =
        list.map((q) => q.avgScore).reduce((a, b) => a + b) ~/ list.length;
    return TeacherQuizzesSummary(
      total: list.length,
      avgClassScore: avg,
      attempted: list.fold(0, (sum, q) => sum + q.attempted),
      studentsTotal: list.first.total,
    );
  }

  List<TeacherAssignment> assignmentsFor(TeacherAssessmentFilter filter) {
    return _filterAssignments(assignments, filter);
  }

  List<TeacherQuiz> quizzesFor(TeacherAssessmentFilter filter) {
    return _filterQuizzes(quizzes, filter);
  }

  List<TeacherLesson> lessonsAvailableForAssignment({String? editingLessonId}) {
    return _lessonsStore.publishedLessons.where((lesson) {
      if (editingLessonId != null && lesson.id == editingLessonId) {
        return true;
      }
      return !lesson.hasAssignment;
    }).toList();
  }

  List<TeacherLesson> lessonsAvailableForQuiz({String? editingLessonId}) {
    return _lessonsStore.publishedLessons.where((lesson) {
      if (editingLessonId != null && lesson.id == editingLessonId) {
        return true;
      }
      return !lesson.hasQuiz;
    }).toList();
  }

  void saveAssignment(AssignmentContent content) {
    _assignments[content.lessonId] = content;
    _lessonsStore.updateLessonFlags(content.lessonId, hasAssignment: true);
    notifyListeners();
  }

  void saveQuiz(QuizContent content) {
    _quizzes[content.lessonId] = content;
    _lessonsStore.updateLessonFlags(content.lessonId, hasQuiz: true);
    notifyListeners();
  }

  List<StudentSubmissionRow> submissionsForAssignment(
    TeacherAssignment assignment,
  ) {
    final names = TeacherAttendanceData.studentNames.take(assignment.total);
    return names.map((name) {
      final index = names.toList().indexOf(name);
      if (index >= assignment.submitted) {
        return StudentSubmissionRow(
          studentName: name,
          status: SubmissionStatus.notSubmitted,
        );
      }
      if (index >= assignment.graded) {
        return StudentSubmissionRow(
          studentName: name,
          status: SubmissionStatus.submitted,
        );
      }
      return StudentSubmissionRow(
        studentName: name,
        status: SubmissionStatus.graded,
        score: 70 + (index * 4) % 30,
      );
    }).toList();
  }

  List<TeacherAssignment> _buildAssignments() {
    final items = <TeacherAssignment>[];
    for (final lesson in _lessonsStore.publishedLessons) {
      if (!lesson.hasAssignment) continue;
      final content = _assignments[lesson.id];
      final configured = content?.isConfigured ?? false;
      items.add(
        TeacherAssignment(
          id: 'as-${lesson.id}',
          lessonId: lesson.id,
          weekNumber: lesson.weekNumber,
          title: configured
              ? content!.title
              : _defaultAssignmentTitle(lesson.weekNumber),
          lessonTitle: lesson.title,
          deadline: lesson.deadline,
          submitted: _submittedFor(lesson),
          total: lesson.studentsTotal,
          pendingReview: _pendingReviewFor(lesson),
          graded: _gradedFor(lesson),
          isConfigured: configured,
        ),
      );
    }
    return items;
  }

  List<TeacherQuiz> _buildQuizzes() {
    final items = <TeacherQuiz>[];
    for (final lesson in _lessonsStore.publishedLessons) {
      if (!lesson.hasQuiz) continue;
      final content = _quizzes[lesson.id];
      final configured = content?.isConfigured ?? false;
      items.add(
        TeacherQuiz(
          id: 'qz-${lesson.id}',
          lessonId: lesson.id,
          weekNumber: lesson.weekNumber,
          title: configured
              ? content!.title
              : _defaultQuizTitle(lesson.weekNumber),
          lessonTitle: lesson.title,
          deadline: lesson.deadline,
          attempted: _attemptedFor(lesson),
          total: lesson.studentsTotal,
          avgScore: _avgScoreFor(lesson),
          passed: _passedFor(lesson),
          questionCount: content?.questions.length ?? 0,
          isConfigured: configured,
        ),
      );
    }
    return items;
  }

  static List<TeacherAssignment> _filterAssignments(
    List<TeacherAssignment> list,
    TeacherAssessmentFilter filter,
  ) {
    return switch (filter) {
      TeacherAssessmentFilter.all => list,
      TeacherAssessmentFilter.pending => list
          .where(
            (a) =>
                !a.isConfigured ||
                a.pendingReview > 0 ||
                a.notSubmitted > 0,
          )
          .toList(),
      TeacherAssessmentFilter.completed =>
        list.where((a) => a.isConfigured && a.isComplete).toList(),
    };
  }

  static List<TeacherQuiz> _filterQuizzes(
    List<TeacherQuiz> list,
    TeacherAssessmentFilter filter,
  ) {
    return switch (filter) {
      TeacherAssessmentFilter.all => list,
      TeacherAssessmentFilter.pending => list
          .where((q) => !q.isConfigured || q.notAttempted > 0)
          .toList(),
      TeacherAssessmentFilter.completed =>
        list.where((q) => q.isConfigured && q.isComplete).toList(),
    };
  }

  static String _defaultAssignmentTitle(int week) => 'Week $week Assignment';

  static String _defaultQuizTitle(int week) => 'Week $week Quiz';

  static int _submittedFor(TeacherLesson lesson) {
    return switch (lesson.status) {
      TeacherLessonStatus.closed => lesson.studentsTotal - 2,
      TeacherLessonStatus.active => (lesson.studentsCompleted * 0.7).round(),
      _ => 0,
    };
  }

  static int _pendingReviewFor(TeacherLesson lesson) {
    final submitted = _submittedFor(lesson);
    final graded = _gradedFor(lesson);
    return (submitted - graded).clamp(0, submitted);
  }

  static int _gradedFor(TeacherLesson lesson) {
    if (lesson.status == TeacherLessonStatus.closed) {
      return lesson.studentsTotal - 4;
    }
    if (lesson.status == TeacherLessonStatus.active) {
      return (_submittedFor(lesson) * 0.6).round();
    }
    return 0;
  }

  static int _attemptedFor(TeacherLesson lesson) {
    return switch (lesson.status) {
      TeacherLessonStatus.closed => lesson.studentsTotal - 1,
      TeacherLessonStatus.active => lesson.studentsCompleted,
      _ => 0,
    };
  }

  static int _avgScoreFor(TeacherLesson lesson) {
    return switch (lesson.status) {
      TeacherLessonStatus.closed => 84,
      TeacherLessonStatus.active => 76,
      _ => 0,
    };
  }

  static int _passedFor(TeacherLesson lesson) {
    final attempted = _attemptedFor(lesson);
    return (attempted * 0.85).round();
  }
}
