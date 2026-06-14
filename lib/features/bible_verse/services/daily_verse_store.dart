import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitoapp/features/admin/services/users_management_store.dart';
import 'package:kitoapp/features/bible_verse/services/daily_verse_supabase_service.dart';
import 'package:kitoapp/features/notifications/services/notifications_store.dart';
import 'package:kitoapp/shared/models/bible_verse.dart';

class DailyVerseSummary {
  const DailyVerseSummary({
    required this.totalPosted,
    required this.daysWithVerses,
  });

  final int totalPosted;
  final int daysWithVerses;
}

class DailyVerseStore extends ChangeNotifier {
  DailyVerseStore({
    NotificationsStore? notificationsStore,
    UsersManagementStore? usersManagementStore,
  })  : _notificationsStore = notificationsStore,
        _usersManagementStore = usersManagementStore;

  final NotificationsStore? _notificationsStore;
  final UsersManagementStore? _usersManagementStore;
  final List<BibleVerse> _verses = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BibleVerse> get allVerses {
    final copy = List<BibleVerse>.from(_verses);
    copy.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    return List.unmodifiable(copy);
  }

  BibleVerse? get todayVerse {
    final now = DateTime.now();
    for (final verse in allVerses) {
      if (_isSameDay(verse.scheduledDate, now)) return verse;
    }
    for (final verse in allVerses) {
      if (!_isSameDay(verse.scheduledDate, now) &&
          !verse.scheduledDate.isAfter(now)) {
        return verse;
      }
    }
    return allVerses.isEmpty ? null : allVerses.last;
  }

  List<BibleVerse> get previousVerses {
    final today = todayVerse;
    if (today == null) return allVerses;
    return allVerses.where((verse) => verse.id != today.id).toList();
  }

  DailyVerseSummary get summary {
    final dates = allVerses.map((v) => _dateKey(v.scheduledDate)).toSet();
    return DailyVerseSummary(
      totalPosted: allVerses.length,
      daysWithVerses: dates.length,
    );
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remoteVerses = await DailyVerseSupabaseService.fetchAllVerses();
      _verses
        ..clear()
        ..addAll(remoteVerses);
      _error = null;
      debugPrint('DailyVerseStore.load: stored ${_verses.length} verses');
    } catch (error, stackTrace) {
      debugPrint('DailyVerseStore.load failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  BibleVerse? verseById(String id) {
    for (final verse in _verses) {
      if (verse.id == id) return verse;
    }
    return null;
  }

  bool isToday(BibleVerse verse) {
    return isScheduledToday(verse.scheduledDate);
  }

  bool isScheduledToday(DateTime scheduledDate) {
    return _isSameDay(scheduledDate, DateTime.now());
  }

  Future<bool> addVerse({
    required String text,
    required String reference,
    required DateTime scheduledDate,
    String? localImagePath,
    XFile? pickedImage,
    String? imageUrl,
  }) async {
    try {
      final saved = await DailyVerseSupabaseService.addVerse(
        text: text,
        reference: reference,
        scheduledDate: scheduledDate,
        localImagePath: localImagePath,
        pickedImage: pickedImage,
        imageUrl: imageUrl,
      );

      _upsertLocalVerse(saved);
      _error = null;
      notifyListeners();

      final studentIds =
          _usersManagementStore?.activeStudentIds() ?? const <String>[];
      if (studentIds.isNotEmpty) {
        _notificationsStore?.notifyDailyVerseForStudents(
          studentIds,
          reference: reference.trim(),
        );
      }

      return true;
    } catch (error, stackTrace) {
      debugPrint('DailyVerseStore.addVerse failed: $error\n$stackTrace');
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVerse({
    required String id,
    required String text,
    required String reference,
    required DateTime scheduledDate,
    String? localImagePath,
    XFile? pickedImage,
    String? imageUrl,
    bool removeImage = false,
  }) async {
    try {
      final saved = await DailyVerseSupabaseService.updateVerse(
        id: id,
        text: text,
        reference: reference,
        scheduledDate: scheduledDate,
        localImagePath: localImagePath,
        pickedImage: pickedImage,
        imageUrl: imageUrl,
        removeImage: removeImage,
      );

      _upsertLocalVerse(saved);
      _error = null;
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('DailyVerseStore.updateVerse failed: $error\n$stackTrace');
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVerse(String id) async {
    _verses.removeWhere((verse) => verse.id == id);
    notifyListeners();

    try {
      await DailyVerseSupabaseService.deleteVerse(id);
      return true;
    } catch (error, stackTrace) {
      debugPrint('DailyVerseStore.deleteVerse failed: $error\n$stackTrace');
      _error = error.toString();
      await load();
      return false;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  void _upsertLocalVerse(BibleVerse verse) {
    _verses.removeWhere(
      (existing) =>
          existing.id == verse.id ||
          _isSameDay(existing.scheduledDate, verse.scheduledDate),
    );
    _verses.insert(0, verse);
  }
}
