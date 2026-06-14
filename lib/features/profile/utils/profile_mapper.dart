import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/admin/models/managed_user.dart';
import 'package:kitoapp/features/profile/models/user_profile.dart';

extension ManagedUserProfileX on ManagedUser {
  UserProfile toUserProfile() {
    return UserProfile(
      fullName: fullName,
      email: email,
      role: role,
      compassionId: compassionId,
      university: university,
      phone: phone,
      department: department,
    );
  }
}

UserProfile userProfileFromRole(UserRole role) {
  return UserProfile(
    fullName: role.name,
    email: '',
    role: role,
  );
}
