import 'package:kitoapp/core/enums/app_enums.dart';

class User {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.registrationStatus,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final RegistrationStatus? registrationStatus;
}
