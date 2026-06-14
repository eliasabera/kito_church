import 'package:kitoapp/features/announcements/services/announcements_store.dart';
import 'package:kitoapp/features/attendance/services/attendance_store.dart';
import 'package:kitoapp/features/bible_stories/services/bible_stories_store.dart';
import 'package:kitoapp/features/bible_verse/services/daily_verse_store.dart';
import 'package:kitoapp/features/learning/services/learning_progress_store.dart';
import 'package:kitoapp/features/learning/services/teacher_assessments_store.dart';
import 'package:kitoapp/features/learning/services/teacher_lessons_store.dart';
import 'package:kitoapp/features/profile/services/profile_store.dart';

/// Loads Supabase-backed data shown on the student home tab.
Future<void> loadStudentHomeData({
  required ProfileStore profileStore,
  required DailyVerseStore dailyVerseStore,
  required BibleStoriesStore bibleStoriesStore,
  required AnnouncementsStore announcementsStore,
  required TeacherLessonsStore lessonsStore,
  required TeacherAssessmentsStore assessmentsStore,
  AttendanceStore? attendanceStore,
}) async {
  await Future.wait([
    profileStore.load(),
    dailyVerseStore.load(),
    bibleStoriesStore.load(),
    announcementsStore.loadFromSupabase(publishedOnly: true),
    lessonsStore.loadPublishedForStudents(),
    if (attendanceStore != null) attendanceStore.loadFromSupabase(),
  ]);

  await assessmentsStore.loadForPublishedLessons();
}

/// Loads published lessons, assessments, and student progress for learning tab.
Future<void> loadStudentLearningData({
  required TeacherLessonsStore lessonsStore,
  required TeacherAssessmentsStore assessmentsStore,
  required LearningProgressStore progressStore,
  AttendanceStore? attendanceStore,
}) async {
  await lessonsStore.loadPublishedForStudents();
  await assessmentsStore.loadForPublishedLessons();
  await progressStore.loadFromSupabase();
  if (attendanceStore != null) {
    await attendanceStore.loadFromSupabase();
  }
}
