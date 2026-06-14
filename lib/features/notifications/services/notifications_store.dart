import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/core/router/app_router.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/notifications/models/app_notification.dart';
import 'package:kitoapp/features/notifications/services/notifications_supabase_service.dart';

class NotificationsStore extends ChangeNotifier {
  final List<AppNotification> _items = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AppNotification> get allItems => List.unmodifiable(_items);

  List<AppNotification> forStudent(String studentId) {
    return _items
        .where(
          (item) =>
              item.audience == NotificationAudience.student &&
              item.userId == studentId,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<AppNotification> forAdmin() {
    return _items
        .where((item) => item.audience == NotificationAudience.admin)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int unreadCountForStudent(String studentId) =>
      forStudent(studentId).where((item) => !item.isRead).length;

  int unreadCountForAdmin() =>
      forAdmin().where((item) => !item.isRead).length;

  Future<void> load() async {
    final role = AuthSession.role;
    final userId = AuthSession.userId;

    if (role == null) {
      _items.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<AppNotification> remote;
      if (role == UserRole.admin) {
        remote = await NotificationsSupabaseService.fetchForAdmin();
      } else if (role == UserRole.student && userId != null) {
        remote = await NotificationsSupabaseService.fetchForStudent(userId);
      } else {
        remote = const [];
      }

      _items
        ..clear()
        ..addAll(remote);
      debugPrint('NotificationsStore.load: stored ${_items.length} notifications');
    } catch (error, stackTrace) {
      debugPrint('NotificationsStore.load failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1 || _items[index].isRead) return;

    _items[index] = _items[index].copyWith(isRead: true);
    notifyListeners();

    try {
      await NotificationsSupabaseService.markRead(id);
    } catch (error, stackTrace) {
      debugPrint('NotificationsStore.markRead failed: $error\n$stackTrace');
      _error = error.toString();
      await load();
    }
  }

  Future<void> markAllRead({
    required NotificationAudience audience,
    String? userId,
  }) async {
    var changed = false;
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.audience != audience || item.isRead) continue;
      if (audience == NotificationAudience.student && item.userId != userId) {
        continue;
      }
      _items[i] = item.copyWith(isRead: true);
      changed = true;
    }
    if (changed) notifyListeners();

    try {
      await NotificationsSupabaseService.markAllRead(
        audience: audience,
        userId: userId,
      );
    } catch (error, stackTrace) {
      debugPrint('NotificationsStore.markAllRead failed: $error\n$stackTrace');
      _error = error.toString();
      await load();
    }
  }

  void notifyWeeklyLesson({
    required String studentId,
    required String weekTitle,
    required String lessonId,
  }) {
    unawaited(
      _persistNotification(
        AppNotification(
          id: '',
          type: AppNotificationType.weeklyLesson,
          audience: NotificationAudience.student,
          userId: studentId,
          title: 'Weekly lesson reminder',
          body:
              'Your lesson "$weekTitle" is ready. Continue this week\'s study before the deadline.',
          createdAt: DateTime.now(),
          route: StudentRoutes.lessonReader(lessonId),
        ),
      ),
    );
  }

  void notifyGiftArrived({
    required String studentId,
    required String giftTitle,
  }) {
    unawaited(
      _persistNotification(
        AppNotification(
          id: '',
          type: AppNotificationType.giftArrived,
          audience: NotificationAudience.student,
          userId: studentId,
          title: 'Gift from your sponsor',
          body:
              'A gift has arrived: $giftTitle. Open Gifts to view the details.',
          createdAt: DateTime.now(),
          route: StudentRoutes.gifts,
        ),
      ),
    );
  }

  void notifyDailyVerse({
    required String studentId,
    required String reference,
  }) {
    unawaited(
      _persistNotification(
        AppNotification(
          id: '',
          type: AppNotificationType.dailyVerse,
          audience: NotificationAudience.student,
          userId: studentId,
          title: 'Today\'s verse',
          body: 'A new daily verse is available: $reference.',
          createdAt: DateTime.now(),
          route: StudentRoutes.dailyVerse,
        ),
      ),
    );
  }

  void notifyDailyVerseForStudents(
    Iterable<String> studentIds, {
    required String reference,
  }) {
    for (final studentId in studentIds) {
      notifyDailyVerse(studentId: studentId, reference: reference);
    }
  }

  void notifyAdminRegistration({
    required String userId,
    required String studentName,
    required String email,
  }) {
    unawaited(
      _persistNotification(
        AppNotification(
          id: '',
          type: AppNotificationType.registrationPending,
          audience: NotificationAudience.admin,
          userId: userId,
          title: 'New student registration',
          body:
              '$studentName ($email) registered and is waiting for your approval.',
          createdAt: DateTime.now(),
          route: AdminRoutes.users,
        ),
      ),
    );
  }

  void notifyAccountApproved({
    required String studentId,
    required String studentName,
  }) {
    unawaited(
      _persistNotification(
        AppNotification(
          id: '',
          type: AppNotificationType.accountApproved,
          audience: NotificationAudience.student,
          userId: studentId,
          title: 'Account approved',
          body:
              'Welcome, $studentName! Your account has been approved. You can now sign in.',
          createdAt: DateTime.now(),
          route: AppRoutes.login,
        ),
      ),
    );
  }

  Future<void> _persistNotification(AppNotification notification) async {
    try {
      final saved = await NotificationsSupabaseService.insert(notification);
      _upsertLocal(saved);
      _error = null;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint(
        'NotificationsStore._persistNotification failed: $error\n$stackTrace',
      );
      _error = error.toString();
    }
  }

  void _upsertLocal(AppNotification notification) {
    _items.removeWhere((item) => item.id == notification.id);
    _items.insert(0, notification);
  }
}
