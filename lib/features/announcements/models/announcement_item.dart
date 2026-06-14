class AnnouncementCategoryItem {
  const AnnouncementCategoryItem({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  AnnouncementCategoryItem copyWith({String? id, String? name}) {
    return AnnouncementCategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

class AnnouncementItem {
  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.author,
    required this.categoryId,
    this.isNew = false,
    this.published = true,
    this.localImagePath,
    this.documentUrl,
    this.documentName,
  });

  final String id;
  final String title;
  final String message;
  final DateTime date;
  final String author;
  final String categoryId;
  final bool isNew;
  final bool published;
  final String? localImagePath;
  final String? documentUrl;
  final String? documentName;

  bool get hasImage =>
      localImagePath != null && localImagePath!.trim().isNotEmpty;

  bool get hasDocument =>
      documentUrl != null && documentUrl!.trim().isNotEmpty;

  AnnouncementItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? date,
    String? author,
    String? categoryId,
    bool? isNew,
    bool? published,
    String? localImagePath,
    String? documentUrl,
    String? documentName,
  }) {
    return AnnouncementItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      author: author ?? this.author,
      categoryId: categoryId ?? this.categoryId,
      isNew: isNew ?? this.isNew,
      published: published ?? this.published,
      localImagePath: localImagePath ?? this.localImagePath,
      documentUrl: documentUrl ?? this.documentUrl,
      documentName: documentName ?? this.documentName,
    );
  }
}

class AnnouncementSummary {
  const AnnouncementSummary({
    required this.total,
    required this.unread,
    required this.thisWeek,
  });

  final int total;
  final int unread;
  final int thisWeek;
}

class AdminAnnouncementSummary {
  const AdminAnnouncementSummary({
    required this.total,
    required this.published,
    required this.thisWeek,
    required this.withImage,
    required this.withDocument,
    required this.categories,
  });

  final int total;
  final int published;
  final int thisWeek;
  final int withImage;
  final int withDocument;
  final int categories;
}
