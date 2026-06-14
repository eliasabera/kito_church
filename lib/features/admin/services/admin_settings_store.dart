import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/admin/models/managed_user.dart';
import 'package:kitoapp/features/admin/services/admin_settings_supabase_service.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';

class AdminSettingsStore extends ChangeNotifier {
  ManagedUser? _admin;
  AdminUserSettings _settings = const AdminUserSettings(
    pushNotifications: true,
    emailAlerts: true,
    pendingApprovalAlerts: true,
  );
  bool _isLoading = false;
  String? _error;

  ManagedUser? get admin => _admin;
  AdminUserSettings get settings => _settings;
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
      _settings = await AdminSettingsSupabaseService.fetchSettings(adminId);
    } catch (error, stackTrace) {
      debugPrint('AdminSettingsStore.load failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setPushNotifications(bool value) async {
    await _updateSettings(_settings.copyWith(pushNotifications: value));
  }

  Future<void> setEmailAlerts(bool value) async {
    await _updateSettings(_settings.copyWith(emailAlerts: value));
  }

  Future<void> setPendingApprovalAlerts(bool value) async {
    await _updateSettings(_settings.copyWith(pendingApprovalAlerts: value));
  }

  Future<void> _updateSettings(AdminUserSettings updated) async {
    final adminId = AuthSession.userId;
    if (adminId == null) return;

    _settings = updated;
    notifyListeners();

    try {
      _settings = await AdminSettingsSupabaseService.saveSettings(
        userId: adminId,
        settings: updated,
      );
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('AdminSettingsStore.save failed: $error\n$stackTrace');
      _error = error.toString();
      notifyListeners();
      await load();
    }
  }
}
