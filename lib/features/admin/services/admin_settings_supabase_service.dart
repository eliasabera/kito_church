import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';

class AdminUserSettings {
  const AdminUserSettings({
    required this.pushNotifications,
    required this.emailAlerts,
    required this.pendingApprovalAlerts,
  });

  final bool pushNotifications;
  final bool emailAlerts;
  final bool pendingApprovalAlerts;

  AdminUserSettings copyWith({
    bool? pushNotifications,
    bool? emailAlerts,
    bool? pendingApprovalAlerts,
  }) {
    return AdminUserSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailAlerts: emailAlerts ?? this.emailAlerts,
      pendingApprovalAlerts:
          pendingApprovalAlerts ?? this.pendingApprovalAlerts,
    );
  }
}

class AdminSettingsSupabaseService {
  AdminSettingsSupabaseService._();

  static const _table = 'user_settings';

  static AdminUserSettings settingsFromRow(Map<String, dynamic>? row) {
    if (row == null) {
      return const AdminUserSettings(
        pushNotifications: true,
        emailAlerts: true,
        pendingApprovalAlerts: true,
      );
    }

    return AdminUserSettings(
      pushNotifications: row['push_notifications'] as bool? ?? true,
      emailAlerts: row['email_alerts'] as bool? ?? true,
      pendingApprovalAlerts: row['pending_approval_alerts'] as bool? ?? true,
    );
  }

  static Future<AdminUserSettings> fetchSettings(String userId) async {
    try {
      final row = await SupabaseAuthService.client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (row == null) {
        return await _createDefaultSettings(userId);
      }

      return settingsFromRow(Map<String, dynamic>.from(row));
    } catch (error) {
      return const AdminUserSettings(
        pushNotifications: true,
        emailAlerts: true,
        pendingApprovalAlerts: true,
      );
    }
  }

  static Future<AdminUserSettings> _createDefaultSettings(String userId) async {
    const defaults = AdminUserSettings(
      pushNotifications: true,
      emailAlerts: true,
      pendingApprovalAlerts: true,
    );

    try {
      await SupabaseAuthService.client.from(_table).upsert({
        'user_id': userId,
        'push_notifications': defaults.pushNotifications,
        'email_alerts': defaults.emailAlerts,
        'pending_approval_alerts': defaults.pendingApprovalAlerts,
      });
    } catch (_) {
      // Table may not exist yet on remote — fall back to in-memory defaults.
    }

    return defaults;
  }

  static Future<AdminUserSettings> saveSettings({
    required String userId,
    required AdminUserSettings settings,
  }) async {
    await SupabaseAuthService.client.from(_table).upsert({
      'user_id': userId,
      'push_notifications': settings.pushNotifications,
      'email_alerts': settings.emailAlerts,
      'pending_approval_alerts': settings.pendingApprovalAlerts,
    });

    return settings;
  }
}
