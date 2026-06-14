import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/attendance/models/attendance_record.dart';
import 'package:kitoapp/features/attendance/models/attendance_session.dart';
import 'package:kitoapp/features/attendance/services/student_attendance_supabase_service.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';

class AttendanceStore extends ChangeNotifier {
  AttendanceStore();

  final List<AttendanceSession> _sessions = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

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
    final sorted = List<AttendanceSession>.from(_sessions)
      ..sort((a, b) => a.sessionDate.compareTo(b.sessionDate));

    if (sorted.isEmpty) return const [];

    final recent = sorted.length <= 20
        ? sorted
        : sorted.sublist(sorted.length - 20);

    return recent
        .map(
          (session) => HeatmapCell(
            sessionDate: session.sessionDate,
            status: session.weekStatus,
            weekNumber: session.weekNumber,
            lessonTitle: session.lessonTitle,
            sessionId: session.id,
          ),
        )
        .toList();
  }

  List<AttendanceRecord> recordsFor(AttendanceType? filter) {
    final records = sessions.map((session) => session.toRecord()).toList();
    if (filter == null) return records;
    return records.where((record) => record.type == filter).toList();
  }

  Future<void> loadFromSupabase() async {
    final studentId = AuthSession.userId;
    if (studentId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remote =
          await StudentAttendanceSupabaseService.fetchSessionsForStudent(
        studentId,
      );
      _sessions
        ..clear()
        ..addAll(remote);
    } catch (error, stackTrace) {
      debugPrint('AttendanceStore.loadFromSupabase failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _sessions.clear();
    _error = null;
    notifyListeners();
  }

  Future<void> markLessonComplete(String sessionId) async {
    final session = sessionById(sessionId);
    if (session == null || !session.needsMakeup) return;

    session.lessonCompleted = true;
    notifyListeners();

    final studentId = AuthSession.userId;
    if (studentId == null) return;

    try {
      await StudentAttendanceSupabaseService.markLessonComplete(
        sessionId: sessionId,
        studentId: studentId,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'AttendanceStore.markLessonComplete failed: $error\n$stackTrace',
      );
    }
  }

  Future<void> markOnlineAttendance(String sessionId) async {
    final session = sessionById(sessionId);
    if (session == null || !session.canMarkOnline) return;

    session.onlineMarked = true;
    session.lessonCompleted = true;
    notifyListeners();

    final studentId = AuthSession.userId;
    if (studentId == null) return;

    try {
      await StudentAttendanceSupabaseService.markOnlineAttendance(
        sessionId: sessionId,
        studentId: studentId,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'AttendanceStore.markOnlineAttendance failed: $error\n$stackTrace',
      );
    }
  }

  Future<void> markOnlineFromLearning(int weekNumber) async {
    final session = sessionForWeek(weekNumber);
    if (session == null || session.isAttended) return;
    if (session.deadline != null && DateTime.now().isAfter(session.deadline!)) {
      return;
    }

    session.onlineMarked = true;
    session.lessonCompleted = true;
    notifyListeners();

    final studentId = AuthSession.userId;
    if (studentId == null) return;

    try {
      await StudentAttendanceSupabaseService.markOnlineForWeek(
        studentId: studentId,
        weekNumber: weekNumber,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'AttendanceStore.markOnlineFromLearning failed: $error\n$stackTrace',
      );
    }
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
}
