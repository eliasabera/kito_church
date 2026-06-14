class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.pendingApprovals,
    required this.activePrograms,
  });

  final int totalStudents;
  final int totalTeachers;
  final int pendingApprovals;
  final int activePrograms;
}
