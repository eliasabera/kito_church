import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/attendance/services/attendance_store.dart';
import 'package:kitoapp/features/learning/data/student_learning_data.dart';
import 'package:kitoapp/features/learning/models/lesson_unit.dart';

class LessonProgress {
  LessonProgress({
    this.timeSpentSeconds = 0,
    this.scrollProgress = 0,
    this.isCompleted = false,
  });

  int timeSpentSeconds;
  double scrollProgress;
  bool isCompleted;
}

class LearningPathStats {
  const LearningPathStats({
    required this.overallPercent,
    required this.lessonsCompleted,
    required this.lessonsTotal,
    required this.quizzesCompleted,
    required this.quizzesTotal,
    required this.assignmentsCompleted,
    required this.assignmentsTotal,
    required this.totalTimeMinutes,
  });

  final int overallPercent;
  final int lessonsCompleted;
  final int lessonsTotal;
  final int quizzesCompleted;
  final int quizzesTotal;
  final int assignmentsCompleted;
  final int assignmentsTotal;
  final int totalTimeMinutes;
}

class LearningProgressStore extends ChangeNotifier {
  LearningProgressStore({AttendanceStore? attendanceStore})
      : _attendanceStore = attendanceStore {
    _lessons['1'] = LessonProgress(
      timeSpentSeconds: 120,
      scrollProgress: 1,
      isCompleted: true,
    );
    _completedQuizzes.add('8');
  }

  static const minLessonSeconds = 45;
  static const minScrollProgress = 0.75;

  final AttendanceStore? _attendanceStore;
  final Map<String, LessonProgress> _lessons = {};
  final Set<String> _completedQuizzes = {};
  final Set<String> _completedAssignments = {};
  String? _activeLessonId;

  LessonProgress lessonProgress(String lessonId) {
    return _lessons.putIfAbsent(lessonId, LessonProgress.new);
  }

  bool isLessonCompleted(String lessonId) =>
      _lessons[lessonId]?.isCompleted ?? false;

  bool isQuizCompleted(String quizId) => _completedQuizzes.contains(quizId);

  bool isAssignmentCompleted(String assignmentId) =>
      _completedAssignments.contains(assignmentId);

  bool isWeekLocked(int weekNumber) {
    if (weekNumber <= 1) return false;
    final previous =
        StudentLearningData.weeks.firstWhere((w) => w.weekNumber == weekNumber - 1);
    return !isWeekFullyComplete(previous);
  }

  bool isAssessmentCompleteForWeek(LessonWeek week) {
    if (week.quiz != null && !isQuizCompleted(week.quiz!.id)) return false;
    if (week.assignment != null && !isAssignmentCompleted(week.assignment!.id)) {
      return false;
    }
    return true;
  }

  bool isWeekFullyComplete(LessonWeek week) {
    return isLessonCompleted(week.lesson.id) &&
        isAssessmentCompleteForWeek(week);
  }

  bool canCompleteLesson(String lessonId) {
    final progress = lessonProgress(lessonId);
    if (progress.isCompleted) return false;
    return progress.timeSpentSeconds >= minLessonSeconds &&
        progress.scrollProgress >= minScrollProgress;
  }

  void beginLesson(String lessonId) {
    _activeLessonId = lessonId;
    lessonProgress(lessonId);
    notifyListeners();
  }

  void endLesson(String lessonId) {
    if (_activeLessonId == lessonId) _activeLessonId = null;
    notifyListeners();
  }

  void addLessonTime(String lessonId, {int seconds = 1}) {
    if (_activeLessonId != lessonId) return;
    final progress = lessonProgress(lessonId);
    if (progress.isCompleted) return;
    progress.timeSpentSeconds += seconds;
    notifyListeners();
  }

  void updateLessonScroll(String lessonId, double scrollProgress) {
    if (_activeLessonId != lessonId) return;
    final progress = lessonProgress(lessonId);
    if (progress.isCompleted) return;
    if (scrollProgress > progress.scrollProgress) {
      progress.scrollProgress = scrollProgress.clamp(0.0, 1.0);
      notifyListeners();
    }
  }

  void completeLesson(String lessonId) {
    if (!canCompleteLesson(lessonId)) return;
    lessonProgress(lessonId).isCompleted = true;
    _tryMarkWeekAttendance(StudentLearningData.weekForLessonId(lessonId));
    notifyListeners();
  }

