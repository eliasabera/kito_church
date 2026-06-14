import 'package:kitoapp/features/ranking/models/ranking_entry.dart';

class AdminReportsSummary {
  const AdminReportsSummary({
    required this.avgAttendancePercent,
    required this.avgScore,
    required this.completionRate,
    required this.activeStudents,
    required this.totalStudents,
    required this.lessonsPublished,
    required this.pendingApprovals,
  });

  final int avgAttendancePercent;
  final int avgScore;
  final int completionRate;
  final int activeStudents;
  final int totalStudents;
  final int lessonsPublished;
  final int pendingApprovals;
}

class AdminReportsData {
  AdminReportsData._();

  static const summary = AdminReportsSummary(
    avgAttendancePercent: 87,
    avgScore: 79,
    completionRate: 64,
    activeStudents: 118,
    totalStudents: 128,
    lessonsPublished: 24,
    pendingApprovals: 5,
  );

  static const attendanceTrend = [72, 78, 81, 85, 84, 87, 87];
  static const scoreTrend = [68, 71, 74, 76, 77, 78, 79];

  /// ET-221 Compassion project students.
  static const et221Leaderboard = [
    RankingEntry(rank: 1, name: 'Hanna Bekele', score: 96),
    RankingEntry(rank: 2, name: 'Samuel Girma', score: 94),
    RankingEntry(rank: 3, name: 'Marta Haile', score: 91),
    RankingEntry(rank: 4, name: 'Yonas Abebe', score: 87),
    RankingEntry(rank: 5, name: 'Abel Tesfaye', score: 82, isCurrentStudent: true),
    RankingEntry(rank: 6, name: 'Lydia Mekonnen', score: 80),
    RankingEntry(rank: 7, name: 'Daniel Worku', score: 78),
    RankingEntry(rank: 8, name: 'Ruth Tadesse', score: 75),
  ];
}
