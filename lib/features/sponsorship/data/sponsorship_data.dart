import 'package:kitoapp/features/sponsorship/models/sponsorship_info.dart';

class SponsorshipData {
  SponsorshipData._();

  static const sponsor = SponsorProfile(
    name: 'John Miller',
    country: 'USA',
    sponsoredSince: '2019',
    lettersExchanged: 12,
    giftsReceived: 6,
    message:
        'Abel, I am so proud of your progress in school and in your faith. '
        'Keep memorizing Scripture and serving in your church. I pray for you '
        'and your family every week. God bless you!',
  );

  static final letters = <SponsorLetter>[
    SponsorLetter(
      id: 'l1',
      date: DateTime(2026, 6, 1),
      preview:
          'Happy birthday, Abel! I hope this year brings you joy and growth...',
      isNew: true,
    ),
    SponsorLetter(
      id: 'l2',
      date: DateTime(2026, 3, 15),
      preview:
          'I loved hearing about your ranking in class. Keep working hard...',
      isNew: false,
    ),
    SponsorLetter(
      id: 'l3',
      date: DateTime(2025, 12, 20),
      preview:
          'Merry Christmas! The gift package should arrive soon. Remember...',
      isNew: false,
    ),
    SponsorLetter(
      id: 'l4',
      date: DateTime(2025, 9, 5),
      preview:
          'School has started again — I am praying for your new teachers...',
      isNew: false,
    ),
  ];
}
