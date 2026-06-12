import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/attendance/data/teacher_attendance_data.dart';
import 'package:kitoapp/features/attendance/models/attendance_record.dart';
import 'package:kitoapp/features/attendance/models/student_attendance_entry.dart';

class TeacherAttendanceStore extends ChangeNotifier {
  TeacherAttendanceStore()
      : _sessions = TeacherAttendanceData.initialSessions(),
        _selectedSessionId = TeacherAttendanceData.initialSessions().first.id;

  final List<TeacherAttendanceSession> _sessions;
  String _selectedSessionId;
  int _sessionCounter = 10;

  List<TeacherAttendanceSession> get sessions {
    final copy = List<TeacherAttendanceSession>.from(_sessions);
    copy.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
    return List.unmodifiable(copy);
  }

  TeacherAttendanceSession? get selectedSession {
    for (final session in _sessions) {
      if (session.id == _selectedSessionId) return session;
    }
    return _sessions.isEmpty ? null : _sessions.first;
  }

  bool get canEditSelectedSession => selectedSession?.isEditable ?? false;

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
    final index = ordered.indexWhere((s) => s.id == _selectedSessionId);
    if (index < 0) return;
    final newIndex = index + offset;
    if (newIndex < 0 || newIndex >= ordered.length) return;
    selectSession(ordered[newIndex].id);
  }

  bool hasSessionForWeek(int weekNumber) {
    return _sessions.any((session) => session.weekNumber == weekNumber);
  }

  void createSessionFromLesson({
    required int weekNumber,
    required String lessonTitle,
    required DateTime postedDate,
    required int minAge,
    required int maxAge,
  }) {
    if (hasSessionForWeek(weekNumber)) return;

    final sessionDate = _sundayForPostedDate(postedDate);
    final session = TeacherAttendanceSession(
      id: 'ts-${_sessionCounter++}',
      sessionDate: sessionDate,
      weekNumber: weekNumber,
      lessonTitle: lessonTitle,
      students: TeacherAttendanceData.rosterForAgeRange(minAge, maxAge),
    );

    _sessions.add(session);
    _selectedSessionId = session.id;
    notifyListeners();
  }

  DateTime _sundayForPostedDate(DateTime postedDate) {
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
      attendancePercent:
          total == 0 ? 0 : ((attended / total) * 100).round(),
    );
  }

  void markStudent(String studentId, AttendanceStatus status) {
    final session = selectedSession;
    if (session == null || !session.isEditable) return;

    for (final student in session.students) {
      if (student.id == studentId) {
        student.physicalStatus = status;
        notifyListeners();
        return;
      }
    }
  }
}
