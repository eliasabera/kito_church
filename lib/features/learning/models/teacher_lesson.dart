enum TeacherLessonStatus { draft, published, active, closed }

class TeacherLesson {
  TeacherLesson({
    required this.id,
    required this.weekNumber,
    required this.title,
    required this.minAge,
    required this.maxAge,
    required this.postedDate,
    required this.deadline,
    required this.status,
    required this.studentsTotal,
    required this.studentsCompleted,
    this.hasQuiz = false,
    this.hasAssignment = false,
    this.description,
  });

  final String id;
  final int weekNumber;
  final String title;
  final int minAge;
  final int maxAge;
  final DateTime postedDate;
  final DateTime deadline;
  final TeacherLessonStatus status;
  final int studentsTotal;
  final int studentsCompleted;
  final bool hasQuiz;
  final bool hasAssignment;
  final String? description;

  int get completionPercent => studentsTotal == 0
      ? 0
      : ((studentsCompleted / studentsTotal) * 100).round();

  TeacherLesson copyWith({
    String? id,
    int? weekNumber,
    String? title,
    int? minAge,
    int? maxAge,
    DateTime? postedDate,
    DateTime? deadline,
    TeacherLessonStatus? status,
    int? studentsTotal,
    int? studentsCompleted,
    bool? hasQuiz,
    bool? hasAssignment,
    String? description,
  }) {
    return TeacherLesson(
      id: id ?? this.id,
      weekNumber: weekNumber ?? this.weekNumber,
      title: title ?? this.title,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      postedDate: postedDate ?? this.postedDate,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      studentsTotal: studentsTotal ?? this.studentsTotal,
      studentsCompleted: studentsCompleted ?? this.studentsCompleted,
      hasQuiz: hasQuiz ?? this.hasQuiz,
      hasAssignment: hasAssignment ?? this.hasAssignment,
      description: description ?? this.description,
    );
  }
}

class TeacherLessonsSummary {
  const TeacherLessonsSummary({
    required this.total,
    required this.drafts,
    required this.active,
    required this.avgCompletion,
  });

  final int total;
  final int drafts;
  final int active;
  final int avgCompletion;
}

class PostLessonDraft {
  const PostLessonDraft({
    required this.title,
    required this.minAge,
    required this.maxAge,
    required this.deadline,
    this.description = '',
    this.hasQuiz = false,
    this.hasAssignment = false,
    this.publish = true,
  });

  final String title;
  final int minAge;
  final int maxAge;
  final DateTime deadline;
  final String description;
  final bool hasQuiz;
  final bool hasAssignment;
  final bool publish;
}
