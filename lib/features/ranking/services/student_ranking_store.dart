import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/ranking/models/ranking_entry.dart';
import 'package:kitoapp/features/ranking/services/student_ranking_supabase_service.dart';

class StudentRankingStore extends ChangeNotifier {
  StudentRankSummary? _summary;
  List<RankingEntry> _leaderboard = const [];
  bool _isLoading = false;
  String? _error;

  StudentRankSummary? get summary => _summary;
  List<RankingEntry> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await StudentRankingSupabaseService.fetchSnapshot(
        studentId: AuthSession.userId,
      );
      _summary = snapshot.summary;
      _leaderboard = snapshot.leaderboard;
    } catch (error, stackTrace) {
      debugPrint('StudentRankingStore.load failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _summary = null;
    _leaderboard = const [];
    _error = null;
    notifyListeners();
  }
}
