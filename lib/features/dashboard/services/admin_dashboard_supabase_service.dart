import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/dashboard/data/admin_dashboard_data.dart';

class AdminDashboardSupabaseService {
  AdminDashboardSupabaseService._();

  static Future<AdminDashboardStats> fetchStats() async {
    final students = await SupabaseAuthService.client
        .from('users')
        .select('id')
        .eq('role', 'student')
        .eq('status', 'active');

    final teachers = await SupabaseAuthService.client
        .from('users')
        .select('id')
        .eq('role', 'teacher')
        .eq('status', 'active');

    final pending = await SupabaseAuthService.client
        .from('users')
        .select('id')
        .eq('status', 'pending');

    final activeLessons = await SupabaseAuthService.client
        .from('teacher_lessons')
        .select('id')
        .inFilter('status', ['published', 'active']);

    return AdminDashboardStats(
      totalStudents: (students as List).length,
      totalTeachers: (teachers as List).length,
      pendingApprovals: (pending as List).length,
      activePrograms: (activeLessons as List).length,
    );
  }
}
