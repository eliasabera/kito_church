import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/prayer_requests/models/prayer_request.dart';

class PrayerRequestsData {
  PrayerRequestsData._();

  static List<PrayerRequest> get initialRequests => [
        PrayerRequest(
          id: 'p1',
          authorName: 'Sara Bekele',
          message:
              'Please pray for my grandmother who is recovering from surgery.',
          date: DateTime(2026, 6, 10),
          status: PrayerRequestStatus.praying,
          likedBy: {'teacher', 'student'},
          comments: [
            PrayerComment(
              id: 'c1',
              authorName: 'Mr. Daniel',
              authorRole: UserRole.teacher,
              message: 'We are praying with you, Sara.',
              date: DateTime(2026, 6, 10, 14, 30),
            ),
          ],
        ),
        PrayerRequest(
          id: 'p2',
          authorId: 'u1',
          authorName: 'Abel Tesfaye',
          message:
              'Pray for wisdom as I prepare for the end-of-term Bible memory quiz.',
          date: DateTime(2026, 6, 3),
          status: PrayerRequestStatus.praying,
          likedBy: {'teacher'},
        ),
        PrayerRequest(
          id: 'p3',
          authorName: 'Meron Haile',
          message:
              'Thank God — my father found a new job! Please continue praying for our family.',
          date: DateTime(2026, 5, 20),
          status: PrayerRequestStatus.answered,
          likedBy: {'student', 'teacher'},
          comments: [
            PrayerComment(
              id: 'c2',
              authorName: 'Abel Tesfaye',
              authorRole: UserRole.student,
              message: 'Praise God! So happy for your family.',
              date: DateTime(2026, 5, 21, 9, 15),
            ),
            PrayerComment(
              id: 'c3',
              authorName: 'Mr. Daniel',
              authorRole: UserRole.teacher,
              message: 'Glory to God! Marked as answered.',
              date: DateTime(2026, 5, 21, 11, 0),
            ),
          ],
        ),
        PrayerRequest(
          id: 'p4',
          authorName: 'Yonas Girma',
          message: 'Pray for peace in our community during the rainy season.',
          date: DateTime(2026, 5, 8),
          status: PrayerRequestStatus.answered,
          likedBy: {'student'},
        ),
      ];

  static PrayerSummary summaryFor(List<PrayerRequest> list) {
    return PrayerSummary(
      total: list.length,
      praying: list
          .where((r) => r.status == PrayerRequestStatus.praying)
          .length,
      answered: list
          .where((r) => r.status == PrayerRequestStatus.answered)
          .length,
    );
  }
}
