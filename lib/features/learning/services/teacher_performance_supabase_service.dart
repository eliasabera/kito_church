import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment.dart';

class TeacherPerformanceSupabaseService {
  TeacherPerformanceSupabaseService._();

  static Future<List<StudentPerformanceEntry>> fetchPerformanceEntries() async {
    final rows = await SupabaseAuthService.client
        .from('v_student_rankings')
        .select()
        .order('overall_score', ascending: false);

    final entries = <StudentPerformanceEntry>[];
    var rank = 1;
    for (final row in rows as List) {
      final map = Map<String, dynamic>.from(row as Map);
      entries.add(
        StudentPerformanceEntry(
          id: map['student_id'] as String,
          name: map['full_name'] as String,
          rank: rank++,
          overallScore: map['overall_score'] as int? ?? 0,
          attendancePercent: map['attendance_percent'] as int? ?? 0,
          lessonsCompleted: map['lessons_completed'] as int? ?? 0,
          lessonsTotal: map['lessons_total'] as int? ?? 0,
          assignmentsSubmitted: map['assignments_submitted'] as int? ?? 0,
          assignmentsTotal: map['assignments_total'] as int? ?? 0,
          quizAvgScore: map['quiz_avg_score'] as int? ?? 0,
        ),
      );
    }
    return entries;
  }

  static TeacherPerformanceSummary buildSummary(
    List<StudentPerformanceEntry> entries,
  ) {
    if (entries.isEmpty) {
      return const TeacherPerformanceSummary(
        classAvgScore: 0,
        classAttendance: 0,
        studentsTotal: 0,
        needsAttention: 0,
      );
    }

    final avgScore =
        entries.map((entry) => entry.overallScore).reduce((a, b) => a + b) ~/
            entries.length;
    final avgAttendance = entries
            .map((entry) => entry.attendancePercent)
            .reduce((a, b) => a + b) ~/
        entries.length;
    final needsAttention =
        entries.where((entry) => entry.needsAttention).length;

    return TeacherPerformanceSummary(
      classAvgScore: avgScore,
      classAttendance: avgAttendance,
      studentsTotal: entries.length,
      needsAttention: needsAttention,
    );
  }
}
