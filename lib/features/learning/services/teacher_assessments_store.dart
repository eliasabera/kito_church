import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment_content.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';
import 'package:kitoapp/features/learning/services/teacher_assessments_supabase_service.dart';
import 'package:kitoapp/features/learning/services/teacher_lessons_store.dart';

class TeacherAssessmentsStore extends ChangeNotifier {
  TeacherAssessmentsStore({required TeacherLessonsStore lessonsStore})
      : _lessonsStore = lessonsStore {
    _lessonsStore.addListener(_onLessonsChanged);
  }

  final TeacherLessonsStore _lessonsStore;
  final Map<String, AssignmentContent> _assignments = {};
  final Map<String, QuizContent> _quizzes = {};
  final Map<String, String> _assignmentIdsByLesson = {};
  final Map<String, String> _quizIdsByLesson = {};
  final Map<String, List<StudentSubmissionRow>> _submissionsByLesson = {};
  final Map<String, ({int attempted, int avgScore, int passed})> _quizStatsByLesson =
      {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

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
      pendingReview: list.fold(0, (sum, item) => sum + item.pendingReview),
      submitted: list.fold(0, (sum, item) => sum + item.submitted),
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
        list.map((quiz) => quiz.avgScore).reduce((a, b) => a + b) ~/ list.length;
    return TeacherQuizzesSummary(
      total: list.length,
      avgClassScore: avg,
      attempted: list.fold(0, (sum, quiz) => sum + quiz.attempted),
      studentsTotal: list.first.total,
    );
  }

