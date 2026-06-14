import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';

class TeacherLessonsSupabaseService {
  TeacherLessonsSupabaseService._();

  static Future<List<TeacherLesson>> fetchPublishedLessons() async {
    final rows = await SupabaseAuthService.client
        .from('teacher_lessons')
        .select()
        .neq('status', TeacherLessonStatus.draft.name)
        .order('week_number', ascending: false);

    final lessons = (rows as List).cast<Map<String, dynamic>>();
    if (lessons.isEmpty) return const [];

    final lessonIds = lessons.map((row) => row['id'] as String).toList();
    final progressCounts = await _fetchProgressCounts(lessonIds);
    final activeStudents = await _fetchActiveStudentCount();

    return lessons
        .map(
          (row) => _lessonFromRow(
            row,
            progressCounts: progressCounts,
            activeStudents: activeStudents,
          ),
        )
        .toList();
  }

  static Future<List<TeacherLesson>> fetchLessonsForTeacher(
    String teacherId,
  ) async {
    final rows = await SupabaseAuthService.client
        .from('teacher_lessons')
        .select()
        .eq('teacher_id', teacherId)
        .order('week_number', ascending: false);

    final lessons = (rows as List).cast<Map<String, dynamic>>();
    if (lessons.isEmpty) return const [];

    final lessonIds = lessons.map((row) => row['id'] as String).toList();
    final progressCounts = await _fetchProgressCounts(lessonIds);
    final activeStudents = await _fetchActiveStudentCount();

    return lessons.map((row) {
      return _lessonFromRow(
        row,
        progressCounts: progressCounts,
        activeStudents: activeStudents,
      );
    }).toList();
  }

  static Future<TeacherLesson> insertLesson({
    required String teacherId,
    required PostLessonDraft draft,
    required int weekNumber,
  }) async {
    final now = DateTime.now();
    final status = draft.publish
        ? (draft.deadline.isAfter(now)
            ? TeacherLessonStatus.published.name
            : TeacherLessonStatus.closed.name)
        : TeacherLessonStatus.draft.name;

    final row = await SupabaseAuthService.client
        .from('teacher_lessons')
        .insert({
          'teacher_id': teacherId,
          'week_number': weekNumber,
          'title': draft.title.trim(),
          'description': draft.description.trim().isEmpty
              ? null
              : draft.description.trim(),
          'min_age': draft.minAge,
          'max_age': draft.maxAge,
          'posted_date': now.toIso8601String(),
          'deadline': draft.deadline.toIso8601String(),
          'status': status,
          'has_quiz': draft.hasQuiz,
          'has_assignment': draft.hasAssignment,
        })
        .select()
        .single();

    final activeStudents = await _fetchActiveStudentCount();
    return TeacherLesson(
      id: row['id'] as String,
      weekNumber: row['week_number'] as int,
      title: row['title'] as String,
      minAge: row['min_age'] as int? ?? 0,
      maxAge: row['max_age'] as int? ?? 99,
      postedDate: DateTime.parse(row['posted_date'] as String).toLocal(),
      deadline: DateTime.parse(row['deadline'] as String).toLocal(),
      status: _parseStatus(row['status'] as String),
      studentsTotal: activeStudents,
      studentsCompleted: 0,
      hasQuiz: row['has_quiz'] as bool? ?? false,
      hasAssignment: row['has_assignment'] as bool? ?? false,
      description: row['description'] as String?,
    );
  }

  static Future<void> updateLessonFlags({
    required String lessonId,
    bool? hasQuiz,
    bool? hasAssignment,
  }) async {
    final updates = <String, dynamic>{};
    if (hasQuiz != null) updates['has_quiz'] = hasQuiz;
    if (hasAssignment != null) updates['has_assignment'] = hasAssignment;
    if (updates.isEmpty) return;

    await SupabaseAuthService.client
        .from('teacher_lessons')
        .update(updates)
        .eq('id', lessonId);
  }

  static Future<TeacherLesson> updateLesson({
    required String lessonId,
    required EditLessonDraft draft,
  }) async {
    final row = await SupabaseAuthService.client
        .from('teacher_lessons')
        .update({
          'title': draft.title.trim(),
          'description': draft.description.trim().isEmpty
              ? null
              : draft.description.trim(),
          'min_age': draft.minAge,
          'max_age': draft.maxAge,
          'deadline': draft.deadline.toIso8601String(),
          'status': draft.status.name,
          'has_quiz': draft.hasQuiz,
          'has_assignment': draft.hasAssignment,
        })
        .eq('id', lessonId)
        .select()
        .single();

    final progressCounts = await _fetchProgressCounts([lessonId]);
    final activeStudents = await _fetchActiveStudentCount();
    return _lessonFromRow(
      Map<String, dynamic>.from(row as Map),
      progressCounts: progressCounts,
      activeStudents: activeStudents,
    );
  }

  static TeacherLesson _lessonFromRow(
    Map<String, dynamic> row, {
    required Map<String, ({int total, int completed})> progressCounts,
    required int activeStudents,
  }) {
    final id = row['id'] as String;
    final progress = progressCounts[id];
    return TeacherLesson(
      id: id,
      weekNumber: row['week_number'] as int,
      title: row['title'] as String,
      minAge: row['min_age'] as int? ?? 0,
      maxAge: row['max_age'] as int? ?? 99,
      postedDate: DateTime.parse(row['posted_date'] as String).toLocal(),
      deadline: DateTime.parse(row['deadline'] as String).toLocal(),
      status: _parseStatus(row['status'] as String),
      studentsTotal: progress?.total ?? activeStudents,
      studentsCompleted: progress?.completed ?? 0,
      hasQuiz: row['has_quiz'] as bool? ?? false,
      hasAssignment: row['has_assignment'] as bool? ?? false,
      description: row['description'] as String?,
    );
  }

  static Future<int> fetchMaxWeekNumber(String teacherId) async {
    final rows = await SupabaseAuthService.client
        .from('teacher_lessons')
        .select('week_number')
        .eq('teacher_id', teacherId)
        .order('week_number', ascending: false)
        .limit(1);
    if ((rows as List).isEmpty) return 0;
    return rows.first['week_number'] as int;
  }

  static Future<List<String>> fetchLessonIdsForTeacher(String teacherId) async {
    final rows = await SupabaseAuthService.client
        .from('teacher_lessons')
        .select('id')
        .eq('teacher_id', teacherId);
    return (rows as List).map((row) => row['id'] as String).toList();
  }

  static Future<int> _fetchActiveStudentCount() async {
    final rows = await SupabaseAuthService.client
        .from('users')
        .select('id')
        .eq('role', 'student')
        .eq('status', 'active');
    return (rows as List).length;
  }

  static Future<Map<String, ({int total, int completed})>> _fetchProgressCounts(
    List<String> lessonIds,
  ) async {
    final rows = await SupabaseAuthService.client
        .from('lesson_progress')
        .select('lesson_id, is_completed')
        .inFilter('lesson_id', lessonIds);

    final counts = <String, ({int total, int completed})>{};
    for (final row in rows as List) {
      final lessonId = row['lesson_id'] as String;
      final current = counts[lessonId] ?? (total: 0, completed: 0);
      final completed = current.completed +
          ((row['is_completed'] as bool? ?? false) ? 1 : 0);
      counts[lessonId] = (total: current.total + 1, completed: completed);
    }
    return counts;
  }

  static TeacherLessonStatus _parseStatus(String value) {
    return TeacherLessonStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => TeacherLessonStatus.draft,
    );
  }
}
