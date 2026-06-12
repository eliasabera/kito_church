import 'package:kitoapp/features/attendance/data/teacher_attendance_data.dart';
import 'package:kitoapp/features/learning/data/teacher_lessons_data.dart';
import 'package:kitoapp/features/learning/models/teacher_assessment.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';

class TeacherTeachingData {
  TeacherTeachingData._();

  static List<TeacherAssignment> get assignments {
    final items = <TeacherAssignment>[];
    for (final lesson in TeacherLessonsData.initialLessons) {
      if (!lesson.hasAssignment) continue;
      if (lesson.status == TeacherLessonStatus.draft) continue;
      items.add(
        TeacherAssignment(
          id: 'as-${lesson.id}',
          lessonId: lesson.id,
          weekNumber: lesson.weekNumber,
          title: _assignmentTitleFor(lesson.weekNumber),
          lessonTitle: lesson.title,
          deadline: lesson.deadline,
          submitted: _submittedFor(lesson),
          total: lesson.studentsTotal,
          pendingReview: _pendingReviewFor(lesson),
          graded: _gradedFor(lesson),
        ),
      );
    }
    items.sort((a, b) => b.weekNumber.compareTo(a.weekNumber));
    return items;
  }

  static List<TeacherQuiz> get quizzes {
    final items = <TeacherQuiz>[];
    for (final lesson in TeacherLessonsData.initialLessons) {
      if (!lesson.hasQuiz) continue;
      if (lesson.status == TeacherLessonStatus.draft) continue;
      items.add(
        TeacherQuiz(
          id: 'qz-${lesson.id}',
          lessonId: lesson.id,
          weekNumber: lesson.weekNumber,
          title: _quizTitleFor(lesson.weekNumber),
          lessonTitle: lesson.title,
          deadline: lesson.deadline,
          attempted: _attemptedFor(lesson),
          total: lesson.studentsTotal,
          avgScore: _avgScoreFor(lesson),
          passed: _passedFor(lesson),
        ),
      );
    }
    items.sort((a, b) => b.weekNumber.compareTo(a.weekNumber));
    return items;
  }

  static TeacherAssignmentsSummary get assignmentsSummary {
    final list = assignments;
    return TeacherAssignmentsSummary(
      total: list.length,
      pendingReview: list.fold(0, (sum, a) => sum + a.pendingReview),
      submitted: list.fold(0, (sum, a) => sum + a.submitted),
      studentsTotal: list.isEmpty ? 0 : list.first.total,
    );
  }

  static TeacherQuizzesSummary get quizzesSummary {
    final list = quizzes;
    if (list.isEmpty) {
      return const TeacherQuizzesSummary(
        total: 0,
        avgClassScore: 0,
        attempted: 0,
        studentsTotal: 0,
      );
    }
    final avg = list.map((q) => q.avgScore).reduce((a, b) => a + b) ~/ list.length;
    return TeacherQuizzesSummary(
      total: list.length,
      avgClassScore: avg,
      attempted: list.fold(0, (sum, q) => sum + q.attempted),
      studentsTotal: list.first.total,
    );
  }

  static List<StudentPerformanceEntry> get performanceEntries {
    final names = TeacherAttendanceData.studentNames;
    final scores = [88, 96, 94, 91, 87, 82, 80, 78, 76, 85, 72, 90, 68, 83];
    final attendance = [92, 98, 95, 90, 88, 86, 84, 80, 78, 91, 70, 93, 65, 87];
    final lessonsDone = [4, 4, 4, 3, 3, 3, 2, 2, 2, 3, 1, 3, 1, 2];

    final entries = List.generate(names.length, (index) {
      return StudentPerformanceEntry(
        id: 'sp${index + 1}',
        name: names[index],
        rank: 0,
        overallScore: scores[index % scores.length],
        attendancePercent: attendance[index % attendance.length],
        lessonsCompleted: lessonsDone[index % lessonsDone.length],
        lessonsTotal: 4,
        assignmentsSubmitted: (index % 3) + 1,
        assignmentsTotal: 2,
        quizAvgScore: 60 + (index * 3) % 40,
      );
    });

    entries.sort((a, b) => b.overallScore.compareTo(a.overallScore));
    return List.generate(entries.length, (index) {
      final entry = entries[index];
      return StudentPerformanceEntry(
        id: entry.id,
        name: entry.name,
        rank: index + 1,
        overallScore: entry.overallScore,
        attendancePercent: entry.attendancePercent,
        lessonsCompleted: entry.lessonsCompleted,
        lessonsTotal: entry.lessonsTotal,
        assignmentsSubmitted: entry.assignmentsSubmitted,
        assignmentsTotal: entry.assignmentsTotal,
        quizAvgScore: entry.quizAvgScore,
      );
    });
  }

