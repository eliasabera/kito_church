import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/admin/models/managed_user.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/dashboard/data/admin_dashboard_data.dart';
import 'package:kitoapp/features/dashboard/services/admin_dashboard_supabase_service.dart';

class AdminDashboardStore extends ChangeNotifier {
  ManagedUser? _admin;
  AdminDashboardStats _stats = const AdminDashboardStats(
    totalStudents: 0,
    totalTeachers: 0,
    pendingApprovals: 0,
    activePrograms: 0,
  );
  bool _isLoading = false;
  String? _error;

  ManagedUser? get admin => _admin;
  AdminDashboardStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    final adminId = AuthSession.userId;
    if (adminId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _admin = await SupabaseAuthService.fetchUser(adminId);
      _stats = await AdminDashboardSupabaseService.fetchStats();
    } catch (error, stackTrace) {
      debugPrint('AdminDashboardStore.load failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
