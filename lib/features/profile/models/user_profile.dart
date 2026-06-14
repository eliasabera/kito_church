import 'package:kitoapp/core/enums/app_enums.dart';

class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.role,
    this.compassionId,
    this.university,
    this.phone,
    this.sponsorName,
    this.sponsorCountry,
    this.department,
  });

  final String fullName;
  final String email;
  final UserRole role;
  final String? compassionId;
  final String? university;
  final String? phone;
  final String? sponsorName;
  final String? sponsorCountry;
  final String? department;
}
