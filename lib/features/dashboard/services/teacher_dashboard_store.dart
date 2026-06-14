import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/features/admin/models/managed_user.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/dashboard/data/teacher_dashboard_data.dart';

class TeacherDashboardStore extends ChangeNotifier {
  ManagedUser? _teacher;
  TeacherDashboardStats _stats = const TeacherDashboardStats(
    totalStudents: 0,
    classesToday: 0,
    pendingReviews: 0,
    attendancePercent: 0,
  );
  List<TeacherClassSession> _todayClasses = const [];
  bool _isLoading = false;
  String? _error;

  ManagedUser? get teacher => _teacher;
  TeacherDashboardStats get stats => _stats;
  List<TeacherClassSession> get todayClasses =>
      List.unmodifiable(_todayClasses);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    final teacherId = AuthSession.userId;
    if (teacherId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teacher = await SupabaseAuthService.fetchUser(teacherId);

      final totalStudents = await _fetchActiveStudentCount();
      final lessonIds = await _fetchTeacherLessonIds(teacherId);
      final pendingReviews = await _fetchPendingReviews(lessonIds);
      final attendancePercent = await _fetchAttendancePercent(lessonIds);
      final todayClasses = await _fetchTodayClasses(
        teacherId: teacherId,
        lessonIds: lessonIds,
        totalStudents: totalStudents,
      );

      _stats = TeacherDashboardStats(
        totalStudents: totalStudents,
        classesToday: todayClasses.length,
        pendingReviews: pendingReviews,
        attendancePercent: attendancePercent,
      );
      _todayClasses = todayClasses;
    } catch (error, stackTrace) {
      debugPrint('TeacherDashboardStore.load failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> _fetchActiveStudentCount() async {
    final rows = await SupabaseAuthService.client
        .from('users')
        .select('id')
        .eq('role', 'student')
        .eq('status', 'active');
    return (rows as List).length;
  }

  Future<List<String>> _fetchTeacherLessonIds(String teacherId) async {
    final rows = await SupabaseAuthService.client
        .from('teacher_lessons')
        .select('id')
        .eq('teacher_id', teacherId);
    return (rows as List).map((row) => row['id'] as String).toList();
  }

  Future<int> _fetchPendingReviews(List<String> lessonIds) async {
    if (lessonIds.isEmpty) return 0;

    final assignments = await SupabaseAuthService.client
        .from('assignments')
        .select('id')
        .inFilter('lesson_id', lessonIds);
    final assignmentIds =
        (assignments as List).map((row) => row['id'] as String).toList();
    if (assignmentIds.isEmpty) return 0;

    final submissions = await SupabaseAuthService.client
        .from('assignment_submissions')
        .select('id')
        .inFilter('assignment_id', assignmentIds)
        .eq('status', 'submitted');
    return (submissions as List).length;
  }

  Future<int> _fetchAttendancePercent(List<String> lessonIds) async {
    if (lessonIds.isEmpty) return 0;

    final sessions = await SupabaseAuthService.client
        .from('attendance_sessions')
        .select('id')
        .inFilter('lesson_id', lessonIds);
    final sessionIds =
        (sessions as List).map((row) => row['id'] as String).toList();
    if (sessionIds.isEmpty) return 0;

    final records = await SupabaseAuthService.client
        .from('student_attendance_records')
        .select('physical_status, online_marked')
        .inFilter('session_id', sessionIds);
    final list = records as List;
    if (list.isEmpty) return 0;

    var attended = 0;
    for (final record in list) {
      final status = record['physical_status'] as String?;
      final onlineMarked = record['online_marked'] as bool? ?? false;
      if (status == 'present' || status == 'late' || onlineMarked) {
        attended++;
      }
    }
    return ((attended / list.length) * 100).round();
  }

  Future<List<TeacherClassSession>> _fetchTodayClasses({
    required String teacherId,
    required List<String> lessonIds,
    required int totalStudents,
  }) async {
    if (lessonIds.isEmpty) return const [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final sessions = await SupabaseAuthService.client
        .from('attendance_sessions')
        .select('session_label, posted_date, lesson_id')
        .eq('session_date', todayKey)
        .inFilter('lesson_id', lessonIds);

    final sessionList = sessions as List;
    if (sessionList.isNotEmpty) {
      final lessonsById = await _fetchLessonsById(lessonIds);
      final progressCounts = await _fetchProgressCountsByLesson(lessonIds);

      return sessionList.map((session) {
        final lessonId = session['lesson_id'] as String?;
        final lesson = lessonId == null ? null : lessonsById[lessonId];
        final postedDate = session['posted_date'] as String?;
        final timeSource = postedDate != null
            ? DateTime.parse(postedDate).toLocal()
            : now;

        return TeacherClassSession(
          title: session['session_label'] as String? ??
              _classTitleForLesson(lesson),
          minAge: lesson?['min_age'] as int? ?? 0,
          maxAge: lesson?['max_age'] as int? ?? 99,
          time: DateFormat.jm().format(timeSource),
          studentCount: lessonId == null
              ? totalStudents
              : progressCounts[lessonId] ?? totalStudents,
          lessonTitle: lesson?['title'] as String? ?? '',
        );
      }).toList();
    }

    final lessons = await SupabaseAuthService.client
        .from('teacher_lessons')
        .select(
          'id, title, min_age, max_age, posted_date, week_number, status',
        )
        .eq('teacher_id', teacherId)
        .neq('status', 'draft');

    final progressCounts = await _fetchProgressCountsByLesson(lessonIds);
    final tomorrow = today.add(const Duration(days: 1));

    return (lessons as List)
        .where((lesson) {
          final posted =
              DateTime.parse(lesson['posted_date'] as String).toLocal();
          return !posted.isBefore(today) && posted.isBefore(tomorrow);
        })
        .map((lesson) {
          final lessonId = lesson['id'] as String;
          final posted =
              DateTime.parse(lesson['posted_date'] as String).toLocal();
          return TeacherClassSession(
            title: _classTitleForLesson(lesson),
            minAge: lesson['min_age'] as int? ?? 0,
            maxAge: lesson['max_age'] as int? ?? 99,
            time: DateFormat.jm().format(posted),
            studentCount: progressCounts[lessonId] ?? totalStudents,
            lessonTitle: lesson['title'] as String? ?? '',
          );
        })
        .toList();
  }

  Future<Map<String, Map<String, dynamic>>> _fetchLessonsById(
    List<String> lessonIds,
  ) async {
    final rows = await SupabaseAuthService.client
        .from('teacher_lessons')
        .select('id, title, min_age, max_age, week_number')
        .inFilter('id', lessonIds);
    return {
      for (final row in rows as List)
        row['id'] as String: Map<String, dynamic>.from(row as Map),
    };
  }

  Future<Map<String, int>> _fetchProgressCountsByLesson(
    List<String> lessonIds,
  ) async {
    final rows = await SupabaseAuthService.client
        .from('lesson_progress')
        .select('lesson_id')
        .inFilter('lesson_id', lessonIds);

    final counts = <String, int>{};
    for (final row in rows as List) {
      final lessonId = row['lesson_id'] as String;
      counts[lessonId] = (counts[lessonId] ?? 0) + 1;
    }
    return counts;
  }

  String _classTitleForLesson(Map<String, dynamic>? lesson) {
    if (lesson == null) return 'Class Session';
    final weekNumber = lesson['week_number'] as int?;
    if (weekNumber != null) return 'Week $weekNumber Class';
    return 'Class Session';
  }
}
