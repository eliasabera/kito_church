import 'package:kitoapp/core/enums/app_enums.dart';

class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.compassionProjectId,
    required this.fullName,
    required this.dateOfBirth,
    required this.grade,
    this.phoneNumber,
    this.registrationStatus = RegistrationStatus.pending,
  });

  final String id;
  final String compassionProjectId;
  final String fullName;
  final DateTime dateOfBirth;
  final String grade;
  final String? phoneNumber;
  final RegistrationStatus registrationStatus;
}
