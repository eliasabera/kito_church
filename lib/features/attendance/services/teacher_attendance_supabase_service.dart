import 'package:kitoapp/features/attendance/models/attendance_record.dart';
import 'package:kitoapp/features/attendance/models/student_attendance_entry.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/learning/services/teacher_lessons_supabase_service.dart';

class TeacherAttendanceSupabaseService {
  TeacherAttendanceSupabaseService._();

  static Future<List<TeacherAttendanceSession>> fetchSessionsForTeacher(
    String teacherId,
  ) async {
    final lessonIds =
        await TeacherLessonsSupabaseService.fetchLessonIdsForTeacher(teacherId);
    if (lessonIds.isEmpty) return const [];

    final sessionRows = await SupabaseAuthService.client
        .from('attendance_sessions')
        .select()
        .inFilter('lesson_id', lessonIds)
        .order('session_date', ascending: false);

    final sessions = (sessionRows as List).cast<Map<String, dynamic>>();
    if (sessions.isEmpty) return const [];

    final sessionIds = sessions.map((row) => row['id'] as String).toList();
    final lessonTitles = await _fetchLessonTitles(lessonIds);
    final recordsBySession = await _fetchRecordsBySession(sessionIds);
    final activeStudents = await _fetchActiveStudents();

    return sessions.map((row) {
      final sessionId = row['id'] as String;
      final lessonId = row['lesson_id'] as String?;
      final weekNumber = row['week_number'] as int? ??
          (lessonId != null ? _weekFromTitle(lessonTitles[lessonId]) : 0);
      final lessonTitle = lessonId != null
          ? (lessonTitles[lessonId]?['title'] as String? ?? '')
          : '';
      final records = recordsBySession[sessionId] ?? const [];

      final students = _buildStudentRoster(
        activeStudents: activeStudents,
        records: records,
      );

      return TeacherAttendanceSession(
        id: sessionId,
        sessionDate: DateTime.parse(row['session_date'] as String),
        weekNumber: weekNumber,
        lessonTitle: lessonTitle.isNotEmpty
            ? lessonTitle
            : (row['session_label'] as String? ?? ''),
        students: students,
      );
    }).toList();
  }

  static Future<String> createSessionFromLesson({
    required String lessonId,
    required int weekNumber,
    required String lessonTitle,
    required DateTime postedDate,
    required DateTime deadline,
  }) async {
    final sessionDate = _sundayForPostedDate(postedDate);
    final sessionLabel = 'Week $weekNumber — $lessonTitle';

    final row = await SupabaseAuthService.client
        .from('attendance_sessions')
        .insert({
          'week_number': weekNumber,
          'session_date':
              '${sessionDate.year}-${sessionDate.month.toString().padLeft(2, '0')}-${sessionDate.day.toString().padLeft(2, '0')}',
          'session_label': sessionLabel,
          'posted_date': postedDate.toIso8601String(),
          'deadline': deadline.toIso8601String(),
          'lesson_id': lessonId,
        })
        .select()
        .single();

    final sessionId = row['id'] as String;
    final students = await _fetchActiveStudents();
    if (students.isNotEmpty) {
      await SupabaseAuthService.client.from('student_attendance_records').insert(
        students
            .map(
              (student) => {
                'session_id': sessionId,
                'student_id': student.id,
                'online_marked': false,
              },
            )
            .toList(),
      );
    }

    return sessionId;
  }

  static Future<bool> hasSessionForWeek({
    required String teacherId,
    required int weekNumber,
  }) async {
    final lessonIds =
        await TeacherLessonsSupabaseService.fetchLessonIdsForTeacher(teacherId);
    if (lessonIds.isEmpty) return false;

    final rows = await SupabaseAuthService.client
        .from('attendance_sessions')
        .select('id')
        .eq('week_number', weekNumber)
        .inFilter('lesson_id', lessonIds)
        .limit(1);
    return (rows as List).isNotEmpty;
  }

  static Future<void> markStudent({
    required String sessionId,
    required String studentId,
    required AttendanceStatus status,
  }) async {
    await SupabaseAuthService.client.from('student_attendance_records').upsert(
      {
        'session_id': sessionId,
        'student_id': studentId,
        'physical_status': status.name,
        'marked_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'session_id,student_id',
    );
  }

  static Future<Map<String, Map<String, dynamic>>> _fetchLessonTitles(
    List<String> lessonIds,
  ) async {
    final rows = await SupabaseAuthService.client
        .from('teacher_lessons')
        .select('id, title, week_number')
        .inFilter('id', lessonIds);
    return {
      for (final row in rows as List)
        row['id'] as String: Map<String, dynamic>.from(row as Map),
    };
  }

  static Future<Map<String, List<Map<String, dynamic>>>> _fetchRecordsBySession(
    List<String> sessionIds,
  ) async {
    final rows = await SupabaseAuthService.client
        .from('student_attendance_records')
        .select('session_id, student_id, physical_status, online_marked, users(full_name)')
        .inFilter('session_id', sessionIds);

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in rows as List) {
      final map = Map<String, dynamic>.from(row as Map);
      final sessionId = map['session_id'] as String;
      grouped.putIfAbsent(sessionId, () => []).add(map);
    }
    return grouped;
  }

  static Future<List<({String id, String name})>> _fetchActiveStudents() async {
    final rows = await SupabaseAuthService.client
        .from('users')
        .select('id, full_name')
        .eq('role', 'student')
        .eq('status', 'active')
        .order('full_name');
    return (rows as List)
        .map(
          (row) => (
            id: row['id'] as String,
            name: row['full_name'] as String,
          ),
        )
        .toList();
  }

  static List<StudentAttendanceEntry> _buildStudentRoster({
    required List<({String id, String name})> activeStudents,
    required List<Map<String, dynamic>> records,
  }) {
    final recordByStudent = {
      for (final record in records)
        record['student_id'] as String: record,
    };

    if (activeStudents.isEmpty) {
      return records.map((record) {
        final users = record['users'];
        String name = record['student_id'] as String;
        if (users is Map) {
          name = users['full_name'] as String? ?? name;
        } else if (users is List && users.isNotEmpty) {
          name = (users.first as Map)['full_name'] as String? ?? name;
        }
        return StudentAttendanceEntry(
          id: record['student_id'] as String,
          name: name,
          physicalStatus: _parsePhysicalStatus(
            record['physical_status'] as String?,
          ),
          onlineMarked: record['online_marked'] as bool? ?? false,
        );
      }).toList();
    }

    return activeStudents.map((student) {
      final record = recordByStudent[student.id];
      return StudentAttendanceEntry(
        id: student.id,
        name: student.name,
        physicalStatus: _parsePhysicalStatus(
          record?['physical_status'] as String?,
        ),
        onlineMarked: record?['online_marked'] as bool? ?? false,
      );
    }).toList();
  }

  static AttendanceStatus? _parsePhysicalStatus(String? value) {
    if (value == null) return null;
    return AttendanceStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => AttendanceStatus.absent,
    );
  }

  static int _weekFromTitle(Map<String, dynamic>? lesson) {
    return lesson?['week_number'] as int? ?? 0;
  }

  static DateTime _sundayForPostedDate(DateTime postedDate) {
    final date = DateTime(postedDate.year, postedDate.month, postedDate.day);
    if (date.weekday == DateTime.saturday) {
      return date.add(const Duration(days: 1));
    }
    if (date.weekday == DateTime.sunday) {
      return date;
    }
    final daysUntilSunday = (DateTime.sunday - date.weekday) % 7;
    return date.add(Duration(days: daysUntilSunday));
  }
}
