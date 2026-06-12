enum TeacherAssessmentFilter { all, pending, completed }

enum TeacherPerformanceFilter { all, needsAttention, topPerformers }

enum SubmissionStatus { notSubmitted, submitted, graded }

class TeacherAssignment {
  const TeacherAssignment({
    required this.id,
    required this.lessonId,
    required this.weekNumber,
    required this.title,
    required this.lessonTitle,
    required this.deadline,
    required this.submitted,
    required this.total,
    required this.pendingReview,
    required this.graded,
    this.isConfigured = true,
  });

  final String id;
  final String lessonId;
  final int weekNumber;
  final String title;
  final String lessonTitle;
  final DateTime deadline;
  final int submitted;
  final int total;
  final int pendingReview;
  final int graded;
  final bool isConfigured;

  int get notSubmitted => total - submitted;
  bool get isComplete => pendingReview == 0 && submitted == total;
}

class TeacherQuiz {
  const TeacherQuiz({
    required this.id,
    required this.lessonId,
    required this.weekNumber,
    required this.title,
    required this.lessonTitle,
    required this.deadline,
    required this.attempted,
    required this.total,
    required this.avgScore,
    required this.passed,
    this.questionCount = 0,
    this.isConfigured = true,
  });

  final String id;
  final String lessonId;
  final int weekNumber;
  final String title;
  final String lessonTitle;
  final DateTime deadline;
  final int attempted;
  final int total;
  final int avgScore;
  final int passed;
  final int questionCount;
  final bool isConfigured;

  int get notAttempted => total - attempted;
  bool get isComplete => attempted == total;
}

class TeacherAssignmentsSummary {
  const TeacherAssignmentsSummary({
    required this.total,
    required this.pendingReview,
    required this.submitted,
    required this.studentsTotal,
  });

  final int total;
  final int pendingReview;
  final int submitted;
  final int studentsTotal;
}

class TeacherQuizzesSummary {
  const TeacherQuizzesSummary({
    required this.total,
    required this.avgClassScore,
    required this.attempted,
    required this.studentsTotal,
  });

  final int total;
  final int avgClassScore;
  final int attempted;
  final int studentsTotal;
}

class StudentPerformanceEntry {
  const StudentPerformanceEntry({
    required this.id,
    required this.name,
    required this.rank,
    required this.overallScore,
    required this.attendancePercent,
    required this.lessonsCompleted,
    required this.lessonsTotal,
    required this.assignmentsSubmitted,
    required this.assignmentsTotal,
    required this.quizAvgScore,
  });

  final String id;
  final String name;
  final int rank;
  final int overallScore;
  final int attendancePercent;
  final int lessonsCompleted;
  final int lessonsTotal;
  final int assignmentsSubmitted;
  final int assignmentsTotal;
  final int quizAvgScore;

  bool get needsAttention =>
      overallScore < 70 || attendancePercent < 75;
}

class TeacherPerformanceSummary {
  const TeacherPerformanceSummary({
    required this.classAvgScore,
    required this.classAttendance,
    required this.studentsTotal,
    required this.needsAttention,
  });

  final int classAvgScore;
  final int classAttendance;
  final int studentsTotal;
  final int needsAttention;
}

class StudentSubmissionRow {
  const StudentSubmissionRow({
    required this.studentName,
    required this.status,
    this.score,
  });

  final String studentName;
  final SubmissionStatus status;
  final int? score;
}
