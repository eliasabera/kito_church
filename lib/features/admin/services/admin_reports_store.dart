import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/admin/data/admin_reports_data.dart';
import 'package:kitoapp/features/admin/services/admin_reports_supabase_service.dart';
import 'package:kitoapp/features/ranking/models/ranking_entry.dart';

class AdminReportsStore extends ChangeNotifier {
  AdminReportsSummary _summary = const AdminReportsSummary(
    avgAttendancePercent: 0,
    avgScore: 0,
    completionRate: 0,
    activeStudents: 0,
    totalStudents: 0,
    lessonsPublished: 0,
    pendingApprovals: 0,
  );
  List<RankingEntry> _leaderboard = const [];
  List<int> _attendanceTrend = const [];
  List<int> _scoreTrend = const [];
  List<int> _completionTrend = const [];
  List<int> _activeStudentsTrend = const [];
  bool _isLoading = false;
  String? _error;

  AdminReportsSummary get summary => _summary;
  List<RankingEntry> get leaderboard => List.unmodifiable(_leaderboard);
  List<int> get attendanceTrend => _attendanceTrend;
  List<int> get scoreTrend => _scoreTrend;
  List<int> get completionTrend => _completionTrend;
  List<int> get activeStudentsTrend => _activeStudentsTrend;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final bundle = await AdminReportsSupabaseService.fetchReports();
      _summary = bundle.summary;
      _leaderboard = bundle.leaderboard;
      _attendanceTrend = bundle.attendanceTrend;
      _scoreTrend = bundle.scoreTrend;
      _completionTrend = bundle.completionTrend;
      _activeStudentsTrend = bundle.activeStudentsTrend;
    } catch (error, stackTrace) {
      debugPrint('AdminReportsStore.load failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
