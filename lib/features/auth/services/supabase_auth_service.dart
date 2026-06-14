import 'package:flutter/foundation.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/admin/models/managed_user.dart';
import 'package:kitoapp/features/auth/models/login_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseAuthService._();

  static const _usersTable = 'users';
  static const _profilesTable = 'profiles';
  static const _userSelect = '*, profiles(compassion_id, university)';

  static SupabaseClient get client => Supabase.instance.client;

  static ManagedUser managedUserFromRow(Map<String, dynamic> row) {
    final profile = _profileFromRow(row);

    return ManagedUser(
      id: row['id'] as String,
      fullName: row['full_name'] as String,
      email: row['email'] as String,
      role: _parseRole(row['role'] as String),
      status: _parseStatus(row['status'] as String),
      joinedDate: DateTime.parse(row['joined_date'] as String),
      phone: row['phone'] as String?,
      department: row['department'] as String?,
      compassionId: profile?['compassion_id'] as String?,
      university: profile?['university'] as String?,
    );
  }

  static Map<String, dynamic>? _profileFromRow(Map<String, dynamic> row) {
    final profile = row['profiles'];
    if (profile is List && profile.isNotEmpty) {
      return Map<String, dynamic>.from(profile.first as Map);
    }
    if (profile is Map<String, dynamic>) {
      return profile;
    }
    return null;
  }

  static UserRole _parseRole(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.student,
    );
  }

  static ManagedUserStatus _parseStatus(String value) {
    return ManagedUserStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ManagedUserStatus.pending,
    );
  }

  static String _statusName(ManagedUserStatus status) => status.name;

  static Future<List<ManagedUser>> fetchAllUsers() async {
    final rows = await client
        .from(_usersTable)
        .select(_userSelect)
        .order('joined_date');
    return rows.map(managedUserFromRow).toList();
  }

  static Future<ManagedUser?> fetchUser(String userId) async {
    try {
      final row = await client
          .from(_usersTable)
          .select(_userSelect)
          .eq('id', userId)
          .maybeSingle();
      if (row != null) return managedUserFromRow(row);
    } catch (error) {
      debugPrint('fetchUser with profiles failed: $error');
    }

    final row = await client
        .from(_usersTable)
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (row == null) return null;
    return managedUserFromRow(row);
  }

  static ManagedUser userFromAuthUser(User authUser, String email) {
    final meta = authUser.userMetadata ?? {};
    return ManagedUser(
      id: authUser.id,
      fullName: (meta['full_name'] as String?)?.trim().isNotEmpty == true
          ? meta['full_name'] as String
          : email.split('@').first,
      email: email.trim(),
      role: _parseRole(meta['role'] as String? ?? 'student'),
      status: _parseStatus(meta['status'] as String? ?? 'pending'),
      joinedDate: DateTime.now(),
      department: meta['department'] as String?,
      phone: meta['phone'] as String?,
    );
  }

  static Future<({LoginResult result, ManagedUser? user})> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    try {
      final response = await client.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      final authUser = response.user;
      if (authUser == null) {
        return (result: LoginResult.invalidCredentials, user: null);
      }

      final user =
          await fetchUser(authUser.id) ??
          userFromAuthUser(authUser, normalizedEmail);

      if (user.role == UserRole.student) {
        final result = switch (user.status) {
          ManagedUserStatus.pending => LoginResult.accountPending,
          ManagedUserStatus.rejected => LoginResult.accountRejected,
          ManagedUserStatus.suspended => LoginResult.accountSuspended,
          ManagedUserStatus.active => LoginResult.success,
        };
        if (result != LoginResult.success) {
          await client.auth.signOut();
          return (result: result, user: null);
        }
        return (result: LoginResult.success, user: user);
      }

      if (user.status != ManagedUserStatus.active) {
        await client.auth.signOut();
        return (result: LoginResult.invalidCredentials, user: null);
      }

      return (result: LoginResult.success, user: user);
    } on AuthException catch (error) {
      debugPrint('Supabase auth login failed: ${error.message}');
      final message = error.message.toLowerCase();
      if (message.contains('email not confirmed')) {
        return (result: LoginResult.accountPending, user: null);
      }
      if (message.contains('invalid login credentials') ||
          message.contains('invalid credentials')) {
        return (result: LoginResult.invalidCredentials, user: null);
      }
      return (result: LoginResult.invalidCredentials, user: null);
    } on PostgrestException catch (error) {
      debugPrint('Supabase users fetch failed: ${error.message}');
      return (result: LoginResult.invalidCredentials, user: null);
    } catch (error) {
      debugPrint('Supabase login failed: $error');
      return (result: LoginResult.invalidCredentials, user: null);
    }
  }

  static Future<void> updateUserStatus(
    String userId,
    ManagedUserStatus status,
  ) async {
    await client
        .from(_usersTable)
        .update({'status': _statusName(status)}).eq('id', userId);
  }

  static Future<ManagedUser> updateManagedUser(ManagedUser user) async {
    await client.from(_usersTable).update({
      'full_name': user.fullName.trim(),
      'email': user.email.trim(),
      'role': user.role.name,
      'status': _statusName(user.status),
      'phone': user.phone?.trim(),
      'department': user.department?.trim(),
    }).eq('id', user.id);

    if (user.role == UserRole.student) {
      await _upsertStudentProfile(
        userId: user.id,
        compassionId: user.compassionId?.trim(),
        university: user.university?.trim(),
      );
    }

    return (await fetchUser(user.id)) ?? user;
  }

  static Future<void> deleteUser(String userId) async {
    await client.from(_profilesTable).delete().eq('user_id', userId);
    await client.from(_usersTable).delete().eq('id', userId);
  }

  static Future<({LoginResult result, ManagedUser? user})> adminCreateUser({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    ManagedUserStatus status = ManagedUserStatus.pending,
    String? phone,
    String? compassionId,
    String? university,
    String? department,
  }) async {
    final response = await _registerUser(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
      status: status,
      compassionId: compassionId,
      university: university,
      department: department,
      phone: phone,
    );

    if (response.result != LoginResult.success || response.userId == null) {
      return (result: response.result, user: null);
    }

    final user = await fetchUser(response.userId!);
    return (result: LoginResult.success, user: user);
  }

  static Future<({LoginResult result, String? userId})> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String compassionId,
    String? university,
    String? phone,
  }) {
    return _registerUser(
      fullName: fullName,
      email: email,
      password: password,
      role: UserRole.student,
      compassionId: compassionId,
      university: university,
      phone: phone,
    );
  }

  static Future<({LoginResult result, String? userId})> registerTeacher({
    required String fullName,
    required String email,
    required String password,
    String? department,
    String? phone,
  }) {
    return _registerUser(
      fullName: fullName,
      email: email,
      password: password,
      role: UserRole.teacher,
      department: department,
      phone: phone,
      status: ManagedUserStatus.pending,
    );
  }

  static Future<({LoginResult result, String? userId})> _registerUser({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    ManagedUserStatus status = ManagedUserStatus.pending,
    String? compassionId,
    String? university,
    String? department,
    String? phone,
  }) async {
    try {
      if (role == UserRole.student &&
          compassionId != null &&
          compassionId.trim().isNotEmpty) {
        await _ensureCompassionIdRegistered(
          projectId: compassionId.trim(),
          studentName: fullName.trim(),
        );
      }

      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          'role': role.name,
          'status': status.name,
          if (role == UserRole.student && compassionId != null)
            'compassion_id': compassionId.trim(),
          if (role == UserRole.student &&
              university != null &&
              university.trim().isNotEmpty)
            'university': university.trim(),
          if (department != null && department.trim().isNotEmpty)
            'department': department.trim(),
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        },
      );

      final userId = response.user?.id;
      if (userId == null) {
        return (result: LoginResult.invalidCredentials, userId: null);
      }

      await client.from(_usersTable).upsert({
        'id': userId,
        'full_name': fullName.trim(),
        'email': email.trim(),
        'role': role.name,
        'status': status.name,
        'phone': phone?.trim(),
        'department': department?.trim(),
      });

      if (role == UserRole.student) {
        await _upsertStudentProfile(
          userId: userId,
          compassionId: compassionId?.trim(),
          university: university?.trim(),
        );
      }

      if (response.session != null) {
        await client.auth.signOut();
      }

      return (result: LoginResult.success, userId: userId);
    } on AuthException catch (error) {
      debugPrint('Supabase registration auth failed: ${error.message}');
      final message = error.message.toLowerCase();
      if (message.contains('already registered') ||
          message.contains('already been registered')) {
        return (result: LoginResult.emailAlreadyRegistered, userId: null);
      }
      return (result: LoginResult.registrationFailed, userId: null);
    } on PostgrestException catch (error) {
      debugPrint('Supabase registration data failed: ${error.message}');
      return (result: LoginResult.registrationFailed, userId: null);
    } catch (error) {
      debugPrint('Supabase registration failed: $error');
      return (result: LoginResult.registrationFailed, userId: null);
    }
  }

  static Future<void> _upsertStudentProfile({
    required String userId,
    String? compassionId,
    String? university,
  }) async {
    await client.from(_profilesTable).upsert({
      'user_id': userId,
      if (compassionId != null && compassionId.isNotEmpty)
        'compassion_id': compassionId,
      if (university != null && university.isNotEmpty) 'university': university,
    });
  }

  static Future<void> _ensureCompassionIdRegistered({
    required String projectId,
    required String studentName,
  }) async {
    try {
      await client.from('compassion_ids').upsert({
        'project_id': projectId,
        'student_name': studentName,
        'is_assigned': true,
      });
    } catch (error) {
      debugPrint('Failed to upsert compassion_id: $error');
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
