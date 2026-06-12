import 'package:kitoapp/features/attendance/models/attendance_record.dart';

enum WeekAttendanceStatus {
  future,
  pending,
  online,
  present,
  late,
  missed,
  noLesson,
}

class AttendanceSession {
  AttendanceSession({
    required this.id,
    required this.sessionDate,
    required this.sessionLabel,
    this.weekNumber,
    this.postedDate,
    this.deadline,
    this.lessonId,
    this.lessonTitle,
    this.physicalStatus = AttendanceStatus.absent,
    this.lessonCompleted = false,
    this.onlineMarked = false,
  });

  final String id;
  final DateTime sessionDate;
  final String sessionLabel;
  final int? weekNumber;
  final DateTime? postedDate;
  final DateTime? deadline;
  final String? lessonId;
  final String? lessonTitle;
  AttendanceStatus physicalStatus;
  bool lessonCompleted;
  bool onlineMarked;

  bool get hasLesson => lessonId != null;

  bool get needsMakeup =>
      hasLesson &&
      physicalStatus == AttendanceStatus.absent &&
      !onlineMarked &&
      deadline != null &&
      DateTime.now().isBefore(deadline!);

  bool get needsLesson => needsMakeup && !lessonCompleted;

  bool get canMarkOnline => needsMakeup && lessonCompleted;

  bool get isAttended =>
      onlineMarked ||
      physicalStatus == AttendanceStatus.present ||
      physicalStatus == AttendanceStatus.late;

  WeekAttendanceStatus get weekStatus {
    final now = DateTime.now();
    if (sessionDate.isAfter(now)) return WeekAttendanceStatus.future;

    if (onlineMarked) return WeekAttendanceStatus.online;
    if (physicalStatus == AttendanceStatus.present) {
      return WeekAttendanceStatus.present;
    }
    if (physicalStatus == AttendanceStatus.late) {
      return WeekAttendanceStatus.late;
    }

    if (!hasLesson) return WeekAttendanceStatus.noLesson;

    if (deadline != null && now.isAfter(deadline!)) {
      return WeekAttendanceStatus.missed;
    }

    return WeekAttendanceStatus.pending;
  }

  AttendanceRecord toRecord() {
    if (onlineMarked) {
      return AttendanceRecord(
        id: id,
        date: sessionDate,
        sessionLabel: sessionLabel,
        type: AttendanceType.online,
        status: AttendanceStatus.present,
        needsMakeup: false,
        lessonCompleted: true,
        canMarkOnline: false,
      );
    }

    return AttendanceRecord(
      id: id,
      date: sessionDate,
      sessionLabel: sessionLabel,
      type: AttendanceType.physical,
      status: physicalStatus,
      needsMakeup: needsMakeup,
      lessonCompleted: lessonCompleted,
      canMarkOnline: canMarkOnline,
    );
  }
}

class HeatmapCell {
  const HeatmapCell({
    required this.sessionDate,
    required this.status,
    this.weekNumber,
    this.lessonTitle,
    this.sessionId,
  });

  final DateTime sessionDate;
  final WeekAttendanceStatus status;
  final int? weekNumber;
  final String? lessonTitle;
  final String? sessionId;
}
