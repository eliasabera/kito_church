import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/dashboard/widgets/student_daily_verse_card.dart';
import 'package:kitoapp/features/dashboard/widgets/student_home_hero.dart';
import 'package:kitoapp/features/dashboard/widgets/student_bible_stories_slider.dart';
import 'package:kitoapp/features/dashboard/widgets/student_recent_announcements.dart';
import 'package:kitoapp/features/dashboard/widgets/student_weekly_focus.dart';
import 'package:kitoapp/features/profile/data/profile_data.dart';

class StudentDashboardContent extends StatelessWidget {
  const StudentDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ProfileData.student;

    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.03),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StudentHomeHero(studentName: profile.fullName),
            const SizedBox(height: 20),
            const StudentBibleStoriesSlider(),
            const SizedBox(height: 22),
            const StudentWeeklyFocus(),
            const SizedBox(height: 22),
            const StudentDailyVerseCard(),
            const SizedBox(height: 22),
            const StudentRecentAnnouncements(),
          ],
        ),
      ),
    );
  }
}
