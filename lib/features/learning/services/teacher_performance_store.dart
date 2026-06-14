import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment.dart';
import 'package:kitoapp/features/learning/services/teacher_performance_supabase_service.dart';

class TeacherPerformanceStore extends ChangeNotifier {
  List<StudentPerformanceEntry> _entries = const [];
  TeacherPerformanceSummary _summary = const TeacherPerformanceSummary(
    classAvgScore: 0,
    classAttendance: 0,
    studentsTotal: 0,
    needsAttention: 0,
  );
  bool _isLoading = false;
  String? _error;

  TeacherPerformanceSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<StudentPerformanceEntry> performanceFor(TeacherPerformanceFilter filter) {
    return switch (filter) {
      TeacherPerformanceFilter.all => List.unmodifiable(_entries),
      TeacherPerformanceFilter.needsAttention =>
        _entries.where((entry) => entry.needsAttention).toList(),
      TeacherPerformanceFilter.topPerformers =>
        _entries.where((entry) => entry.rank <= 5).toList(),
    };
  }

  Future<void> loadFromSupabase() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final entries =
          await TeacherPerformanceSupabaseService.fetchPerformanceEntries();
      _entries = entries;
      _summary = TeacherPerformanceSupabaseService.buildSummary(entries);
    } catch (error, stackTrace) {
      debugPrint(
        'TeacherPerformanceStore.loadFromSupabase failed: $error\n$stackTrace',
      );
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
