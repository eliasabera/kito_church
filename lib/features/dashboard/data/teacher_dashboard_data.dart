class TeacherDashboardStats {
  const TeacherDashboardStats({
    required this.totalStudents,
    required this.classesToday,
    required this.pendingReviews,
    required this.attendancePercent,
  });

  final int totalStudents;
  final int classesToday;
  final int pendingReviews;
  final int attendancePercent;
}

class TeacherClassSession {
  const TeacherClassSession({
    required this.title,
    required this.minAge,
    required this.maxAge,
    required this.time,
    required this.studentCount,
    required this.lessonTitle,
  });

  final String title;
  final int minAge;
  final int maxAge;
  final String time;
  final int studentCount;
  final String lessonTitle;
}

