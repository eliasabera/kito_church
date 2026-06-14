import 'package:flutter/foundation.dart';
import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/prayer_requests/models/prayer_request.dart';
import 'package:kitoapp/features/prayer_requests/services/prayer_requests_supabase_service.dart';

class PrayerRequestsStore extends ChangeNotifier {
  final List<PrayerRequest> _requests = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<PrayerRequest> get requests {
    final copy = List<PrayerRequest>.from(_requests);
    copy.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(copy);
  }

  PrayerSummary get summary {
    var praying = 0;
    var answered = 0;
    for (final request in _requests) {
      if (request.status == PrayerRequestStatus.answered) {
        answered++;
      } else {
        praying++;
      }
    }
    return PrayerSummary(
      total: _requests.length,
      praying: praying,
      answered: answered,
    );
  }

  Future<void> loadFromSupabase() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remote = await PrayerRequestsSupabaseService.fetchRequests();
      _requests
        ..clear()
        ..addAll(remote);
    } catch (error, stackTrace) {
      debugPrint('PrayerRequestsStore.loadFromSupabase failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitRequest({
    required String message,
    required String authorName,
    String? authorId,
  }) async {
    final userId = authorId ?? AuthSession.userId;
    if (userId == null) return;

    try {
      final request = await PrayerRequestsSupabaseService.submitRequest(
        message: message,
        authorId: userId,
        authorName: authorName,
      );
      _requests.insert(0, request);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('PrayerRequestsStore.submitRequest failed: $error\n$stackTrace');
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStatus(String requestId, PrayerRequestStatus status) async {
    final request = _requestById(requestId);
    if (request == null) return;

    final previous = request.status;
    request.status = status;
    notifyListeners();

    try {
      await PrayerRequestsSupabaseService.updateStatus(requestId, status);
    } catch (error, stackTrace) {
      debugPrint('PrayerRequestsStore.updateStatus failed: $error\n$stackTrace');
      request.status = previous;
      _error = error.toString();
      notifyListeners();
    }
  }

  bool canStudentEdit(PrayerRequest request) {
    final userId = AuthSession.userId;
    if (userId == null) return false;
    return request.authorId == userId;
  }

  Future<void> toggleLike(String requestId, String userId) async {
    final request = _requestById(requestId);
    if (request == null) return;

    final wasLiked = request.likedBy.contains(userId);
    if (wasLiked) {
      request.likedBy.remove(userId);
    } else {
      request.likedBy.add(userId);
    }
    notifyListeners();

    try {
      final isLiked = await PrayerRequestsSupabaseService.toggleLike(
        requestId: requestId,
        userId: userId,
        currentlyLiked: wasLiked,
      );
      if (isLiked && !request.likedBy.contains(userId)) {
        request.likedBy.add(userId);
      } else if (!isLiked) {
        request.likedBy.remove(userId);
      }
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('PrayerRequestsStore.toggleLike failed: $error\n$stackTrace');
      if (wasLiked) {
        request.likedBy.add(userId);
      } else {
        request.likedBy.remove(userId);
      }
      _error = error.toString();
      notifyListeners();
    }
  }

  bool isLikedBy(String requestId, String userId) {
    return _requestById(requestId)?.likedBy.contains(userId) ?? false;
  }

  Future<void> addComment({
    required String requestId,
    required String authorName,
    required UserRole authorRole,
    required String message,
  }) async {
    final request = _requestById(requestId);
    if (request == null) return;

    final authorId = AuthSession.userId;
    if (authorId == null) return;

    try {
      final comment = await PrayerRequestsSupabaseService.addComment(
        requestId: requestId,
        authorId: authorId,
        authorRole: authorRole,
        authorName: authorName,
        message: message,
      );
      request.comments.add(comment);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('PrayerRequestsStore.addComment failed: $error\n$stackTrace');
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  PrayerRequest? _requestById(String id) {
    for (final request in _requests) {
      if (request.id == id) return request;
    }
    return null;
  }

  static String userIdForRole(UserRole role) {
    return AuthSession.userId ?? role.name;
  }
}
