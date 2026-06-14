import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/ranking/models/ranking_entry.dart';

class StudentRankingSnapshot {
  const StudentRankingSnapshot({
    required this.summary,
    required this.leaderboard,
  });

  final StudentRankSummary? summary;
  final List<RankingEntry> leaderboard;
}

class _RankingRow {
  const _RankingRow({
    required this.studentId,
    required this.fullName,
    required this.university,
    required this.compassionId,
    required this.overallScore,
    required this.attendancePercent,
  });

  final String studentId;
  final String fullName;
  final String? university;
  final String? compassionId;
  final int overallScore;
  final int attendancePercent;
}

class StudentRankingSupabaseService {
  StudentRankingSupabaseService._();

  static const _et221Prefix = 'ET-221';

  static Future<StudentRankingSnapshot> fetchSnapshot({
    required String? studentId,
  }) async {
    final client = SupabaseAuthService.client;

    final rankings = await client
        .from('v_student_rankings')
        .select()
        .order('overall_score', ascending: false);

    final profiles = await client
        .from('profiles')
        .select('user_id, compassion_id, university');

    final profileByUser = {
      for (final row in profiles as List)
        row['user_id'] as String: Map<String, dynamic>.from(row as Map),
    };

    final rows = <_RankingRow>[];
    for (final raw in rankings as List) {
      final map = Map<String, dynamic>.from(raw as Map);
      final id = map['student_id'] as String;
      final profile = profileByUser[id];
      final compassionId = profile?['compassion_id'] as String?;
      final university = (map['university'] as String?)?.trim().isNotEmpty == true
          ? (map['university'] as String).trim()
          : (profile?['university'] as String?)?.trim();

      rows.add(
        _RankingRow(
          studentId: id,
          fullName: map['full_name'] as String,
          university: university,
          compassionId: compassionId,
          overallScore: map['overall_score'] as int? ?? 0,
          attendancePercent: map['attendance_percent'] as int? ?? 0,
        ),
      );
    }

    final et221Rows = rows
        .where((row) => _isEt221Student(row.compassionId, row.university))
        .toList();
    final pool = et221Rows.isNotEmpty ? et221Rows : rows;

    _RankingRow? current;
    for (final row in pool) {
      if (row.studentId == studentId) {
        current = row;
        break;
      }
    }

    final leaderboard = _buildLeaderboard(pool, studentId: studentId);

    final summary = current == null
        ? null
        : StudentRankSummary(
            studentName: current.fullName,
            finalScore: current.overallScore.toDouble(),
            attendancePercent: current.attendancePercent,
            classRank: _rankIn(pool, studentId),
          );

    return StudentRankingSnapshot(
      summary: summary,
      leaderboard: leaderboard,
    );
  }

  static List<RankingEntry> _buildLeaderboard(
    List<_RankingRow> rows, {
    required String? studentId,
  }) {
    final sorted = List<_RankingRow>.from(rows)
      ..sort((a, b) {
        final scoreCompare = b.overallScore.compareTo(a.overallScore);
        if (scoreCompare != 0) return scoreCompare;
        return a.fullName.compareTo(b.fullName);
      });

    return [
      for (var i = 0; i < sorted.length; i++)
        RankingEntry(
          rank: i + 1,
          name: sorted[i].fullName,
          score: sorted[i].overallScore.toDouble(),
          isCurrentStudent: sorted[i].studentId == studentId,
        ),
    ];
  }

  static int _rankIn(List<_RankingRow> rows, String? studentId) {
    if (studentId == null) return 0;
    final sorted = List<_RankingRow>.from(rows)
      ..sort((a, b) {
        final scoreCompare = b.overallScore.compareTo(a.overallScore);
        if (scoreCompare != 0) return scoreCompare;
        return a.fullName.compareTo(b.fullName);
      });
    for (var i = 0; i < sorted.length; i++) {
      if (sorted[i].studentId == studentId) return i + 1;
    }
    return 0;
  }

  static bool _isEt221Student(String? compassionId, String? university) {
    final cid = compassionId ?? '';
    final uni = university?.toUpperCase() ?? '';
    return cid.startsWith(_et221Prefix) || uni.contains(_et221Prefix);
  }
}
