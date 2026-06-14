class BibleStory {
  const BibleStory({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    this.localImagePath,
    this.published = true,
  });

  static const defaultImageUrl =
      'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?w=900&q=80';

  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final String? localImagePath;
  final bool published;

  bool get hasLocalImage =>
      localImagePath != null && localImagePath!.trim().isNotEmpty;

  bool get hasRemoteImage =>
      imageUrl.isNotEmpty &&
      imageUrl.startsWith('http') &&
      imageUrl != defaultImageUrl;

  BibleStory copyWith({
    String? id,
    String? title,
    String? summary,
    String? imageUrl,
    String? localImagePath,
    bool? published,
  }) {
    return BibleStory(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      published: published ?? this.published,
    );
  }
}

class BibleStoriesSummary {
  const BibleStoriesSummary({
    required this.total,
    required this.published,
    required this.withCustomImage,
  });

  final int total;
  final int published;
  final int withCustomImage;
}
