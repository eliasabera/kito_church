import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/attendance/services/teacher_attendance_store.dart';
import 'package:kitoapp/features/learning/data/teacher_lessons_data.dart';
import 'package:kitoapp/features/learning/models/teacher_lesson.dart';

class TeacherLessonsStore extends ChangeNotifier {
  TeacherLessonsStore({TeacherAttendanceStore? attendanceStore})
      : _attendanceStore = attendanceStore,
        _lessons = List.of(TeacherLessonsData.initialLessons);

  final TeacherAttendanceStore? _attendanceStore;
  final List<TeacherLesson> _lessons;
  int _idCounter = 6;

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

  void updateLessonFlags(
    String lessonId, {
    bool? hasQuiz,
    bool? hasAssignment,
  }) {
    final index = _lessons.indexWhere((l) => l.id == lessonId);
    if (index == -1) return;
    _lessons[index] = _lessons[index].copyWith(
      hasQuiz: hasQuiz,
      hasAssignment: hasAssignment,
    );
    notifyListeners();
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

  void postLesson(PostLessonDraft draft) {
    final nextWeek = _lessons.isEmpty
        ? 1
        : _lessons.map((l) => l.weekNumber).reduce((a, b) => a > b ? a : b) + 1;

    final now = DateTime.now();
    final status = draft.publish
        ? (draft.deadline.isAfter(now)
            ? TeacherLessonStatus.published
            : TeacherLessonStatus.closed)
        : TeacherLessonStatus.draft;

    final lesson = TeacherLesson(
      id: 'tl${_idCounter++}',
      weekNumber: nextWeek,
      title: draft.title.trim(),
      minAge: draft.minAge,
      maxAge: draft.maxAge,
      postedDate: now,
      deadline: draft.deadline,
      status: status,
      studentsTotal: _studentsForRange(draft.minAge, draft.maxAge),
      studentsCompleted: 0,
      hasQuiz: draft.hasQuiz,
      hasAssignment: draft.hasAssignment,
      description: draft.description.trim().isEmpty ? null : draft.description,
    );

    _lessons.add(lesson);

    if (draft.publish) {
      _attendanceStore?.createSessionFromLesson(
        weekNumber: lesson.weekNumber,
        lessonTitle: lesson.title,
        postedDate: lesson.postedDate,
        minAge: lesson.minAge,
        maxAge: lesson.maxAge,
      );
    }

    notifyListeners();
  }

  int _studentsForRange(int minAge, int maxAge) {
    if (minAge <= 12 && maxAge >= 24) return 28;
    if (maxAge <= 16) return 14;
    return 14;
  }
}

enum TeacherLessonFilter { all, draft, published, active, closed }
