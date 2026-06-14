import 'package:kitoapp/features/announcements/models/announcement_item.dart';

class AnnouncementsData {
  AnnouncementsData._();

  static const initialCategories = [
    AnnouncementCategoryItem(id: 'cat_church', name: 'Church'),
    AnnouncementCategoryItem(id: 'cat_events', name: 'Events'),
    AnnouncementCategoryItem(id: 'cat_academic', name: 'Academic'),
  ];

  static final initialItems = <AnnouncementItem>[
    AnnouncementItem(
      id: 'a1',
      title: 'Sunday Service',
      message:
          'Join us this Sunday at 9:00 AM for worship and fellowship. '
          'All students are encouraged to attend in person.',
      date: _d(2026, 6, 12),
      author: 'Pastor Samuel',
      categoryId: 'cat_church',
    ),
    AnnouncementItem(
      id: 'a2',
      title: 'Youth Retreat',
      message:
          'Registration for the summer youth retreat is now open. '
          'Speak with your teacher to sign up before June 20.',
      date: _d(2026, 6, 10),
      author: 'Youth Ministry',
      categoryId: 'cat_events',
    ),
    AnnouncementItem(
      id: 'a3',
      title: 'Quiz Week',
      message:
          'Prepare for end-of-term quizzes starting next Monday. '
          'Review lessons 1–5 in the Learning section.',
      date: _d(2026, 6, 8),
      author: 'Mr. Daniel',
      categoryId: 'cat_academic',
    ),
    AnnouncementItem(
      id: 'a4',
      title: 'Virtual Class Schedule',
      message:
          'Updated online class times for university students are now posted. '
          'Check the Learning section for your weekly timetable.',
      date: _d(2026, 6, 5),
      author: 'Sister Ruth',
      categoryId: 'cat_academic',
    ),
    AnnouncementItem(
      id: 'a5',
      title: 'Community Outreach',
      message:
          'We will visit the local care home next Saturday. '
          'Volunteers should meet at the church at 8:00 AM.',
      date: _d(2026, 6, 1),
      author: 'Sister Ruth',
      categoryId: 'cat_events',
    ),
    AnnouncementItem(
      id: 'a6',
      title: 'Prayer & Fasting Week',
      message:
          'Join the church-wide prayer and fasting week beginning July 1. '
          'Daily prayer points will be shared in announcements.',
      date: _d(2026, 5, 28),
      author: 'Pastor Samuel',
      categoryId: 'cat_church',
    ),
  ];

  static DateTime _d(int year, int month, int day) => DateTime(year, month, day);
}
