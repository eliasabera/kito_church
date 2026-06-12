import 'package:flutter/foundation.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/prayer_requests/data/prayer_requests_data.dart';
import 'package:kitoapp/features/prayer_requests/models/prayer_request.dart';

class PrayerRequestsStore extends ChangeNotifier {
  PrayerRequestsStore()
      : _requests = List.of(PrayerRequestsData.initialRequests);

  final List<PrayerRequest> _requests;
  int _idCounter = 5;
  int _commentCounter = 4;

  List<PrayerRequest> get requests {
    final copy = List<PrayerRequest>.from(_requests);
    copy.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(copy);
  }

  PrayerSummary get summary => PrayerRequestsData.summaryFor(_requests);

  void submitRequest({
    required String message,
    required String authorName,
  }) {
    _requests.insert(
      0,
      PrayerRequest(
        id: 'p${_idCounter++}',
        authorName: authorName,
        message: message,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void toggleLike(String requestId, String userId) {
    final request = _requestById(requestId);
    if (request == null) return;
    if (request.likedBy.contains(userId)) {
      request.likedBy.remove(userId);
    } else {
      request.likedBy.add(userId);
    }
    notifyListeners();
  }

  bool isLikedBy(String requestId, String userId) {
    return _requestById(requestId)?.likedBy.contains(userId) ?? false;
  }

  void addComment({
    required String requestId,
    required String authorName,
    required UserRole authorRole,
    required String message,
  }) {
    final request = _requestById(requestId);
    if (request == null) return;
    request.comments.add(
      PrayerComment(
        id: 'c${_commentCounter++}',
        authorName: authorName,
        authorRole: authorRole,
        message: message.trim(),
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  PrayerRequest? _requestById(String id) {
    for (final request in _requests) {
      if (request.id == id) return request;
    }
    return null;
  }

  static String userIdForRole(UserRole role) => role.name;
}
