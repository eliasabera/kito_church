enum AttendanceType { physical, online }

enum AttendanceStatus { present, absent, late }

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.date,
    required this.sessionLabel,
    required this.type,
    required this.status,
    this.needsMakeup = false,
    this.lessonCompleted = false,
    this.canMarkOnline = false,
  });

  final String id;
  final DateTime date;
  final String sessionLabel;
  final AttendanceType type;
  final AttendanceStatus status;
  final bool needsMakeup;
  final bool lessonCompleted;
  final bool canMarkOnline;
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.percent,
    required this.attended,
    required this.total,
    required this.physicalPresent,
    required this.physicalTotal,
    required this.onlinePresent,
    required this.onlineTotal,
    required this.lateCount,
    required this.streakWeeks,
    required this.pendingMakeup,
  });

  final int percent;
  final int attended;
  final int total;
  final int physicalPresent;
  final int physicalTotal;
  final int onlinePresent;
  final int onlineTotal;
  final int lateCount;
  final int streakWeeks;
  final int pendingMakeup;
}
