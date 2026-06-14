class SponsorProfile {
  const SponsorProfile({
    required this.name,
    required this.country,
    required this.sponsoredSince,
    required this.lettersExchanged,
    required this.giftsReceived,
    required this.message,
  });

  final String name;
  final String country;
  final String sponsoredSince;
  final int lettersExchanged;
  final int giftsReceived;
  final String message;
}

class SponsorLetter {
  const SponsorLetter({
    required this.id,
    required this.date,
    required this.body,
    required this.isNew,
  });

  final String id;
  final DateTime date;
  final String body;
  final bool isNew;
}