  static TeacherPerformanceSummary get performanceSummary {
    final entries = performanceEntries;
    final avgScore =
        entries.map((e) => e.overallScore).reduce((a, b) => a + b) ~/
            entries.length;
    final avgAttendance = entries
            .map((e) => e.attendancePercent)
            .reduce((a, b) => a + b) ~/
        entries.length;
    return TeacherPerformanceSummary(
      classAvgScore: avgScore,
      classAttendance: avgAttendance,
      studentsTotal: entries.length,
      needsAttention: entries.where((e) => e.needsAttention).length,
    );
  }

  static List<TeacherAssignment> assignmentsFor(TeacherAssessmentFilter filter) {
    return _filterAssignments(assignments, filter);
  }

  static List<TeacherQuiz> quizzesFor(TeacherAssessmentFilter filter) {
    return _filterQuizzes(quizzes, filter);
  }

  static List<StudentPerformanceEntry> performanceFor(
    TeacherPerformanceFilter filter,
  ) {
    final entries = performanceEntries;
    return switch (filter) {
      TeacherPerformanceFilter.all => entries,
      TeacherPerformanceFilter.needsAttention =>
        entries.where((e) => e.needsAttention).toList(),
      TeacherPerformanceFilter.topPerformers =>
        entries.where((e) => e.rank <= 5).toList(),
    };
  }

  static List<StudentSubmissionRow> submissionsForAssignment(
    TeacherAssignment assignment,
  ) {
    final names = TeacherAttendanceData.studentNames.take(assignment.total);
    return names.map((name) {
      final index = names.toList().indexOf(name);
      if (index >= assignment.submitted) {
        return StudentSubmissionRow(
          studentName: name,
          status: SubmissionStatus.notSubmitted,
        );
      }
      if (index >= assignment.graded) {
        return StudentSubmissionRow(
          studentName: name,
          status: SubmissionStatus.submitted,
        );
      }
      return StudentSubmissionRow(
        studentName: name,
        status: SubmissionStatus.graded,
        score: 70 + (index * 4) % 30,
      );
    }).toList();
  }

  static List<TeacherAssignment> _filterAssignments(
    List<TeacherAssignment> list,
    TeacherAssessmentFilter filter,
  ) {
    return switch (filter) {
      TeacherAssessmentFilter.all => list,
      TeacherAssessmentFilter.pending =>
        list.where((a) => a.pendingReview > 0 || a.notSubmitted > 0).toList(),
      TeacherAssessmentFilter.completed =>
        list.where((a) => a.isComplete).toList(),
    };
  }

  static List<TeacherQuiz> _filterQuizzes(
    List<TeacherQuiz> list,
    TeacherAssessmentFilter filter,
  ) {
    return switch (filter) {
      TeacherAssessmentFilter.all => list,
      TeacherAssessmentFilter.pending =>
        list.where((q) => q.notAttempted > 0).toList(),
      TeacherAssessmentFilter.completed =>
        list.where((q) => q.isComplete).toList(),
    };
  }

  static String _assignmentTitleFor(int week) {
    return switch (week) {
      2 => 'Memory Verse Essay',
      4 => 'Reflection Assignment',
      _ => 'Week $week Assignment',
    };
  }

  static String _quizTitleFor(int week) {
    return switch (week) {
      1 => 'Bible Memory Quiz',
      3 => 'Week 3 Quiz',
      _ => 'Week $week Quiz',
    };
  }

  static int _submittedFor(TeacherLesson lesson) {
    return switch (lesson.status) {
      TeacherLessonStatus.closed => lesson.studentsTotal - 2,
      TeacherLessonStatus.active => (lesson.studentsCompleted * 0.7).round(),
      _ => 0,
    };
  }

  static int _pendingReviewFor(TeacherLesson lesson) {
    final submitted = _submittedFor(lesson);
    final graded = _gradedFor(lesson);
    return (submitted - graded).clamp(0, submitted);
  }

  static int _gradedFor(TeacherLesson lesson) {
    if (lesson.status == TeacherLessonStatus.closed) {
      return lesson.studentsTotal - 4;
    }
    if (lesson.status == TeacherLessonStatus.active) {
      return (_submittedFor(lesson) * 0.6).round();
    }
    return 0;
  }

  static int _attemptedFor(TeacherLesson lesson) {
    return switch (lesson.status) {
      TeacherLessonStatus.closed => lesson.studentsTotal - 1,
      TeacherLessonStatus.active => lesson.studentsCompleted,
      _ => 0,
    };
  }

  static int _avgScoreFor(TeacherLesson lesson) {
    return switch (lesson.status) {
      TeacherLessonStatus.closed => 84,
      TeacherLessonStatus.active => 76,
      _ => 0,
    };
  }

  static int _passedFor(TeacherLesson lesson) {
    final attempted = _attemptedFor(lesson);
    return (attempted * 0.85).round();
  }
}
