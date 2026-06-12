class BibleVerse {
  const BibleVerse({
    required this.id,
    required this.text,
    required this.reference,
    required this.scheduledDate,
    this.language = 'am',
  });

  final String id;
  final String text;
  final String reference;
  final DateTime scheduledDate;
  final String language;
}
