import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/learning/services/student_learning_catalog_store.dart';

class StudentLessonProgressRow {
  const StudentLessonProgressRow({
    required this.lessonId,
    required this.timeSpentSeconds,
    required this.scrollProgress,
    required this.isCompleted,
  });

  final String lessonId;
  final int timeSpentSeconds;
  final double scrollProgress;
  final bool isCompleted;
}

class StudentLearningProgressSnapshot {
  const StudentLearningProgressSnapshot({
    required this.lessons,
    required this.completedQuizIds,
    required this.completedAssignmentIds,
  });

  final Map<String, StudentLessonProgressRow> lessons;
  final Set<String> completedQuizIds;
  final Set<String> completedAssignmentIds;
}

class StudentLearningProgressSupabaseService {
  StudentLearningProgressSupabaseService._();

  static Future<StudentLearningProgressSnapshot> fetchForStudent(
    String studentId,
  ) async {
    final client = SupabaseAuthService.client;

    final lessonRows = await client
        .from('lesson_progress')
        .select()
        .eq('student_id', studentId);

    final quizRows = await client
        .from('quiz_completions')
        .select('quiz_id, quizzes(lesson_id)')
        .eq('student_id', studentId);

    final assignmentRows = await client
        .from('assignment_submissions')
        .select('assignment_id, status, assignments(lesson_id)')
        .eq('student_id', studentId)
        .inFilter('status', ['submitted', 'graded']);

    final lessons = <String, StudentLessonProgressRow>{};
    for (final raw in lessonRows as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final lessonId = row['lesson_id'] as String;
      lessons[lessonId] = StudentLessonProgressRow(
        lessonId: lessonId,
        timeSpentSeconds: row['time_spent_seconds'] as int? ?? 0,
        scrollProgress: (row['scroll_progress'] as num?)?.toDouble() ?? 0,
        isCompleted: row['is_completed'] as bool? ?? false,
      );
    }

    final completedQuizIds = <String>{};
    for (final raw in quizRows as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final quiz = row['quizzes'];
      if (quiz is Map) {
        final lessonId = quiz['lesson_id'] as String?;
        if (lessonId != null) {
          completedQuizIds.add(
            StudentLearningCatalogStore.quizIdForLesson(lessonId),
          );
        }
      }
    }

    final completedAssignmentIds = <String>{};
    for (final raw in assignmentRows as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final assignment = row['assignments'];
      if (assignment is Map) {
        final lessonId = assignment['lesson_id'] as String?;
        if (lessonId != null) {
          completedAssignmentIds.add(
            StudentLearningCatalogStore.assignmentIdForLesson(lessonId),
          );
        }
      }
    }

    return StudentLearningProgressSnapshot(
      lessons: lessons,
      completedQuizIds: completedQuizIds,
      completedAssignmentIds: completedAssignmentIds,
    );
  }

  static Future<void> upsertLessonProgress({
    required String studentId,
    required String lessonId,
    required int timeSpentSeconds,
    required double scrollProgress,
    required bool isCompleted,
  }) async {
    await SupabaseAuthService.client.from('lesson_progress').upsert(
      {
        'student_id': studentId,
        'lesson_id': lessonId,
        'time_spent_seconds': timeSpentSeconds,
        'scroll_progress': scrollProgress.clamp(0.0, 1.0),
        'is_completed': isCompleted,
        if (isCompleted) 'completed_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'student_id,lesson_id',
    );
  }

  static Future<void> recordQuizCompletion({
    required String studentId,
    required String quizId,
    required int score,
    required bool passed,
  }) async {
    await SupabaseAuthService.client.from('quiz_completions').upsert(
      {
        'student_id': studentId,
        'quiz_id': quizId,
        'score': score,
        'passed': passed,
        'completed_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'student_id,quiz_id',
    );
  }

  static Future<void> recordAssignmentSubmission({
    required String studentId,
    required String assignmentId,
    required String answerText,
  }) async {
    await SupabaseAuthService.client.from('assignment_submissions').upsert(
      {
        'assignment_id': assignmentId,
        'student_id': studentId,
        'status': 'submitted',
        'answer_text': answerText.trim(),
        'submitted_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'assignment_id,student_id',
    );
  }
}
