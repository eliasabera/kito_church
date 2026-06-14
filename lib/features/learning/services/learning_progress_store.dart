import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/attendance/services/attendance_store.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/learning/models/lesson_unit.dart';
import 'package:kitoapp/features/learning/services/student_learning_catalog_store.dart';
import 'package:kitoapp/features/learning/services/student_learning_progress_supabase_service.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';

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
  LearningProgressStore({
    AttendanceStore? attendanceStore,
    StudentLearningCatalogStore? catalogStore,
  })  : _attendanceStore = attendanceStore,
        _catalogStore = catalogStore {
    _catalogStore?.addListener(notifyListeners);
  }

  static const minLessonSeconds = 45;
  static const minScrollProgress = 0.75;

  final AttendanceStore? _attendanceStore;
  final StudentLearningCatalogStore? _catalogStore;
  final Map<String, LessonProgress> _lessons = {};
  final Set<String> _completedQuizzes = {};
  final Set<String> _completedAssignments = {};
  String? _activeLessonId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<LessonWeek> get weeks => _catalogStore?.weeks ?? const [];

  @override
  void dispose() {
    _catalogStore?.removeListener(notifyListeners);
    super.dispose();
  }

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
    final previous = _weekForNumber(weekNumber - 1);
    if (previous == null) return false;
    return !isWeekFullyComplete(previous);
  }

  LessonWeek? _weekForNumber(int weekNumber) {
    return _catalogStore?.weekForNumber(weekNumber);
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
    _tryMarkWeekAttendance(_weekForLessonId(lessonId));
    notifyListeners();
    _persistLessonProgress(lessonId);
  }

  void completeQuiz(String quizId) {
    _completedQuizzes.add(quizId);
    _tryMarkWeekAttendance(_weekContainingItem(quizId));
    notifyListeners();
    _persistQuizCompletion(quizId);
  }

  void completeAssignment(String assignmentId) {
    _completedAssignments.add(assignmentId);
    _tryMarkWeekAttendance(_weekContainingItem(assignmentId));
    notifyListeners();
  }

  Future<void> completeAssignmentWithAnswer(
    String assignmentId,
    String answerText,
  ) async {
    completeAssignment(assignmentId);
    await _persistAssignmentSubmission(assignmentId, answerText);
  }

  Future<void> loadFromSupabase() async {
    final studentId = AuthSession.userId;
    if (studentId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await StudentLearningProgressSupabaseService.fetchForStudent(
        studentId,
      );

      _lessons.clear();
      for (final entry in snapshot.lessons.entries) {
        _lessons[entry.key] = LessonProgress(
          timeSpentSeconds: entry.value.timeSpentSeconds,
          scrollProgress: entry.value.scrollProgress,
          isCompleted: entry.value.isCompleted,
        );
      }

      _completedQuizzes
        ..clear()
        ..addAll(snapshot.completedQuizIds);
      _completedAssignments
        ..clear()
        ..addAll(snapshot.completedAssignmentIds);
    } catch (error, stackTrace) {
      debugPrint(
        'LearningProgressStore.loadFromSupabase failed: $error\n$stackTrace',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _persistLessonProgress(String lessonId) {
    final studentId = AuthSession.userId;
    if (studentId == null) return;

    final progress = lessonProgress(lessonId);
    unawaited(
      StudentLearningProgressSupabaseService.upsertLessonProgress(
        studentId: studentId,
        lessonId: lessonId,
        timeSpentSeconds: progress.timeSpentSeconds,
        scrollProgress: progress.scrollProgress,
        isCompleted: progress.isCompleted,
      ).catchError((Object error, StackTrace stackTrace) {
        debugPrint(
          'LearningProgressStore._persistLessonProgress failed: $error\n$stackTrace',
        );
      }),
    );
  }

  void _persistQuizCompletion(String quizId) {
    final studentId = AuthSession.userId;
    if (studentId == null) return;

    final lessonId = _lessonIdFromSyntheticQuizId(quizId);
    if (lessonId == null) return;

    unawaited(
      _resolveQuizId(lessonId).then((resolvedQuizId) async {
        if (resolvedQuizId == null) return;
        await StudentLearningProgressSupabaseService.recordQuizCompletion(
          studentId: studentId,
          quizId: resolvedQuizId,
          score: 100,
          passed: true,
        );
      }).catchError((Object error, StackTrace stackTrace) {
        debugPrint(
          'LearningProgressStore._persistQuizCompletion failed: $error\n$stackTrace',
        );
      }),
    );
  }

  Future<void> _persistAssignmentSubmission(
    String assignmentId,
    String answerText,
  ) async {
    final studentId = AuthSession.userId;
    if (studentId == null) return;

    final lessonId = _lessonIdFromSyntheticAssignmentId(assignmentId);
    if (lessonId == null) return;

    try {
      final resolvedAssignmentId = await _resolveAssignmentId(lessonId);
      if (resolvedAssignmentId == null) return;
      await StudentLearningProgressSupabaseService.recordAssignmentSubmission(
        studentId: studentId,
        assignmentId: resolvedAssignmentId,
        answerText: answerText,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'LearningProgressStore._persistAssignmentSubmission failed: $error\n$stackTrace',
      );
    }
  }

  Future<String?> _resolveQuizId(String lessonId) async {
    final rows = await SupabaseAuthService.client
        .from('quizzes')
        .select('id')
        .eq('lesson_id', lessonId)
        .limit(1);
    if ((rows as List).isEmpty) return null;
    return rows.first['id'] as String;
  }

  Future<String?> _resolveAssignmentId(String lessonId) async {
    final rows = await SupabaseAuthService.client
        .from('assignments')
        .select('id')
        .eq('lesson_id', lessonId)
        .limit(1);
    if ((rows as List).isEmpty) return null;
    return rows.first['id'] as String;
  }

  String? _lessonIdFromSyntheticQuizId(String quizId) {
    if (quizId.startsWith('qz-')) return quizId.substring(3);
    return lessonIdForQuiz(quizId);
  }

  String? _lessonIdFromSyntheticAssignmentId(String assignmentId) {
    if (assignmentId.startsWith('as-')) return assignmentId.substring(3);
    return lessonIdForAssignment(assignmentId);
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

  LessonWeek? _weekForLessonId(String lessonId) {
    return _catalogStore?.weekForLessonId(lessonId);
  }

  LessonWeek? _weekContainingItem(String itemId) {
    return _catalogStore?.weekContainingItem(itemId);
  }

  String? lessonIdForQuiz(String quizId) {
    for (final week in weeks) {
      if (week.quiz?.id == quizId) return week.lesson.id;
    }
    return null;
  }

  String? lessonIdForAssignment(String assignmentId) {
    for (final week in weeks) {
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
