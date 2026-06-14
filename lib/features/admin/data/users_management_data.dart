import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/admin/models/managed_user.dart';

class UsersManagementData {
  UsersManagementData._();

  static List<ManagedUser> get initialUsers => [
        ManagedUser(
          id: 'u1',
          fullName: 'Abel Tesfaye',
          email: 'abel@student.kgc.org',
          role: UserRole.student,
          status: ManagedUserStatus.active,
          joinedDate: DateTime(2025, 9, 12),
          phone: '+251 91 234 5678',
          compassionId: 'KGC-COMP-003',
          university: 'Addis Ababa University',
        ),
        ManagedUser(
          id: 'u2',
          fullName: 'Hanna Bekele',
          email: 'hanna@student.kgc.org',
          role: UserRole.student,
          status: ManagedUserStatus.pending,
          joinedDate: DateTime(2026, 6, 10),
          phone: '+251 91 345 6789',
          compassionId: 'KGC-COMP-006',
          university: 'Hawassa University',
        ),
        ManagedUser(
          id: 'u3',
          fullName: 'Samuel Girma',
          email: 'samuel@student.kgc.org',
          role: UserRole.student,
          status: ManagedUserStatus.suspended,
          joinedDate: DateTime(2025, 3, 5),
          compassionId: 'KGC-COMP-001',
          university: 'Bahir Dar University',
        ),
        ManagedUser(
          id: 'u4',
          fullName: 'Mr. Daniel',
          email: 'daniel@teacher.kgc.org',
          role: UserRole.teacher,
          status: ManagedUserStatus.active,
          joinedDate: DateTime(2024, 1, 15),
          phone: '+251 91 876 5432',
          department: 'Bible & Life Skills',
        ),
        ManagedUser(
          id: 'u5',
          fullName: 'Ms. Sara',
          email: 'sara@teacher.kgc.org',
          role: UserRole.teacher,
          status: ManagedUserStatus.active,
          joinedDate: DateTime(2024, 8, 20),
          department: 'Youth Ministry',
        ),
        ManagedUser(
          id: 'u6',
          fullName: 'Yonas Mekonnen',
          email: 'yonas@student.kgc.org',
          role: UserRole.student,
          status: ManagedUserStatus.rejected,
          joinedDate: DateTime(2026, 5, 28),
          compassionId: 'KGC-COMP-007',
          university: 'Jimma University',
        ),
        ManagedUser(
          id: 'u7',
          fullName: 'Marta Tadesse',
          email: 'marta@student.kgc.org',
          role: UserRole.student,
          status: ManagedUserStatus.pending,
          joinedDate: DateTime(2026, 6, 13),
          compassionId: 'KGC-COMP-008',
          university: 'Mekelle University',
        ),
        ManagedUser(
          id: 'u8',
          fullName: 'Sister Ruth',
          email: 'ruth@admin.kgc.org',
          role: UserRole.admin,
          status: ManagedUserStatus.active,
          joinedDate: DateTime(2023, 6, 1),
          department: 'KGC Connect Admin',
        ),
      ];

  /// Demo passwords for seeded accounts.
  static const initialPasswords = <String, String>{
    'u1': 'student123',
    'u4': 'teacher123',
    'u5': 'teacher123',
    'u8': 'admin123',
  };
}
