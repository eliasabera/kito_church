import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/gifts/models/gift_item.dart';

class GiftsData {
  GiftsData._();

  static final items = <GiftItem>[
    GiftItem(
      id: 'g1',
      title: 'Birthday Card & Letter',
      description:
          'A heartfelt birthday letter and handmade card from your sponsor.',
      sponsorName: 'John Miller',
      date: DateTime(2026, 6, 5),
      type: GiftType.digital,
      status: GiftStatus.received,
    ),
    GiftItem(
      id: 'g2',
      title: 'School Backpack',
      description:
          'A new backpack with notebooks and pens for the new school term.',
      sponsorName: 'John Miller',
      date: DateTime(2026, 5, 20),
      type: GiftType.physical,
      status: GiftStatus.delivered,
    ),
    GiftItem(
      id: 'g3',
      title: 'Encouragement Video',
      description:
          'A short video message wishing you success in your Bible memory quiz.',
      sponsorName: 'John Miller',
      date: DateTime(2026, 5, 8),
      type: GiftType.digital,
      status: GiftStatus.received,
    ),
    GiftItem(
      id: 'g4',
      title: 'Winter Jacket',
      description: 'A warm jacket for the rainy season.',
      sponsorName: 'John Miller',
      date: DateTime(2026, 4, 15),
      type: GiftType.physical,
      status: GiftStatus.pending,
    ),
    GiftItem(
      id: 'g5',
      title: 'Christmas Gift Package',
      description: 'Holiday gift box with toys, books, and a family photo.',
      sponsorName: 'John Miller',
      date: DateTime(2025, 12, 20),
      type: GiftType.physical,
      status: GiftStatus.delivered,
    ),
    GiftItem(
      id: 'g6',
      title: 'Prayer Letter',
      description:
          'A letter sharing prayers and encouragement for your studies.',
      sponsorName: 'John Miller',
      date: DateTime(2026, 3, 10),
      type: GiftType.digital,
      status: GiftStatus.received,
    ),
  ];

  static GiftSummary get summary {
    return GiftSummary(
      total: items.length,
      pending: items.where((g) => g.status == GiftStatus.pending).length,
      received: items.where((g) => g.status == GiftStatus.received).length,
      delivered: items.where((g) => g.status == GiftStatus.delivered).length,
    );
  }

  static List<GiftItem> itemsFor({
    GiftType? type,
    GiftStatus? status,
  }) {
    return items.where((item) {
      if (type != null && item.type != type) return false;
      if (status != null && item.status != status) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
