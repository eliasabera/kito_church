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

class TeacherDashboardData {
  TeacherDashboardData._();

  static const stats = TeacherDashboardStats(
    totalStudents: 28,
    classesToday: 2,
    pendingReviews: 5,
    attendancePercent: 86,
  );

  static const todayClasses = [
    TeacherClassSession(
      title: 'Sunday Morning Class',
      minAge: 12,
      maxAge: 16,
      time: '9:00 AM',
      studentCount: 14,
      lessonTitle: 'Bible Study — Week 3',
    ),
    TeacherClassSession(
      title: 'Sunday Afternoon Class',
      minAge: 17,
      maxAge: 24,
      time: '11:00 AM',
      studentCount: 14,
      lessonTitle: 'The Life of Jesus',
    ),
  ];
}
