import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/notifications/models/app_notification.dart';

class NotificationsSupabaseService {
  NotificationsSupabaseService._();

  static const _table = 'notifications';

  static const _selectColumns =
      'id, user_id, type, audience, title, body, route, is_read, created_at';

  static AppNotification notificationFromRow(Map<String, dynamic> row) {
    return AppNotification(
      id: row['id']?.toString() ?? '',
      type: _typeFromDb(row['type']?.toString() ?? ''),
      audience: _audienceFromDb(row['audience']?.toString() ?? ''),
      userId: row['user_id']?.toString(),
      title: row['title']?.toString() ?? '',
      body: row['body']?.toString() ?? '',
      route: _optionalString(row['route']),
      isRead: row['is_read'] == true,
      createdAt: _parseDateTime(row['created_at']),
    );
  }

  static Future<List<AppNotification>> fetchForStudent(String userId) async {
    final rows = await SupabaseAuthService.client
        .from(_table)
        .select(_selectColumns)
        .eq('audience', 'student')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return _parseRows(rows);
  }

  static Future<List<AppNotification>> fetchForAdmin() async {
    final rows = await SupabaseAuthService.client
        .from(_table)
        .select(_selectColumns)
        .eq('audience', 'admin')
        .order('created_at', ascending: false);

    return _parseRows(rows);
  }

  static Future<AppNotification> insert(AppNotification notification) async {
    final payload = {
      if (notification.userId != null) 'user_id': notification.userId,
      'type': _typeToDb(notification.type),
      'audience': _audienceToDb(notification.audience),
      'title': notification.title,
      'body': notification.body,
      if (notification.route != null) 'route': notification.route,
      'is_read': notification.isRead,
    };

    final row = await SupabaseAuthService.client
        .from(_table)
        .insert(payload)
        .select(_selectColumns)
        .single();

    return notificationFromRow(Map<String, dynamic>.from(row));
  }

  static Future<void> markRead(String id) async {
    await SupabaseAuthService.client
        .from(_table)
        .update({'is_read': true})
        .eq('id', id);
  }

  static Future<void> markAllRead({
    required NotificationAudience audience,
    String? userId,
  }) async {
    var query = SupabaseAuthService.client
        .from(_table)
        .update({'is_read': true})
        .eq('audience', _audienceToDb(audience))
        .eq('is_read', false);

    if (audience == NotificationAudience.student && userId != null) {
      query = query.eq('user_id', userId);
    }

    await query;
  }

  static List<AppNotification> _parseRows(dynamic rows) {
    final list = rows as List;
    final notifications = <AppNotification>[];

    for (final row in list) {
      try {
        final notification = notificationFromRow(
          Map<String, dynamic>.from(row as Map),
        );
        if (notification.title.isEmpty) continue;
        notifications.add(notification);
      } catch (error, stackTrace) {
        debugPrint(
          'NotificationsSupabaseService: skipping row $row: $error\n$stackTrace',
        );
      }
    }

    debugPrint(
      'NotificationsSupabaseService: loaded ${notifications.length} notifications',
    );
    return notifications;
  }

  static AppNotificationType _typeFromDb(String value) {
    return switch (value) {
      'weekly_lesson' => AppNotificationType.weeklyLesson,
      'gift_arrived' => AppNotificationType.giftArrived,
      'daily_verse' => AppNotificationType.dailyVerse,
      'account_approved' => AppNotificationType.accountApproved,
      'registration_pending' => AppNotificationType.registrationPending,
      _ => AppNotificationType.weeklyLesson,
    };
  }

  static String _typeToDb(AppNotificationType type) {
    return switch (type) {
      AppNotificationType.weeklyLesson => 'weekly_lesson',
      AppNotificationType.giftArrived => 'gift_arrived',
      AppNotificationType.dailyVerse => 'daily_verse',
      AppNotificationType.accountApproved => 'account_approved',
      AppNotificationType.registrationPending => 'registration_pending',
    };
  }

  static NotificationAudience _audienceFromDb(String value) {
    return switch (value) {
      'admin' => NotificationAudience.admin,
      _ => NotificationAudience.student,
    };
  }

  static String _audienceToDb(NotificationAudience audience) {
    return switch (audience) {
      NotificationAudience.admin => 'admin',
      NotificationAudience.student => 'student',
    };
  }

  static String? _optionalString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime _parseDateTime(dynamic raw) {
    if (raw is DateTime) return raw;
    final text = raw?.toString().trim() ?? '';
    if (text.isEmpty) return DateTime.now();
    return DateTime.parse(text);
  }
}
