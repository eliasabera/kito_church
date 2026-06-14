import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/profile/models/user_profile.dart';
import 'package:kitoapp/features/profile/utils/profile_mapper.dart';

class ProfileStore extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    final userId = AuthSession.userId;
    if (userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await SupabaseAuthService.fetchUser(userId);
      _profile = user?.toUserProfile();
    } catch (error, stackTrace) {
      debugPrint('ProfileStore.load failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _profile = null;
    _error = null;
    notifyListeners();
  }
}
