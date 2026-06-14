import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';

/// Session state for the signed-in user.
class AuthSession {
  AuthSession._();

  static String? userId;
  static UserRole? role;

  static void setSession({required String id, required UserRole userRole}) {
    userId = id;
    role = userRole;
  }

  static Future<void> signOut() async {
    await SupabaseAuthService.signOut();
    clear();
  }

  static void clear() {
    userId = null;
    role = null;
  }

  static String get studentId => userId ?? 'u1';
}
