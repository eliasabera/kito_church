import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/learning/models/quiz_question.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment_content.dart';
import 'package:kitoapp/features/learning/services/teacher_lessons_supabase_service.dart';

class AssignmentLoadResult {
  const AssignmentLoadResult({
    required this.id,
    required this.content,
    required this.submissions,
  });

  final String id;
  final AssignmentContent content;
  final List<StudentSubmissionRow> submissions;
}

class QuizLoadResult {
  const QuizLoadResult({
    required this.id,
    required this.content,
    required this.attempted,
    required this.avgScore,
    required this.passed,
  });

  final String id;
  final QuizContent content;
  final int attempted;
  final int avgScore;
  final int passed;
}

class TeacherAssessmentsSupabaseService {
  TeacherAssessmentsSupabaseService._();

  static Future<Map<String, AssignmentLoadResult>> fetchAssignmentsForTeacher(
    String teacherId,
  ) async {
    final lessonIds =
        await TeacherLessonsSupabaseService.fetchLessonIdsForTeacher(teacherId);
    return fetchAssignmentsForLessons(lessonIds);
  }

  static Future<Map<String, AssignmentLoadResult>> fetchAssignmentsForLessons(
    List<String> lessonIds,
  ) async {
    if (lessonIds.isEmpty) return {};

    final rows = await SupabaseAuthService.client
        .from('assignments')
        .select()
        .inFilter('lesson_id', lessonIds);

    final assignments = (rows as List).cast<Map<String, dynamic>>();
    if (assignments.isEmpty) return {};

    final assignmentIds = assignments.map((row) => row['id'] as String).toList();
    final submissionsByAssignment =
        await _fetchSubmissionsByAssignment(assignmentIds);

    return {
      for (final row in assignments)
        row['lesson_id'] as String: AssignmentLoadResult(
          id: row['id'] as String,
          content: AssignmentContent(
            lessonId: row['lesson_id'] as String,
            title: row['title'] as String,
            instructions: row['instructions'] as String? ?? '',
            attachmentName: row['attachment_path'] as String?,
          ),
          submissions: submissionsByAssignment[row['id'] as String] ?? const [],
        ),
    };
  }

  static Future<Map<String, QuizLoadResult>> fetchQuizzesForTeacher(
    String teacherId,
  ) async {
    final lessonIds =
        await TeacherLessonsSupabaseService.fetchLessonIdsForTeacher(teacherId);
    return fetchQuizzesForLessons(lessonIds);
  }

  static Future<Map<String, QuizLoadResult>> fetchQuizzesForLessons(
    List<String> lessonIds,
  ) async {
    if (lessonIds.isEmpty) return {};

    final rows = await SupabaseAuthService.client
        .from('quizzes')
        .select('*, quiz_questions(*)')
        .inFilter('lesson_id', lessonIds);

    final quizzes = (rows as List).cast<Map<String, dynamic>>();
    if (quizzes.isEmpty) return {};

    final quizIds = quizzes.map((row) => row['id'] as String).toList();
    final statsByQuiz = await _fetchQuizStats(quizIds);

    return {
      for (final row in quizzes)
        row['lesson_id'] as String: _quizFromRow(
          row,
          stats: statsByQuiz[row['id'] as String],
        ),
    };
  }

  static Future<String> saveAssignment(AssignmentContent content) async {
    final row = await SupabaseAuthService.client
        .from('assignments')
        .upsert(
          {
            'lesson_id': content.lessonId,
            'title': content.title.trim(),
            'instructions': content.instructions.trim(),
            'attachment_path': content.attachmentName,
          },
          onConflict: 'lesson_id',
        )
        .select()
        .single();

    return row['id'] as String;
  }

  static Future<String> saveQuiz(QuizContent content) async {
    final quizRow = await SupabaseAuthService.client
        .from('quizzes')
        .upsert(
          {
            'lesson_id': content.lessonId,
            'title': content.title.trim(),
          },
          onConflict: 'lesson_id',
        )
        .select()
        .single();

    final quizId = quizRow['id'] as String;

    await SupabaseAuthService.client
        .from('quiz_questions')
        .delete()
        .eq('quiz_id', quizId);

    if (content.questions.isNotEmpty) {
      await SupabaseAuthService.client.from('quiz_questions').insert(
        content.questions.asMap().entries.map((entry) {
          final question = entry.value;
          return {
            'quiz_id': quizId,
            'question': question.question,
            'options': question.options,
            'correct_index': question.correctIndex,
            'sort_order': entry.key,
          };
        }).toList(),
      );
    }

    return quizId;
  }

