import 'package:kitoapp/features/admin/data/admin_reports_data.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/ranking/models/ranking_entry.dart';

class AdminReportsDataBundle {
  const AdminReportsDataBundle({
    required this.summary,
    required this.leaderboard,
    required this.attendanceTrend,
    required this.scoreTrend,
    required this.completionTrend,
    required this.activeStudentsTrend,
  });

  final AdminReportsSummary summary;
  final List<RankingEntry> leaderboard;
  final List<int> attendanceTrend;
  final List<int> scoreTrend;
  final List<int> completionTrend;
  final List<int> activeStudentsTrend;
}

class AdminReportsSupabaseService {
  AdminReportsSupabaseService._();

  static const _et221Prefix = 'ET-221';

  static Future<AdminReportsDataBundle> fetchReports() async {
    final client = SupabaseAuthService.client;

    final rankings = await client
        .from('v_student_rankings')
        .select()
        .order('overall_score', ascending: false);

    final allStudents = await client
        .from('users')
        .select('id, status')
        .eq('role', 'student');

    final pending = await client
        .from('users')
        .select('id')
        .eq('status', 'pending');

    final publishedLessons = await client
        .from('teacher_lessons')
        .select('id')
        .inFilter('status', ['published', 'active']);

    final rankingRows = (rankings as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();

    final studentRows = (allStudents as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();

    final profiles = await client
        .from('profiles')
        .select('user_id, compassion_id, university');

    final profileRows = (profiles as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();

    final et221StudentIds = profileRows
        .where((row) {
          final compassionId = row['compassion_id'] as String? ?? '';
          final university = (row['university'] as String?)?.toUpperCase() ?? '';
          return compassionId.startsWith(_et221Prefix) ||
              university.contains(_et221Prefix);
        })
        .map((row) => row['user_id'] as String)
        .toSet();

    final et221Rows = rankingRows
        .where((row) => et221StudentIds.contains(row['student_id']))
        .toList();
    final leaderboardSource = et221Rows.isNotEmpty ? et221Rows : rankingRows;

    final avgAttendance = _averageInt(
      rankingRows.map((row) => row['attendance_percent'] as int? ?? 0),
    );
    final avgScore = _averageInt(
      rankingRows.map((row) => row['overall_score'] as int? ?? 0),
    );
    final completionRate = _averageCompletionPercent(rankingRows);

    final activeStudents = studentRows
        .where((row) => row['status'] == 'active')
        .length;
    final totalStudents = studentRows.length;

    final summary = AdminReportsSummary(
      avgAttendancePercent: avgAttendance,
      avgScore: avgScore,
      completionRate: completionRate,
      activeStudents: activeStudents,
      totalStudents: totalStudents,
      lessonsPublished: (publishedLessons as List).length,
      pendingApprovals: (pending as List).length,
    );

    final leaderboard = <RankingEntry>[];
    var rank = 1;
    for (final row in leaderboardSource.take(8)) {
      leaderboard.add(
        RankingEntry(
          rank: rank++,
          name: row['full_name'] as String,
          score: (row['overall_score'] as num?)?.toDouble() ?? 0,
        ),
      );
    }

    return AdminReportsDataBundle(
      summary: summary,
      leaderboard: leaderboard,
      attendanceTrend: _sparklineTrend(avgAttendance),
      scoreTrend: _sparklineTrend(avgScore),
      completionTrend: _sparklineTrend(completionRate),
      activeStudentsTrend: _sparklineTrend(activeStudents),
    );
  }

  static int _averageInt(Iterable<int> values) {
    final list = values.toList();
    if (list.isEmpty) return 0;
    return list.reduce((a, b) => a + b) ~/ list.length;
  }

  static int _averageCompletionPercent(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return 0;

    var total = 0;
    for (final row in rows) {
      final completed = row['lessons_completed'] as int? ?? 0;
      final lessonsTotal = row['lessons_total'] as int? ?? 0;
      if (lessonsTotal <= 0) continue;
      total += ((completed / lessonsTotal) * 100).round();
    }
    return total ~/ rows.length;
  }

  static List<int> _sparklineTrend(int current, {double variance = 0.12}) {
    if (current <= 0) return List.filled(7, 0);
    final start = (current * (1 - variance)).round().clamp(0, current);
    return List.generate(
      7,
      (index) => start + ((current - start) * index / 6).round(),
    );
  }
}
