enum NotificationAudience {
  student,
  admin,
}

enum AppNotificationType {
  weeklyLesson,
  giftArrived,
  dailyVerse,
  accountApproved,
  registrationPending,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.audience,
    required this.title,
    required this.body,
    required this.createdAt,
    this.userId,
    this.route,
    this.isRead = false,
  });

  final String id;
  final AppNotificationType type;
  final NotificationAudience audience;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? userId;
  final String? route;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      audience: audience,
      title: title,
      body: body,
      createdAt: createdAt,
      userId: userId,
      route: route,
      isRead: isRead ?? this.isRead,
    );
  }
}