  static QuizLoadResult _quizFromRow(
    Map<String, dynamic> row, {
    ({int attempted, int avgScore, int passed})? stats,
  }) {
    final questionsRaw = row['quiz_questions'];
    final questionRows = questionsRaw is List ? questionsRaw : const [];
    questionRows.sort((a, b) {
      final aOrder = (a as Map)['sort_order'] as int? ?? 0;
      final bOrder = (b as Map)['sort_order'] as int? ?? 0;
      return aOrder.compareTo(bOrder);
    });

    final questions = questionRows.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final optionsRaw = map['options'];
      final options = optionsRaw is List
          ? optionsRaw.map((option) => option.toString()).toList()
          : <String>[];
      return QuizQuestion(
        question: map['question'] as String,
        options: options,
        correctIndex: map['correct_index'] as int? ?? 0,
      );
    }).toList();

    return QuizLoadResult(
      id: row['id'] as String,
      content: QuizContent(
        lessonId: row['lesson_id'] as String,
        title: row['title'] as String,
        questions: questions,
      ),
      attempted: stats?.attempted ?? 0,
      avgScore: stats?.avgScore ?? 0,
      passed: stats?.passed ?? 0,
    );
  }

  static Future<Map<String, List<StudentSubmissionRow>>>
      _fetchSubmissionsByAssignment(List<String> assignmentIds) async {
    if (assignmentIds.isEmpty) return {};

    final rows = await SupabaseAuthService.client
        .from('assignment_submissions')
        .select(
          'assignment_id, status, score, users(full_name)',
        )
        .inFilter('assignment_id', assignmentIds);

    final grouped = <String, List<StudentSubmissionRow>>{};
    for (final row in rows as List) {
      final map = Map<String, dynamic>.from(row as Map);
      final assignmentId = map['assignment_id'] as String;
      grouped.putIfAbsent(assignmentId, () => []).add(
            StudentSubmissionRow(
              studentName: _studentNameFromRow(map),
              status: _parseSubmissionStatus(map['status'] as String?),
              score: map['score'] as int?,
            ),
          );
    }
    return grouped;
  }

  static Future<Map<String, ({int attempted, int avgScore, int passed})>>
      _fetchQuizStats(List<String> quizIds) async {
    if (quizIds.isEmpty) return {};

    final rows = await SupabaseAuthService.client
        .from('quiz_completions')
        .select('quiz_id, score, passed')
        .inFilter('quiz_id', quizIds);

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in rows as List) {
      final map = Map<String, dynamic>.from(row as Map);
      final quizId = map['quiz_id'] as String;
      grouped.putIfAbsent(quizId, () => []).add(map);
    }

    return {
      for (final entry in grouped.entries)
        entry.key: _quizStatsFromRows(entry.value),
    };
  }

  static ({int attempted, int avgScore, int passed}) _quizStatsFromRows(
    List<Map<String, dynamic>> rows,
  ) {
    if (rows.isEmpty) {
      return (attempted: 0, avgScore: 0, passed: 0);
    }

    final scores = rows
        .map((row) => row['score'] as int? ?? 0)
        .where((score) => score > 0)
        .toList();
    final avgScore = scores.isEmpty
        ? 0
        : scores.reduce((a, b) => a + b) ~/ scores.length;
    final passed = rows.where((row) => row['passed'] as bool? ?? false).length;

    return (attempted: rows.length, avgScore: avgScore, passed: passed);
  }

  static String _studentNameFromRow(Map<String, dynamic> row) {
    final users = row['users'];
    if (users is Map) {
      return users['full_name'] as String? ?? 'Student';
    }
    if (users is List && users.isNotEmpty) {
      return (users.first as Map)['full_name'] as String? ?? 'Student';
    }
    return 'Student';
  }

  static SubmissionStatus _parseSubmissionStatus(String? value) {
    return switch (value) {
      'submitted' => SubmissionStatus.submitted,
      'graded' => SubmissionStatus.graded,
      _ => SubmissionStatus.notSubmitted,
    };
  }

  static String? get currentTeacherId => AuthSession.userId;
}
