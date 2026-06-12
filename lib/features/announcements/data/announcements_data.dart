import 'package:kitoapp/features/announcements/models/announcement_item.dart';

class AnnouncementsData {
  AnnouncementsData._();

  static final items = <AnnouncementItem>[
    AnnouncementItem(
      id: 'a1',
      title: 'Sunday Service',
      message:
          'Join us this Sunday at 9:00 AM for worship and fellowship. '
          'All students are encouraged to attend in person.',
      date: DateTime(2026, 6, 12),
      author: 'Pastor Samuel',
      category: AnnouncementCategory.church,
      isNew: true,
    ),
    AnnouncementItem(
      id: 'a2',
      title: 'Youth Retreat',
      message:
          'Registration for the summer youth retreat is now open. '
          'Speak with your teacher to sign up before June 20.',
      date: DateTime(2026, 6, 10),
      author: 'Youth Ministry',
      category: AnnouncementCategory.events,
      isNew: true,
    ),
    AnnouncementItem(
      id: 'a3',
      title: 'Quiz Week',
      message:
          'Prepare for end-of-term quizzes starting next Monday. '
          'Review lessons 1–5 in the Learning section.',
      date: DateTime(2026, 6, 8),
      author: 'Mr. Daniel',
      category: AnnouncementCategory.academic,
      isNew: false,
    ),
    AnnouncementItem(
      id: 'a4',
      title: 'Bible Memory Competition',
      message:
          'The branch-level Bible memory competition will be held on June 25. '
          'Practice your assigned verses daily.',
      date: DateTime(2026, 6, 5),
      author: 'Ms. Sara',
      category: AnnouncementCategory.academic,
      isNew: false,
    ),
    AnnouncementItem(
      id: 'a5',
      title: 'Community Outreach',
      message:
          'We will visit the local care home next Saturday. '
          'Volunteers should meet at the church at 8:00 AM.',
      date: DateTime(2026, 6, 1),
      author: 'Sister Ruth',
      category: AnnouncementCategory.events,
      isNew: false,
    ),
    AnnouncementItem(
      id: 'a6',
      title: 'Prayer & Fasting Week',
      message:
          'Join the church-wide prayer and fasting week beginning July 1. '
          'Daily prayer points will be shared in announcements.',
      date: DateTime(2026, 5, 28),
      author: 'Pastor Samuel',
      category: AnnouncementCategory.church,
      isNew: false,
    ),
  ];

  static AnnouncementSummary get summary {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return AnnouncementSummary(
      total: items.length,
      unread: items.where((item) => item.isNew).length,
      thisWeek: items.where((item) => item.date.isAfter(weekAgo)).length,
    );
  }

  static List<AnnouncementItem> itemsFor(AnnouncementCategory? category) {
    final filtered = category == null
        ? items
        : items.where((item) => item.category == category).toList();
    return filtered..sort((a, b) => b.date.compareTo(a.date));
  }
}
