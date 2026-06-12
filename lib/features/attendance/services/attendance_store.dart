import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/attendance/models/attendance_record.dart';
import 'package:kitoapp/features/attendance/models/attendance_session.dart';
import 'package:kitoapp/features/learning/data/student_learning_data.dart';

class AttendanceStore extends ChangeNotifier {
  AttendanceStore() : _sessions = List.of(_initialSessions);

  final List<AttendanceSession> _sessions;

  List<AttendanceSession> get sessions {
    final copy = List<AttendanceSession>.from(_sessions);
    copy.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
    return List.unmodifiable(copy);
  }

  List<AttendanceSession> get pendingMakeupSessions {
    final copy = _sessions.where((session) => session.needsMakeup).toList();
    copy.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
    return copy;
  }

  AttendanceSession? sessionById(String id) {
    for (final session in _sessions) {
      if (session.id == id) return session;
    }
    return null;
  }

  AttendanceSession? sessionForWeek(int weekNumber) {
    for (final session in _sessions) {
      if (session.weekNumber == weekNumber) return session;
    }
    return null;
  }

  AttendanceSummary get summary {
    final pastSessions = _sessions
        .where((session) => !session.sessionDate.isAfter(DateTime.now()))
        .toList();
    final total = pastSessions.length;
    final attended =
        pastSessions.where((session) => session.isAttended).length;
    final physicalSessions =
        pastSessions.where((session) => !session.onlineMarked).toList();
    final onlineMarked =
        pastSessions.where((session) => session.onlineMarked).length;
    final physicalPresent = physicalSessions
        .where((session) => session.physicalStatus == AttendanceStatus.present)
        .length;
    final lateCount = physicalSessions
        .where((session) => session.physicalStatus == AttendanceStatus.late)
        .length;
    final pendingMakeup = pendingMakeupSessions.length;

    return AttendanceSummary(
      percent: total == 0 ? 0 : ((attended / total) * 100).round(),
      attended: attended,
      total: total,
      physicalPresent: physicalPresent,
      physicalTotal: physicalSessions.length,
      onlinePresent: onlineMarked,
      onlineTotal: onlineMarked + pendingMakeup,
      lateCount: lateCount,
      streakWeeks: _computeStreakWeeks(),
      pendingMakeup: pendingMakeup,
    );
  }

  List<HeatmapCell> get heatmapCells {
    final cells = <HeatmapCell>[];
    var sunday = _nearestPastSunday(DateTime.now());

    for (var i = 0; i < 20; i++) {
      final session = _sessionForDate(sunday);
      cells.add(
        HeatmapCell(
          sessionDate: sunday,
          status: session?.weekStatus ?? WeekAttendanceStatus.noLesson,
          weekNumber: session?.weekNumber,
          lessonTitle: session?.lessonTitle,
          sessionId: session?.id,
        ),
      );
      sunday = sunday.subtract(const Duration(days: 7));
    }

    return cells.reversed.toList();
  }

  List<AttendanceRecord> recordsFor(AttendanceType? filter) {
    final records = sessions.map((session) => session.toRecord()).toList();
    if (filter == null) return records;
    return records.where((record) => record.type == filter).toList();
  }

  void markLessonComplete(String sessionId) {
    final session = sessionById(sessionId);
    if (session == null || !session.needsMakeup) return;
    session.lessonCompleted = true;
    notifyListeners();
  }

  void markOnlineAttendance(String sessionId) {
    final session = sessionById(sessionId);
    if (session == null || !session.canMarkOnline) return;
    session.onlineMarked = true;
    notifyListeners();
  }

  void markOnlineFromLearning(int weekNumber) {
    final session = sessionForWeek(weekNumber);
    if (session == null || session.isAttended) return;
    if (session.deadline != null && DateTime.now().isAfter(session.deadline!)) {
      return;
    }
    session.onlineMarked = true;
    session.lessonCompleted = true;
    notifyListeners();
  }

  AttendanceSession? _sessionForDate(DateTime date) {
    for (final session in _sessions) {
      if (_isSameDay(session.sessionDate, date)) return session;
    }
    return null;
  }

