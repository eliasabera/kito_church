import 'package:kitoapp/core/enums/app_enums.dart';

enum PrayerRequestStatus { praying, answered }

class PrayerComment {
  PrayerComment({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.message,
    required this.date,
  });

  final String id;
  final String authorName;
  final UserRole authorRole;
  final String message;
  final DateTime date;
}

class PrayerRequest {
  PrayerRequest({
    required this.id,
    required this.message,
    required this.date,
    required this.authorName,
    this.authorId,
    this.status = PrayerRequestStatus.praying,
    this.isPrivate = false,
    Set<String>? likedBy,
    List<PrayerComment>? comments,
  })  : likedBy = likedBy ?? {},
        comments = comments ?? [];

  final String id;
  final String message;
  final DateTime date;
  final String authorName;
  final String? authorId;
  PrayerRequestStatus status;
  final bool isPrivate;
  final Set<String> likedBy;
  final List<PrayerComment> comments;

  int get likeCount => likedBy.length;
}

class PrayerSummary {
  const PrayerSummary({
    required this.total,
    required this.praying,
    required this.answered,
  });

  final int total;
  final int praying;
  final int answered;
}
