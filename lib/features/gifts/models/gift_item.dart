import 'package:kitoapp/core/enums/app_enums.dart';

class GiftItem {
  const GiftItem({
    required this.id,
    required this.title,
    required this.description,
    required this.sponsorName,
    required this.date,
    required this.type,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final String sponsorName;
  final DateTime date;
  final GiftType type;
  final GiftStatus status;
}

class GiftSummary {
  const GiftSummary({
    required this.total,
    required this.pending,
    required this.received,
    required this.delivered,
  });

  final int total;
  final int pending;
  final int received;
  final int delivered;
}
