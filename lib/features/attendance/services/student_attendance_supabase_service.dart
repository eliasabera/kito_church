import 'package:kitoapp/features/attendance/models/attendance_record.dart';
import 'package:kitoapp/features/attendance/models/attendance_session.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';

class StudentAttendanceSupabaseService {
  StudentAttendanceSupabaseService._();

  static Future<List<AttendanceSession>> fetchSessionsForStudent(
    String studentId,
  ) async {
    final rows = await SupabaseAuthService.client
        .from('student_attendance_records')
        .select(
          'physical_status, online_marked, lesson_completed, '
          'attendance_sessions('
          'id, week_number, session_date, session_label, posted_date, '
          'deadline, lesson_id, teacher_lessons(title)'
          ')',
        )
        .eq('student_id', studentId);

    final sessions = <AttendanceSession>[];
    for (final raw in rows as List) {
      final record = Map<String, dynamic>.from(raw as Map);
      final sessionRaw = record['attendance_sessions'];
      if (sessionRaw is! Map) continue;

      final session = Map<String, dynamic>.from(sessionRaw);
      final lessonRaw = session['teacher_lessons'];
      String? lessonTitle;
      if (lessonRaw is Map) {
        lessonTitle = lessonRaw['title'] as String?;
      }

      sessions.add(
        _sessionFromRow(
          session: session,
          record: record,
          lessonTitle: lessonTitle,
        ),
      );
    }

    sessions.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
    return sessions;
  }

  static Future<void> markLessonComplete({
    required String sessionId,
    required String studentId,
  }) async {
    await SupabaseAuthService.client
        .from('student_attendance_records')
        .update({'lesson_completed': true})
        .eq('session_id', sessionId)
        .eq('student_id', studentId);
  }

  static Future<void> markOnlineAttendance({
    required String sessionId,
    required String studentId,
  }) async {
    await SupabaseAuthService.client
        .from('student_attendance_records')
        .update({
          'online_marked': true,
          'lesson_completed': true,
          'marked_at': DateTime.now().toIso8601String(),
        })
        .eq('session_id', sessionId)
        .eq('student_id', studentId);
  }

  static Future<void> markOnlineForWeek({
    required String studentId,
    required int weekNumber,
  }) async {
    final rows = await SupabaseAuthService.client
        .from('student_attendance_records')
        .select('session_id, attendance_sessions(week_number)')
        .eq('student_id', studentId);

    for (final raw in rows as List) {
      final row = Map<String, dynamic>.from(raw as Map);
      final sessionRaw = row['attendance_sessions'];
      if (sessionRaw is! Map) continue;
      if ((sessionRaw['week_number'] as int?) != weekNumber) continue;

      await markOnlineAttendance(
        sessionId: row['session_id'] as String,
        studentId: studentId,
      );
      return;
    }
  }

  static AttendanceSession _sessionFromRow({
    required Map<String, dynamic> session,
    required Map<String, dynamic> record,
    required String? lessonTitle,
  }) {
    final lessonId = session['lesson_id'] as String?;
    final weekNumber = session['week_number'] as int?;
    final label = session['session_label'] as String? ?? '';
    final resolvedTitle = lessonTitle?.trim().isNotEmpty == true
        ? lessonTitle!.trim()
        : _titleFromLabel(label);

    return AttendanceSession(
      id: session['id'] as String,
      sessionDate: DateTime.parse(session['session_date'] as String).toLocal(),
      sessionLabel: label,
      weekNumber: weekNumber,
      postedDate: _parseOptionalDate(session['posted_date']),
      deadline: _parseOptionalDate(session['deadline']),
      lessonId: lessonId,
      lessonTitle: resolvedTitle,
      physicalStatus: _parsePhysicalStatus(record['physical_status'] as String?),
      lessonCompleted: record['lesson_completed'] as bool? ?? false,
      onlineMarked: record['online_marked'] as bool? ?? false,
    );
  }

  static DateTime? _parseOptionalDate(Object? value) {
    if (value == null) return null;
    return DateTime.parse(value as String).toLocal();
  }

  static AttendanceStatus _parsePhysicalStatus(String? value) {
    if (value == null) return AttendanceStatus.absent;
    return AttendanceStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => AttendanceStatus.absent,
    );
  }

  static String? _titleFromLabel(String label) {
    final parts = label.split('—');
    if (parts.length < 2) return null;
    final title = parts.last.trim();
    return title.isEmpty ? null : title;
  }
}
