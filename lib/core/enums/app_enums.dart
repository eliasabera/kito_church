enum UserRole {
  student,
  teacher,
  admin,
}

enum RegistrationStatus {
  pending,
  approved,
  rejected,
}

enum AttendanceStatus {
  present,
  absent,
  late,
}

enum GiftStatus {
  pending,
  received,
  delivered,
}

enum GiftType {
  digital,
  physical,
}

enum ManagedUserStatus {
  active,
  pending,
  suspended,
  rejected,
}

enum UserManagementFilter {
  all,
  students,
  teachers,
  pending,
  suspended,
}

enum SponsorshipFilter {
  all,
  linked,
  unlinked,
}

enum AdminGiftFilter {
  all,
  awaitingAnnouncement,
  announced,
  pending,
  received,
  delivered,
}

/// Virtual university scoring categories only.
enum ScoringCategory {
  attendance,
  quiz,
  assignment,
}
