import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/gifts/models/gift_item.dart';

class ManagedGift {
  const ManagedGift({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.sponsorId,
    required this.sponsorName,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.status,
    required this.announced,
    this.announcedAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String sponsorId;
  final String sponsorName;
  final String title;
  final String description;
  final DateTime date;
  final GiftType type;
  final GiftStatus status;
  final bool announced;
  final DateTime? announcedAt;

  ManagedGift copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? sponsorId,
    String? sponsorName,
    String? title,
    String? description,
    DateTime? date,
    GiftType? type,
    GiftStatus? status,
    bool? announced,
    DateTime? announcedAt,
  }) {
    return ManagedGift(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      sponsorId: sponsorId ?? this.sponsorId,
      sponsorName: sponsorName ?? this.sponsorName,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      announced: announced ?? this.announced,
      announcedAt: announcedAt ?? this.announcedAt,
    );
  }

  GiftItem toGiftItem() {
    return GiftItem(
      id: id,
      title: title,
      description: description,
      sponsorName: sponsorName,
      date: date,
      type: type,
      status: status,
    );
  }
}

class ManagedGiftSummary {
  const ManagedGiftSummary({
    required this.total,
    required this.awaitingAnnouncement,
    required this.announced,
    required this.pending,
    required this.received,
    required this.delivered,
  });

  final int total;
  final int awaitingAnnouncement;
  final int announced;
  final int pending;
  final int received;
  final int delivered;
}

class SponsorshipManagementSummary {
  const SponsorshipManagementSummary({
    required this.totalStudents,
    required this.linkedStudents,
    required this.unlinkedStudents,
    required this.totalSponsors,
    required this.availableSponsors,
  });

  final int totalStudents;
  final int linkedStudents;
  final int unlinkedStudents;
  final int totalSponsors;
  final int availableSponsors;
}
