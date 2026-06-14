import 'package:kitoapp/core/enums/app_enums.dart';

class ManagedUser {
  ManagedUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    required this.joinedDate,
    this.phone,
    this.compassionId,
    this.university,
    this.department,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final ManagedUserStatus status;
  final DateTime joinedDate;
  final String? phone;
  final String? compassionId;
  final String? university;
  final String? department;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  ManagedUser copyWith({
    String? id,
    String? fullName,
    String? email,
    UserRole? role,
    ManagedUserStatus? status,
    DateTime? joinedDate,
    String? phone,
    String? compassionId,
    String? university,
    String? department,
  }) {
    return ManagedUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedDate: joinedDate ?? this.joinedDate,
      phone: phone ?? this.phone,
      compassionId: compassionId ?? this.compassionId,
      university: university ?? this.university,
      department: department ?? this.department,
    );
  }
}

class UserManagementSummary {
  const UserManagementSummary({
    required this.total,
    required this.active,
    required this.pending,
    required this.suspended,
    required this.students,
    required this.teachers,
  });

  final int total;
  final int active;
  final int pending;
  final int suspended;
  final int students;
  final int teachers;
}
