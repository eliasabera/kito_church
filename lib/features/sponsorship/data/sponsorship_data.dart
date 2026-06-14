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
      body:
          'Happy birthday, Abel! I hope this year brings you joy and growth in '
          'every part of your life. I am praying that God will guide your '
          'studies and strengthen your faith. Remember that you are deeply loved '
          'and never alone. With love, John.',
      isNew: true,
    ),
    SponsorLetter(
      id: 'l2',
      date: DateTime(2026, 3, 15),
      body:
          'Dear Abel, I loved hearing about your ranking in class. Keep working '
          'hard and trusting the Lord with your future. Your dedication inspires '
          'me. I am proud of you and praying for wisdom as you prepare for exams.',
      isNew: false,
    ),
    SponsorLetter(
      id: 'l3',
      date: DateTime(2025, 12, 20),
      body:
          'Merry Christmas, Abel! The gift package should arrive soon. Remember '
          'that the greatest gift is the love of Christ. I hope you and your '
          'family have a peaceful holiday season filled with hope and gratitude.',
      isNew: false,
    ),
    SponsorLetter(
      id: 'l4',
      date: DateTime(2025, 9, 5),
      body:
          'School has started again — I am praying for your new teachers and '
          'classmates. May this semester be a time of learning, friendship, and '
          'spiritual growth. Write to me anytime about how things are going.',
      isNew: false,
    ),
  ];
}
