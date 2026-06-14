import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/attendance/services/teacher_attendance_store.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';
import 'package:kitoapp/features/learning/services/teacher_lessons_supabase_service.dart';

class TeacherLessonsStore extends ChangeNotifier {
  TeacherLessonsStore({TeacherAttendanceStore? attendanceStore})
      : _attendanceStore = attendanceStore;

  final TeacherAttendanceStore? _attendanceStore;
  final List<TeacherLesson> _lessons = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TeacherLesson> get allLessons {
    final copy = List<TeacherLesson>.from(_lessons);
    copy.sort((a, b) => b.weekNumber.compareTo(a.weekNumber));
    return List.unmodifiable(copy);
  }

  TeacherLessonsSummary get summary {
    final total = _lessons.length;
    final drafts =
        _lessons.where((l) => l.status == TeacherLessonStatus.draft).length;
    final active =
        _lessons.where((l) => l.status == TeacherLessonStatus.active).length;

    final publishedLessons = _lessons
        .where((l) =>
            l.status != TeacherLessonStatus.draft && l.studentsTotal > 0)
        .toList();
    final avgCompletion = publishedLessons.isEmpty
        ? 0
        : (publishedLessons
                .map((l) => l.completionPercent)
                .reduce((a, b) => a + b) /
            publishedLessons.length)
            .round();

    return TeacherLessonsSummary(
      total: total,
      drafts: drafts,
      active: active,
      avgCompletion: avgCompletion,
    );
  }

  TeacherLesson? lessonById(String id) {
    for (final lesson in _lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  List<TeacherLesson> get publishedLessons {
    return _lessons
        .where((l) => l.status != TeacherLessonStatus.draft)
        .toList()
      ..sort((a, b) => b.weekNumber.compareTo(a.weekNumber));
  }

  Future<void> loadFromSupabase() async {
    final teacherId = AuthSession.userId;
    if (teacherId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remoteLessons =
          await TeacherLessonsSupabaseService.fetchLessonsForTeacher(teacherId);
      _lessons
        ..clear()
        ..addAll(remoteLessons);
    } catch (error, stackTrace) {
      debugPrint('TeacherLessonsStore.loadFromSupabase failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPublishedForStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remoteLessons =
          await TeacherLessonsSupabaseService.fetchPublishedLessons();
      _lessons
        ..clear()
        ..addAll(remoteLessons);
    } catch (error, stackTrace) {
      debugPrint(
        'TeacherLessonsStore.loadPublishedForStudents failed: $error\n$stackTrace',
      );
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLessonFlags(
    String lessonId, {
    bool? hasQuiz,
    bool? hasAssignment,
  }) async {
    final index = _lessons.indexWhere((l) => l.id == lessonId);
    if (index == -1) return;

    try {
      await TeacherLessonsSupabaseService.updateLessonFlags(
        lessonId: lessonId,
        hasQuiz: hasQuiz,
        hasAssignment: hasAssignment,
      );
      _lessons[index] = _lessons[index].copyWith(
        hasQuiz: hasQuiz,
        hasAssignment: hasAssignment,
      );
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint(
        'TeacherLessonsStore.updateLessonFlags failed: $error\n$stackTrace',
      );
    }
  }

  Future<void> updateLesson(String lessonId, EditLessonDraft draft) async {
    final previous = lessonById(lessonId);
    if (previous == null) return;

    try {
      final updated = await TeacherLessonsSupabaseService.updateLesson(
        lessonId: lessonId,
        draft: draft,
      );

      final index = _lessons.indexWhere((lesson) => lesson.id == lessonId);
      if (index != -1) {
        _lessons[index] = updated;
      }

      final wasDraft = previous.status == TeacherLessonStatus.draft;
      final isPublished = draft.status != TeacherLessonStatus.draft;
      if (wasDraft && isPublished) {
        await _attendanceStore?.createSessionFromLesson(
          lessonId: updated.id,
          weekNumber: updated.weekNumber,
          lessonTitle: updated.title,
          postedDate: updated.postedDate,
          deadline: updated.deadline,
        );
      }

      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('TeacherLessonsStore.updateLesson failed: $error\n$stackTrace');
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  List<TeacherLesson> lessonsFor(TeacherLessonFilter? filter) {
    if (filter == null || filter == TeacherLessonFilter.all) return allLessons;
    return allLessons
        .where((lesson) => _statusForFilter(filter) == lesson.status)
        .toList();
  }

  TeacherLessonStatus? _statusForFilter(TeacherLessonFilter filter) {
    return switch (filter) {
      TeacherLessonFilter.all => null,
      TeacherLessonFilter.draft => TeacherLessonStatus.draft,
      TeacherLessonFilter.published => TeacherLessonStatus.published,
      TeacherLessonFilter.active => TeacherLessonStatus.active,
      TeacherLessonFilter.closed => TeacherLessonStatus.closed,
    };
  }

  Future<TeacherLesson?> postLesson(PostLessonDraft draft) async {
    final teacherId = AuthSession.userId;
    if (teacherId == null) return null;

    try {
      final maxWeek =
          await TeacherLessonsSupabaseService.fetchMaxWeekNumber(teacherId);
      final localMax = _lessons.isEmpty
          ? 0
          : _lessons.map((l) => l.weekNumber).reduce((a, b) => a > b ? a : b);
      final nextWeek = (maxWeek > localMax ? maxWeek : localMax) + 1;

      final lesson = await TeacherLessonsSupabaseService.insertLesson(
        teacherId: teacherId,
        draft: draft,
        weekNumber: nextWeek,
      );

      _lessons.add(lesson);

      if (draft.publish) {
        await _attendanceStore?.createSessionFromLesson(
          lessonId: lesson.id,
          weekNumber: lesson.weekNumber,
          lessonTitle: lesson.title,
          postedDate: lesson.postedDate,
          deadline: lesson.deadline,
        );
      }

      notifyListeners();
      return lesson;
    } catch (error, stackTrace) {
      debugPrint('TeacherLessonsStore.postLesson failed: $error\n$stackTrace');
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }
}

enum TeacherLessonFilter { all, draft, published, active, closed }