  void completeQuiz(String quizId) {
    _completedQuizzes.add(quizId);
    _tryMarkWeekAttendance(StudentLearningData.weekContainingItem(quizId));
    notifyListeners();
  }

  void completeAssignment(String assignmentId) {
    _completedAssignments.add(assignmentId);
    _tryMarkWeekAttendance(StudentLearningData.weekContainingItem(assignmentId));
    notifyListeners();
  }

  void _tryMarkWeekAttendance(LessonWeek? week) {
    if (week == null || _attendanceStore == null) return;
    if (!isWeekFullyComplete(week)) return;
    if (DateTime.now().isAfter(week.deadline)) return;
    _attendanceStore.markOnlineFromLearning(week.weekNumber);
  }

  bool isQuizUnlocked(String lessonId) => isLessonCompleted(lessonId);

  bool isAssignmentUnlocked(String lessonId) => isLessonCompleted(lessonId);

  List<PathNode> pathNodesForWeek(LessonWeek week) {
    final weekLocked = isWeekLocked(week.weekNumber);
    final lessonDone = isLessonCompleted(week.lesson.id);

    return [
      PathNode(
        type: PathNodeType.lesson,
        item: week.lesson,
        isLocked: weekLocked,
        isCompleted: lessonDone,
        timeSpentSeconds: lessonProgress(week.lesson.id).timeSpentSeconds,
      ),
      if (week.quiz != null)
        PathNode(
          type: PathNodeType.quiz,
          item: week.quiz!,
          isLocked: weekLocked || !lessonDone,
          isCompleted: isQuizCompleted(week.quiz!.id),
        ),
      if (week.assignment != null)
        PathNode(
          type: PathNodeType.assignment,
          item: week.assignment!,
          isLocked: weekLocked || !lessonDone,
          isCompleted: isAssignmentCompleted(week.assignment!.id),
        ),
    ];
  }

  String? lessonIdForQuiz(String quizId) {
    for (final week in StudentLearningData.weeks) {
      if (week.quiz?.id == quizId) return week.lesson.id;
    }
    return null;
  }

  String? lessonIdForAssignment(String assignmentId) {
    for (final week in StudentLearningData.weeks) {
      if (week.assignment?.id == assignmentId) return week.lesson.id;
    }
    return null;
  }

  bool isQuizAccessible(String quizId) {
    final lessonId = lessonIdForQuiz(quizId);
    return lessonId != null && isQuizUnlocked(lessonId);
  }

  bool isAssignmentAccessible(String assignmentId) {
    final lessonId = lessonIdForAssignment(assignmentId);
    return lessonId != null && isAssignmentUnlocked(lessonId);
  }

  LearningPathStats get stats {
    final weeks = StudentLearningData.weeks;
    var lessonsTotal = 0;
    var lessonsDone = 0;
    var quizzesTotal = 0;
    var quizzesDone = 0;
    var assignmentsTotal = 0;
    var assignmentsDone = 0;
    var totalSeconds = 0;

    for (final week in weeks) {
      lessonsTotal++;
      if (isLessonCompleted(week.lesson.id)) lessonsDone++;
      totalSeconds += lessonProgress(week.lesson.id).timeSpentSeconds;

      if (week.quiz != null) {
        quizzesTotal++;
        if (isQuizCompleted(week.quiz!.id)) quizzesDone++;
      }
      if (week.assignment != null) {
        assignmentsTotal++;
        if (isAssignmentCompleted(week.assignment!.id)) assignmentsDone++;
      }
    }

    final totalNodes = lessonsTotal + quizzesTotal + assignmentsTotal;
    final doneNodes = lessonsDone + quizzesDone + assignmentsDone;

    return LearningPathStats(
      overallPercent:
          totalNodes == 0 ? 0 : ((doneNodes / totalNodes) * 100).round(),
      lessonsCompleted: lessonsDone,
      lessonsTotal: lessonsTotal,
      quizzesCompleted: quizzesDone,
      quizzesTotal: quizzesTotal,
      assignmentsCompleted: assignmentsDone,
      assignmentsTotal: assignmentsTotal,
      totalTimeMinutes: (totalSeconds / 60).ceil(),
    );
  }
}
