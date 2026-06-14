import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/dashboard/services/student_home_loader.dart';
import 'package:kitoapp/features/dashboard/widgets/student_daily_verse_card.dart';
import 'package:kitoapp/features/dashboard/widgets/student_home_hero.dart';
import 'package:kitoapp/features/dashboard/widgets/student_bible_stories_slider.dart';
import 'package:kitoapp/features/dashboard/widgets/student_recent_announcements.dart';
import 'package:kitoapp/features/dashboard/widgets/student_weekly_focus.dart';
import 'package:kitoapp/shared/widgets/announcements_store_provider.dart';
import 'package:kitoapp/shared/widgets/attendance_store_provider.dart';
import 'package:kitoapp/shared/widgets/bible_stories_store_provider.dart';
import 'package:kitoapp/shared/widgets/daily_verse_store_provider.dart';
import 'package:kitoapp/shared/widgets/profile_store_provider.dart';
import 'package:kitoapp/shared/widgets/teacher_assessments_store_provider.dart';
import 'package:kitoapp/shared/widgets/teacher_lessons_store_provider.dart';

class StudentDashboardContent extends StatefulWidget {
  const StudentDashboardContent({super.key});

  @override
  State<StudentDashboardContent> createState() =>
      _StudentDashboardContentState();
}

class _StudentDashboardContentState extends State<StudentDashboardContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHomeData());
  }

  Future<void> _loadHomeData() async {
    await loadStudentHomeData(
      profileStore: ProfileStoreProvider.of(context),
      dailyVerseStore: DailyVerseStoreProvider.of(context),
      bibleStoriesStore: BibleStoriesStoreProvider.of(context),
      announcementsStore: AnnouncementsStoreProvider.of(context),
      lessonsStore: TeacherLessonsStoreProvider.of(context),
      assessmentsStore: TeacherAssessmentsStoreProvider.of(context),
      attendanceStore: AttendanceStoreProvider.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.03),
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              StudentHomeHero(),
              SizedBox(height: 20),
              StudentBibleStoriesSlider(),
              SizedBox(height: 22),
              StudentWeeklyFocus(),
              SizedBox(height: 22),
              StudentDailyVerseCard(),
              SizedBox(height: 22),
              StudentRecentAnnouncements(),
            ],
          ),
        ),
      ),
    );
  }
}
