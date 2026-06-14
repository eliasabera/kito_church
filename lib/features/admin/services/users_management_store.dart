import 'package:flutter/foundation.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/admin/models/managed_user.dart';
import 'package:kitoapp/features/auth/models/login_result.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/notifications/services/notifications_store.dart';

export 'package:kitoapp/features/auth/models/login_result.dart';

class UsersManagementStore extends ChangeNotifier {
  UsersManagementStore({NotificationsStore? notificationsStore})
      : _notificationsStore = notificationsStore;

  final NotificationsStore? _notificationsStore;
  final List<ManagedUser> _users = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ManagedUser> get allUsers {
    final copy = List<ManagedUser>.from(_users);
    copy.sort((a, b) => b.joinedDate.compareTo(a.joinedDate));
    return List.unmodifiable(copy);
  }

  UserManagementSummary get summary {
    var active = 0;
    var pending = 0;
    var suspended = 0;
    var students = 0;
    var teachers = 0;

    for (final user in _users) {
      switch (user.status) {
        case ManagedUserStatus.active:
          active++;
        case ManagedUserStatus.pending:
          pending++;
        case ManagedUserStatus.suspended:
          suspended++;
        case ManagedUserStatus.rejected:
          break;
      }
      if (user.role == UserRole.student) students++;
      if (user.role == UserRole.teacher) teachers++;
    }

    return UserManagementSummary(
      total: _users.length,
      active: active,
      pending: pending,
      suspended: suspended,
      students: students,
      teachers: teachers,
    );
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remoteUsers = await SupabaseAuthService.fetchAllUsers();
      _users
        ..clear()
        ..addAll(remoteUsers);
    } catch (error, stackTrace) {
      debugPrint('UsersManagementStore.load failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ManagedUser> filteredUsers({
    UserManagementFilter filter = UserManagementFilter.all,
    String query = '',
  }) {
    final normalized = query.trim().toLowerCase();
    return allUsers.where((user) {
      if (!_matchesFilter(user, filter)) return false;
      if (normalized.isEmpty) return true;
      return user.fullName.toLowerCase().contains(normalized) ||
          user.email.toLowerCase().contains(normalized) ||
          (user.compassionId?.toLowerCase().contains(normalized) ?? false);
    }).toList();
  }

  bool _matchesFilter(ManagedUser user, UserManagementFilter filter) {
    return switch (filter) {
      UserManagementFilter.all => true,
      UserManagementFilter.students => user.role == UserRole.student,
      UserManagementFilter.teachers => user.role == UserRole.teacher,
      UserManagementFilter.pending => user.status == ManagedUserStatus.pending,
      UserManagementFilter.suspended =>
        user.status == ManagedUserStatus.suspended,
    };
  }

  ManagedUser? userById(String id) {
    for (final user in _users) {
      if (user.id == id) return user;
    }
    return null;
  }

  ManagedUser? userByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final user in _users) {
      if (user.email.toLowerCase() == normalized) return user;
    }
    return null;
  }

  List<String> activeStudentIds() {
    return _users
        .where(
          (user) =>
              user.role == UserRole.student &&
              user.status == ManagedUserStatus.active,
        )
        .map((user) => user.id)
        .toList();
  }

  Future<({LoginResult result, ManagedUser? user})> login(
    String email,
    String password,
  ) async {
    final response = await SupabaseAuthService.login(
      email: email,
      password: password,
    );

    if (response.result == LoginResult.success && response.user != null) {
      final index = _users.indexWhere((u) => u.id == response.user!.id);
      if (index >= 0) {
        _users[index] = response.user!;
      } else {
        _users.insert(0, response.user!);
      }
      notifyListeners();
      await load();
      final synced = userById(response.user!.id) ?? response.user;
      return (result: LoginResult.success, user: synced);
    }

    return (result: response.result, user: null);
  }

  Future<LoginResult> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String compassionId,
    String? university,
    String? phone,
  }) async {
    final response = await SupabaseAuthService.registerStudent(
      fullName: fullName,
      email: email,
      password: password,
      compassionId: compassionId,
      university: university,
      phone: phone,
    );

    if (response.result != LoginResult.success) {
      return response.result;
    }

    await load();

    final user = response.userId != null
        ? userById(response.userId!)
        : userByEmail(email);

    _notificationsStore?.notifyAdminRegistration(
      userId: user?.id ?? response.userId ?? '',
      studentName: fullName.trim(),
      email: email.trim(),
    );

    notifyListeners();
    return LoginResult.success;
  }

  Future<LoginResult> addUser({
    required String fullName,
    required String email,
    required UserRole role,
    required String password,
    ManagedUserStatus status = ManagedUserStatus.pending,
    String? phone,
    String? compassionId,
    String? university,
    String? department,
  }) async {
    final response = await SupabaseAuthService.adminCreateUser(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
      status: status,
      phone: phone,
      compassionId: compassionId,
      university: university,
      department: department,
    );

    if (response.result != LoginResult.success || response.user == null) {
      return response.result;
    }

    _users.insert(0, response.user!);
    notifyListeners();
    return LoginResult.success;
  }

  Future<LoginResult> updateUser(ManagedUser updated) async {
    try {
      final saved = await SupabaseAuthService.updateManagedUser(updated);
      final index = _users.indexWhere((user) => user.id == saved.id);
      if (index == -1) {
        _users.insert(0, saved);
      } else {
        _users[index] = saved;
      }
      notifyListeners();
      return LoginResult.success;
    } catch (error, stackTrace) {
      debugPrint('UsersManagementStore.updateUser failed: $error\n$stackTrace');
      return LoginResult.registrationFailed;
    }
  }

  Future<void> approveUser(String id) async {
    final user = userById(id);
    if (user == null) return;

    _setStatus(id, ManagedUserStatus.active);
    try {
      await SupabaseAuthService.updateUserStatus(id, ManagedUserStatus.active);
      if (user.role == UserRole.student) {
        _notificationsStore?.notifyAccountApproved(
          studentId: id,
          studentName: user.fullName,
        );
      }
    } catch (error) {
      debugPrint('approveUser failed: $error');
      await load();
    }
  }

  Future<void> rejectUser(String id) async {
    _setStatus(id, ManagedUserStatus.rejected);
    try {
      await SupabaseAuthService.updateUserStatus(id, ManagedUserStatus.rejected);
    } catch (error) {
      debugPrint('rejectUser failed: $error');
      await load();
    }
  }

  Future<void> suspendUser(String id) async {
    _setStatus(id, ManagedUserStatus.suspended);
    try {
      await SupabaseAuthService.updateUserStatus(
        id,
        ManagedUserStatus.suspended,
      );
    } catch (error) {
      debugPrint('suspendUser failed: $error');
      await load();
    }
  }

  Future<void> reactivateUser(String id) async {
    _setStatus(id, ManagedUserStatus.active);
    try {
      await SupabaseAuthService.updateUserStatus(id, ManagedUserStatus.active);
    } catch (error) {
      debugPrint('reactivateUser failed: $error');
      await load();
    }
  }

  Future<void> deleteUser(String id) async {
    _users.removeWhere((user) => user.id == id);
    notifyListeners();

    try {
      await SupabaseAuthService.deleteUser(id);
    } catch (error) {
      debugPrint('deleteUser failed: $error');
      await load();
    }
  }

  void _setStatus(String id, ManagedUserStatus status) {
    final index = _users.indexWhere((user) => user.id == id);
    if (index == -1) return;
    _users[index] = _users[index].copyWith(status: status);
    notifyListeners();
  }
}