  Future<void> loadFromSupabase() async {
    final teacherId = TeacherAssessmentsSupabaseService.currentTeacherId;
    if (teacherId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final assignmentResults =
          await TeacherAssessmentsSupabaseService.fetchAssignmentsForTeacher(
        teacherId,
      );
      final quizResults =
          await TeacherAssessmentsSupabaseService.fetchQuizzesForTeacher(
        teacherId,
      );
      _applyLoadResults(
        assignmentResults: assignmentResults,
        quizResults: quizResults,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'TeacherAssessmentsStore.loadFromSupabase failed: $error\n$stackTrace',
      );
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadForPublishedLessons() async {
    final lessonIds =
        _lessonsStore.publishedLessons.map((lesson) => lesson.id).toList();
    if (lessonIds.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final assignmentResults =
          await TeacherAssessmentsSupabaseService.fetchAssignmentsForLessons(
        lessonIds,
      );
      final quizResults =
          await TeacherAssessmentsSupabaseService.fetchQuizzesForLessons(
        lessonIds,
      );
      _applyLoadResults(
        assignmentResults: assignmentResults,
        quizResults: quizResults,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'TeacherAssessmentsStore.loadForPublishedLessons failed: $error\n$stackTrace',
      );
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyLoadResults({
    required Map<String, AssignmentLoadResult> assignmentResults,
    required Map<String, QuizLoadResult> quizResults,
  }) {
    _assignments
      ..clear()
      ..addEntries(
        assignmentResults.entries.map(
          (entry) => MapEntry(entry.key, entry.value.content),
        ),
      );
    _assignmentIdsByLesson
      ..clear()
      ..addEntries(
        assignmentResults.entries.map(
          (entry) => MapEntry(entry.key, entry.value.id),
        ),
      );
    _submissionsByLesson
      ..clear()
      ..addEntries(
        assignmentResults.entries.map(
          (entry) => MapEntry(entry.key, entry.value.submissions),
        ),
      );

    _quizzes
      ..clear()
      ..addEntries(
        quizResults.entries.map(
          (entry) => MapEntry(entry.key, entry.value.content),
        ),
      );
    _quizIdsByLesson
      ..clear()
      ..addEntries(
        quizResults.entries.map(
          (entry) => MapEntry(entry.key, entry.value.id),
        ),
      );
    _quizStatsByLesson
      ..clear()
      ..addEntries(
        quizResults.entries.map(
          (entry) => MapEntry(
            entry.key,
            (
              attempted: entry.value.attempted,
              avgScore: entry.value.avgScore,
              passed: entry.value.passed,
            ),
          ),
        ),
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

  Future<void> saveAssignment(AssignmentContent content) async {
    try {
      final assignmentId =
          await TeacherAssessmentsSupabaseService.saveAssignment(content);
      _assignments[content.lessonId] = content;
      _assignmentIdsByLesson[content.lessonId] = assignmentId;
      _submissionsByLesson.putIfAbsent(content.lessonId, () => []);
      await _lessonsStore.updateLessonFlags(
        content.lessonId,
        hasAssignment: true,
      );
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint(
        'TeacherAssessmentsStore.saveAssignment failed: $error\n$stackTrace',
      );
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> saveQuiz(QuizContent content) async {
    try {
      final quizId = await TeacherAssessmentsSupabaseService.saveQuiz(content);
      _quizzes[content.lessonId] = content;
      _quizIdsByLesson[content.lessonId] = quizId;
      _quizStatsByLesson.putIfAbsent(
        content.lessonId,
        () => (attempted: 0, avgScore: 0, passed: 0),
      );
      await _lessonsStore.updateLessonFlags(content.lessonId, hasQuiz: true);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('TeacherAssessmentsStore.saveQuiz failed: $error\n$stackTrace');
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<StudentSubmissionRow> submissionsForAssignment(
    TeacherAssignment assignment,
  ) {
    return List.unmodifiable(_submissionsByLesson[assignment.lessonId] ?? const []);
  }

  List<TeacherAssignment> _buildAssignments() {
    final items = <TeacherAssignment>[];
    for (final lesson in _lessonsStore.publishedLessons) {
      if (!lesson.hasAssignment) continue;
      final content = _assignments[lesson.id];
      final configured = content?.isConfigured ?? false;
      final submissions = _submissionsByLesson[lesson.id] ?? const [];
      final submitted = submissions
          .where((row) => row.status != SubmissionStatus.notSubmitted)
          .length;
      final pendingReview = submissions
          .where((row) => row.status == SubmissionStatus.submitted)
          .length;
      final graded =
          submissions.where((row) => row.status == SubmissionStatus.graded).length;
      final assignmentId =
          _assignmentIdsByLesson[lesson.id] ?? 'as-${lesson.id}';

      items.add(
        TeacherAssignment(
          id: assignmentId,
          lessonId: lesson.id,
          weekNumber: lesson.weekNumber,
          title: configured
              ? content!.title
              : _defaultAssignmentTitle(lesson.weekNumber),
          lessonTitle: lesson.title,
          deadline: lesson.deadline,
          submitted: submitted,
          total: lesson.studentsTotal,
          pendingReview: pendingReview,
          graded: graded,
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
      final stats = _quizStatsByLesson[lesson.id];
      final quizId = _quizIdsByLesson[lesson.id] ?? 'qz-${lesson.id}';

      items.add(
        TeacherQuiz(
          id: quizId,
          lessonId: lesson.id,
          weekNumber: lesson.weekNumber,
          title: configured
              ? content!.title
              : _defaultQuizTitle(lesson.weekNumber),
          lessonTitle: lesson.title,
          deadline: lesson.deadline,
          attempted: stats?.attempted ?? 0,
          total: lesson.studentsTotal,
          avgScore: stats?.avgScore ?? 0,
          passed: stats?.passed ?? 0,
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
            (item) =>
                !item.isConfigured ||
                item.pendingReview > 0 ||
                item.notSubmitted > 0,
          )
          .toList(),
      TeacherAssessmentFilter.completed =>
        list.where((item) => item.isConfigured && item.isComplete).toList(),
    };
  }

  static List<TeacherQuiz> _filterQuizzes(
    List<TeacherQuiz> list,
    TeacherAssessmentFilter filter,
  ) {
    return switch (filter) {
      TeacherAssessmentFilter.all => list,
      TeacherAssessmentFilter.pending => list
          .where((item) => !item.isConfigured || item.notAttempted > 0)
          .toList(),
      TeacherAssessmentFilter.completed =>
        list.where((item) => item.isConfigured && item.isComplete).toList(),
    };
  }

  static String _defaultAssignmentTitle(int week) => 'Week $week Assignment';

  static String _defaultQuizTitle(int week) => 'Week $week Quiz';
}
