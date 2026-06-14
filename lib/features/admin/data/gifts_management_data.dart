import 'package:kitoapp/core/enums/app_enums.dart';
import 'package:kitoapp/features/admin/models/managed_gift.dart';

class GiftsManagementData {
  GiftsManagementData._();

  static final initialGifts = [
    ManagedGift(
      id: 'g1',
      studentId: 'u1',
      studentName: 'Abel Tesfaye',
      sponsorId: 's1',
      sponsorName: 'John Miller',
      title: 'Birthday Card & Letter',
      description:
          'A heartfelt birthday letter and handmade card from your sponsor.',
      date: DateTime(2026, 6, 5),
      type: GiftType.digital,
      status: GiftStatus.received,
      announced: true,
      announcedAt: DateTime(2026, 6, 6),
    ),
    ManagedGift(
      id: 'g2',
      studentId: 'u1',
      studentName: 'Abel Tesfaye',
      sponsorId: 's1',
      sponsorName: 'John Miller',
      title: 'School Backpack',
      description:
          'A new backpack with notebooks and pens for the new university term.',
      date: DateTime(2026, 5, 20),
      type: GiftType.physical,
      status: GiftStatus.delivered,
      announced: true,
      announcedAt: DateTime(2026, 5, 21),
    ),
    ManagedGift(
      id: 'g3',
      studentId: 'u2',
      studentName: 'Hanna Bekele',
      sponsorId: 's2',
      sponsorName: 'Sarah Johnson',
      title: 'Encouragement Package',
      description: 'Books and stationery sent for the new semester.',
      date: DateTime(2026, 6, 10),
      type: GiftType.physical,
      status: GiftStatus.pending,
      announced: false,
    ),
    ManagedGift(
      id: 'g4',
      studentId: 'u1',
      studentName: 'Abel Tesfaye',
      sponsorId: 's1',
      sponsorName: 'John Miller',
      title: 'Winter Jacket',
      description: 'A warm jacket for the rainy season.',
      date: DateTime(2026, 6, 12),
      type: GiftType.physical,
      status: GiftStatus.pending,
      announced: false,
    ),
  ];
}
