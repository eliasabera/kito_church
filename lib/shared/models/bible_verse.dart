class BibleVerse {
  const BibleVerse({
    required this.id,
    required this.text,
    required this.reference,
    required this.scheduledDate,
    this.language = 'am',
    this.imageUrl,
    this.localImagePath,
  });

  static const defaultImageUrl =
      'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=800&q=80';

  final String id;
  final String text;
  final String reference;
  final DateTime scheduledDate;
  final String language;
  final String? imageUrl;
  final String? localImagePath;

  bool get hasRemoteImage =>
      imageUrl != null &&
      imageUrl!.isNotEmpty &&
      imageUrl!.startsWith('http') &&
      imageUrl != defaultImageUrl;

  bool get hasUploadedImage =>
      localImagePath != null && localImagePath!.isNotEmpty;

  String get networkImageUrl => imageUrl ?? defaultImageUrl;
}