  DateTime _nearestPastSunday(DateTime from) {
    final weekday = from.weekday;
    final daysSinceSunday = weekday % 7;
    return DateTime(from.year, from.month, from.day - daysSinceSunday);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _computeStreakWeeks() {
    var streak = 0;
    for (final session in sessions) {
      if (session.sessionDate.isAfter(DateTime.now())) continue;
      if (session.isAttended) {
        streak++;
      } else if (session.hasLesson) {
        break;
      }
    }
    return streak.clamp(0, 99);
  }

  static List<AttendanceSession> get _initialSessions {
    final learningWeeks = StudentLearningData.weeks;
    final sessions = <AttendanceSession>[
      AttendanceSession(
        id: 'w1',
        weekNumber: 1,
        postedDate: learningWeeks[0].postedDate,
        sessionDate: learningWeeks[0].sessionDate,
        deadline: learningWeeks[0].deadline,
        sessionLabel: 'Week 1 — Sunday Class',
        lessonId: learningWeeks[0].lesson.id,
        lessonTitle: learningWeeks[0].title,
        physicalStatus: AttendanceStatus.present,
      ),
      AttendanceSession(
        id: 'w2',
        weekNumber: 2,
        postedDate: learningWeeks[1].postedDate,
        sessionDate: learningWeeks[1].sessionDate,
        deadline: learningWeeks[1].deadline,
        sessionLabel: 'Week 2 — Sunday Class',
        lessonId: learningWeeks[1].lesson.id,
        lessonTitle: learningWeeks[1].title,
        physicalStatus: AttendanceStatus.absent,
        onlineMarked: true,
        lessonCompleted: true,
      ),
      AttendanceSession(
        id: 'w3',
        weekNumber: 3,
        postedDate: learningWeeks[2].postedDate,
        sessionDate: learningWeeks[2].sessionDate,
        deadline: learningWeeks[2].deadline,
        sessionLabel: 'Week 3 — Sunday Class',
        lessonId: learningWeeks[2].lesson.id,
        lessonTitle: learningWeeks[2].title,
        physicalStatus: AttendanceStatus.absent,
      ),
      AttendanceSession(
        id: 'w4',
        weekNumber: 4,
        postedDate: learningWeeks[3].postedDate,
        sessionDate: learningWeeks[3].sessionDate,
        deadline: learningWeeks[3].deadline,
        sessionLabel: 'Week 4 — Sunday Class',
        lessonId: learningWeeks[3].lesson.id,
        lessonTitle: learningWeeks[3].title,
        physicalStatus: AttendanceStatus.absent,
      ),
      AttendanceSession(
        id: 'h1',
        sessionDate: DateTime(2026, 5, 25),
        sessionLabel: 'Sunday Class',
        physicalStatus: AttendanceStatus.present,
      ),
      AttendanceSession(
        id: 'h2',
        sessionDate: DateTime(2026, 5, 18),
        sessionLabel: 'Sunday Class',
        physicalStatus: AttendanceStatus.present,
      ),
      AttendanceSession(
        id: 'h3',
        sessionDate: DateTime(2026, 5, 11),
        sessionLabel: 'Sunday Class',
        physicalStatus: AttendanceStatus.late,
      ),
      AttendanceSession(
        id: 'h4',
        sessionDate: DateTime(2026, 5, 4),
        sessionLabel: 'Sunday Class',
        physicalStatus: AttendanceStatus.present,
      ),
      AttendanceSession(
        id: 'h5',
        sessionDate: DateTime(2026, 4, 27),
        sessionLabel: 'Sunday Class',
        physicalStatus: AttendanceStatus.absent,
        onlineMarked: true,
        lessonCompleted: true,
      ),
      AttendanceSession(
        id: 'h6',
        sessionDate: DateTime(2026, 4, 20),
        sessionLabel: 'Sunday Class',
        physicalStatus: AttendanceStatus.present,
      ),
      AttendanceSession(
        id: 'h7',
        sessionDate: DateTime(2026, 4, 13),
        sessionLabel: 'Sunday Class',
        physicalStatus: AttendanceStatus.present,
      ),
      AttendanceSession(
        id: 'h8',
        sessionDate: DateTime(2026, 4, 6),
        sessionLabel: 'Sunday Class',
        physicalStatus: AttendanceStatus.present,
      ),
    ];

    return sessions;
  }
}
