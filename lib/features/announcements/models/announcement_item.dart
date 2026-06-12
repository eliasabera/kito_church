enum AnnouncementCategory { church, events, academic }

class AnnouncementItem {
  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.author,
    required this.category,
    this.isNew = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime date;
  final String author;
  final AnnouncementCategory category;
  final bool isNew;
}

class AnnouncementSummary {
  const AnnouncementSummary({
    required this.total,
    required this.unread,
    required this.thisWeek,
  });

  final int total;
  final int unread;
  final int thisWeek;
}
