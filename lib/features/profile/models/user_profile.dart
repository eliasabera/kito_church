import 'package:kitoapp/core/enums/app_enums.dart';

class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.role,
    this.compassionId,
    this.grade,
    this.phone,
    this.sponsorName,
    this.sponsorCountry,
    this.department,
  });

  final String fullName;
  final String email;
  final UserRole role;
  final String? compassionId;
  final String? grade;
  final String? phone;
  final String? sponsorName;
  final String? sponsorCountry;
  final String? department;
}
