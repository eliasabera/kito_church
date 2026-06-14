import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/attendance/models/attendance_record.dart';
import 'package:kitoapp/features/attendance/models/student_attendance_entry.dart';
import 'package:kitoapp/features/attendance/services/teacher_attendance_supabase_service.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';

class TeacherAttendanceStore extends ChangeNotifier {
  final List<TeacherAttendanceSession> _sessions = [];
  String? _selectedSessionId;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TeacherAttendanceSession> get sessions {
    final copy = List<TeacherAttendanceSession>.from(_sessions);
    copy.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
    return List.unmodifiable(copy);
  }

  TeacherAttendanceSession? get selectedSession {
    if (_selectedSessionId == null) {
      return _sessions.isEmpty ? null : sessions.first;
    }
    for (final session in _sessions) {
      if (session.id == _selectedSessionId) return session;
    }
    return _sessions.isEmpty ? null : sessions.first;
  }

  bool get canEditSelectedSession => selectedSession?.isEditable ?? false;

  Future<void> loadFromSupabase() async {
    final teacherId = AuthSession.userId;
    if (teacherId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remoteSessions =
          await TeacherAttendanceSupabaseService.fetchSessionsForTeacher(
        teacherId,
      );
      _sessions
        ..clear()
        ..addAll(remoteSessions);

      if (_selectedSessionId != null &&
          !_sessions.any((session) => session.id == _selectedSessionId)) {
        _selectedSessionId = null;
      }
      _selectedSessionId ??= _sessions.isEmpty ? null : sessions.first.id;
    } catch (error, stackTrace) {
      debugPrint(
        'TeacherAttendanceStore.loadFromSupabase failed: $error\n$stackTrace',
      );
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectSession(String sessionId) {
    if (_selectedSessionId == sessionId) return;
    _selectedSessionId = sessionId;
    notifyListeners();
  }

  void selectOlderSession() {
    _selectRelativeSession(1);
  }

  void selectNewerSession() {
    _selectRelativeSession(-1);
  }

  void _selectRelativeSession(int offset) {
    final ordered = sessions;
    if (ordered.isEmpty) return;
    final currentId = _selectedSessionId ?? ordered.first.id;
    final index = ordered.indexWhere((session) => session.id == currentId);
    if (index < 0) return;
    final newIndex = index + offset;
    if (newIndex < 0 || newIndex >= ordered.length) return;
    selectSession(ordered[newIndex].id);
  }

  Future<bool> hasSessionForWeek(int weekNumber) async {
    final teacherId = AuthSession.userId;
    if (teacherId == null) {
      return _sessions.any((session) => session.weekNumber == weekNumber);
    }

    return TeacherAttendanceSupabaseService.hasSessionForWeek(
      teacherId: teacherId,
      weekNumber: weekNumber,
    );
  }

  Future<void> createSessionFromLesson({
    required String lessonId,
    required int weekNumber,
    required String lessonTitle,
    required DateTime postedDate,
    required DateTime deadline,
  }) async {
    final teacherId = AuthSession.userId;
    if (teacherId == null) return;

    try {
      final alreadyExists = await TeacherAttendanceSupabaseService
          .hasSessionForWeek(teacherId: teacherId, weekNumber: weekNumber);
      if (alreadyExists) return;

      final sessionId =
          await TeacherAttendanceSupabaseService.createSessionFromLesson(
        lessonId: lessonId,
        weekNumber: weekNumber,
        lessonTitle: lessonTitle,
        postedDate: postedDate,
        deadline: deadline,
      );

      await loadFromSupabase();
      _selectedSessionId = sessionId;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint(
        'TeacherAttendanceStore.createSessionFromLesson failed: $error\n$stackTrace',
      );
      _error = error.toString();
      notifyListeners();
    }
  }

  TeacherSessionSummary get sessionSummary {
    final session = selectedSession;
    if (session == null) {
      return const TeacherSessionSummary(
        total: 0,
        present: 0,
        late: 0,
        absent: 0,
        online: 0,
        unmarked: 0,
        attendancePercent: 0,
      );
    }

    var present = 0;
    var late = 0;
    var absent = 0;
    var online = 0;
    var unmarked = 0;
    var attended = 0;

    for (final student in session.students) {
      if (!student.isMarked) {
        unmarked++;
      } else {
        switch (student.physicalStatus) {
          case AttendanceStatus.present:
            present++;
          case AttendanceStatus.late:
            late++;
          case AttendanceStatus.absent:
            absent++;
          case null:
            break;
        }
      }
      if (student.onlineMarked) online++;
      if (student.isAttended) attended++;
    }

    final total = session.students.length;

    return TeacherSessionSummary(
      total: total,
      present: present,
      late: late,
      absent: absent,
      online: online,
      unmarked: unmarked,
      attendancePercent: total == 0 ? 0 : ((attended / total) * 100).round(),
    );
  }

  Future<void> markStudent(String studentId, AttendanceStatus status) async {
    final session = selectedSession;
    if (session == null || !session.isEditable) return;

    for (final student in session.students) {
      if (student.id == studentId) {
        student.physicalStatus = status;
        notifyListeners();

        try {
          await TeacherAttendanceSupabaseService.markStudent(
            sessionId: session.id,
            studentId: studentId,
            status: status,
          );
        } catch (error, stackTrace) {
          debugPrint(
            'TeacherAttendanceStore.markStudent failed: $error\n$stackTrace',
          );
          student.physicalStatus = null;
          _error = error.toString();
          notifyListeners();
        }
        return;
      }
    }
  }
}
