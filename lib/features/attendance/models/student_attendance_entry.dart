import 'package:kitoapp/features/attendance/models/attendance_record.dart';

class StudentAttendanceEntry {
  StudentAttendanceEntry({
    required this.id,
    required this.name,
    this.physicalStatus,
    this.onlineMarked = false,
  });

  final String id;
  final String name;
  AttendanceStatus? physicalStatus;
  bool onlineMarked;

  bool get isMarked => physicalStatus != null;

  bool get isAttended =>
      onlineMarked ||
      physicalStatus == AttendanceStatus.present ||
      physicalStatus == AttendanceStatus.late;
}

class TeacherAttendanceSession {
  TeacherAttendanceSession({
    required this.id,
    required this.sessionDate,
    required this.weekNumber,
    required this.lessonTitle,
    required List<StudentAttendanceEntry> students,
  }) : students = List.of(students);

  final String id;
  final DateTime sessionDate;
  final int weekNumber;
  final String lessonTitle;
  final List<StudentAttendanceEntry> students;

  bool get isEditable {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
    );
    return !sessionDay.isBefore(today);
  }
}

class TeacherSessionSummary {
  const TeacherSessionSummary({
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
    required this.online,
    required this.unmarked,
    required this.attendancePercent,
  });

  final int total;
  final int present;
  final int late;
  final int absent;
  final int online;
  final int unmarked;
  final int attendancePercent;
}
