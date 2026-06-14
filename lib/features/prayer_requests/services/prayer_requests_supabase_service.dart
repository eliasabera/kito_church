import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/prayer_requests/models/prayer_request.dart';

class PrayerRequestsSupabaseService {
  PrayerRequestsSupabaseService._();

  static Future<List<PrayerRequest>> fetchRequests() async {
    final rows = await SupabaseAuthService.client
        .from('prayer_requests')
        .select('*, users(full_name)')
        .order('created_at', ascending: false);

    final requests = (rows as List).cast<Map<String, dynamic>>();
    if (requests.isEmpty) return const [];

    final requestIds = requests.map((row) => row['id'] as String).toList();
    final commentsByRequest = await _fetchCommentsByRequest(requestIds);
    final likesByRequest = await _fetchLikesByRequest(requestIds);

    return requests.map((row) {
      final id = row['id'] as String;
      return PrayerRequest(
        id: id,
        authorId: row['author_id'] as String?,
        authorName: _authorNameFromRow(row),
        message: row['message'] as String,
        date: DateTime.parse(row['created_at'] as String).toLocal(),
        status: _parseStatus(row['status'] as String?),
        isPrivate: row['is_private'] as bool? ?? false,
        likedBy: likesByRequest[id] ?? {},
        comments: commentsByRequest[id] ?? [],
      );
    }).toList();
  }

  static Future<PrayerRequest> submitRequest({
    required String message,
    required String authorId,
    required String authorName,
  }) async {
    final row = await SupabaseAuthService.client
        .from('prayer_requests')
        .insert({
          'author_id': authorId,
          'message': message.trim(),
        })
        .select('*, users(full_name)')
        .single();

    return PrayerRequest(
      id: row['id'] as String,
      authorId: authorId,
      authorName: authorName,
      message: row['message'] as String,
      date: DateTime.parse(row['created_at'] as String).toLocal(),
    );
  }

  static Future<void> updateStatus(
    String requestId,
    PrayerRequestStatus status,
  ) async {
    await SupabaseAuthService.client
        .from('prayer_requests')
        .update({'status': status.name})
        .eq('id', requestId);
  }

  static Future<bool> toggleLike({
    required String requestId,
    required String userId,
    required bool currentlyLiked,
  }) async {
    if (currentlyLiked) {
      await SupabaseAuthService.client
          .from('prayer_likes')
          .delete()
          .eq('prayer_request_id', requestId)
          .eq('user_id', userId);
      return false;
    }

    await SupabaseAuthService.client.from('prayer_likes').insert({
      'prayer_request_id': requestId,
      'user_id': userId,
    });
    return true;
  }

  static Future<PrayerComment> addComment({
    required String requestId,
    required String authorId,
    required UserRole authorRole,
    required String authorName,
    required String message,
  }) async {
    final row = await SupabaseAuthService.client
        .from('prayer_comments')
        .insert({
          'prayer_request_id': requestId,
          'author_id': authorId,
          'author_role': authorRole.name,
          'message': message.trim(),
        })
        .select()
        .single();

    return PrayerComment(
      id: row['id'] as String,
      authorName: authorName,
      authorRole: authorRole,
      message: row['message'] as String,
      date: DateTime.parse(row['created_at'] as String).toLocal(),
    );
  }

  static Future<Map<String, List<PrayerComment>>> _fetchCommentsByRequest(
    List<String> requestIds,
  ) async {
    final rows = await SupabaseAuthService.client
        .from('prayer_comments')
        .select('*, users(full_name)')
        .inFilter('prayer_request_id', requestIds)
        .order('created_at');

    final grouped = <String, List<PrayerComment>>{};
    for (final row in rows as List) {
      final map = Map<String, dynamic>.from(row as Map);
      final requestId = map['prayer_request_id'] as String;
      grouped.putIfAbsent(requestId, () => []).add(
            PrayerComment(
              id: map['id'] as String,
              authorName: _authorNameFromRow(map),
              authorRole: _parseRole(map['author_role'] as String?),
              message: map['message'] as String,
              date: DateTime.parse(map['created_at'] as String).toLocal(),
            ),
          );
    }
    return grouped;
  }

  static Future<Map<String, Set<String>>> _fetchLikesByRequest(
    List<String> requestIds,
  ) async {
    final rows = await SupabaseAuthService.client
        .from('prayer_likes')
        .select('prayer_request_id, user_id')
        .inFilter('prayer_request_id', requestIds);

    final grouped = <String, Set<String>>{};
    for (final row in rows as List) {
      final map = Map<String, dynamic>.from(row as Map);
      final requestId = map['prayer_request_id'] as String;
      grouped.putIfAbsent(requestId, () => {}).add(map['user_id'] as String);
    }
    return grouped;
  }

  static String _authorNameFromRow(Map<String, dynamic> row) {
    final users = row['users'];
    if (users is Map) {
      return users['full_name'] as String? ?? 'Student';
    }
    if (users is List && users.isNotEmpty) {
      return (users.first as Map)['full_name'] as String? ?? 'Student';
    }
    return 'Student';
  }

  static PrayerRequestStatus _parseStatus(String? value) {
    return PrayerRequestStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PrayerRequestStatus.praying,
    );
  }

  static UserRole _parseRole(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.student,
    );
  }
}
