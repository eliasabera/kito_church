import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/profile/models/user_profile.dart';

class ProfileData {
  ProfileData._();

  static const student = UserProfile(
    fullName: 'Abel Tesfaye',
    email: 'abel@student.kgc.org',
    role: UserRole.student,
    compassionId: 'KGC-COMP-003',
    grade: 'Grade 8',
    phone: '+251 91 234 5678',
    sponsorName: 'John Miller',
    sponsorCountry: 'USA',
  );

  static const teacher = UserProfile(
    fullName: 'Mr. Daniel',
    email: 'daniel@teacher.kgc.org',
    role: UserRole.teacher,
    phone: '+251 91 876 5432',
    department: 'Bible & Life Skills',
  );

  static const admin = UserProfile(
    fullName: 'Sister Ruth',
    email: 'ruth@admin.kgc.org',
    role: UserRole.admin,
    phone: '+251 91 111 2233',
    department: 'KGC Connect Admin',
  );

  static UserProfile forRole(UserRole role) {
    return switch (role) {
      UserRole.student => student,
      UserRole.teacher => teacher,
      UserRole.admin => admin,
    };
  }
}
