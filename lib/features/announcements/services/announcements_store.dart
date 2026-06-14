import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitoapp/features/announcements/models/announcement_item.dart';
import 'package:kitoapp/features/announcements/services/announcement_document_storage.dart';
import 'package:kitoapp/features/announcements/services/announcements_supabase_service.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum CategoryDeleteResult {
  success,
  lastCategory,
  inUse,
  failed,
}

class AnnouncementsStore extends ChangeNotifier {
  final List<AnnouncementCategoryItem> _categories = [];
  final List<AnnouncementItem> _items = [];
  final Set<String> _readIds = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AnnouncementCategoryItem> get categories =>
      List.unmodifiable(_categories);

  List<AnnouncementItem> get allItems => List.unmodifiable(_items);

  AnnouncementCategoryItem? categoryById(String id) {
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  String categoryNameFor(String categoryId) {
    return categoryById(categoryId)?.name ?? categoryId;
  }

  List<AnnouncementItem> get publishedItems {
    return _items
        .where((item) => item.published)
        .map(_withReadState)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<AnnouncementItem> publishedItemsFor({String? categoryId}) {
    if (categoryId == null) return publishedItems;
    return publishedItems
        .where((item) => item.categoryId == categoryId)
        .toList();
  }

  List<AnnouncementItem> get recentPublished {
    return publishedItems.take(3).toList();
  }

  AnnouncementSummary get studentSummary {
    final items = publishedItems;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return AnnouncementSummary(
      total: items.length,
      unread: items.where((item) => item.isNew).length,
      thisWeek: items.where((item) => item.date.isAfter(weekAgo)).length,
    );
  }

  AdminAnnouncementSummary get adminSummary {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return AdminAnnouncementSummary(
      total: _items.length,
      published: _items.where((item) => item.published).length,
      thisWeek: _items.where((item) => item.date.isAfter(weekAgo)).length,
      withImage: _items.where((item) => item.hasImage).length,
      withDocument: _items.where((item) => item.hasDocument).length,
      categories: _categories.length,
    );
  }

  Future<void> loadFromSupabase({bool publishedOnly = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final categories = await AnnouncementsSupabaseService.fetchCategories();
      final items = await AnnouncementsSupabaseService.fetchAnnouncements(
        userId: AuthSession.userId,
        publishedOnly: publishedOnly,
      );

      _categories
        ..clear()
        ..addAll(categories);
      _items
        ..clear()
        ..addAll(items);
      _readIds
        ..clear()
        ..addAll(items.where((item) => !item.isNew).map((item) => item.id));
    } catch (error, stackTrace) {
      debugPrint('AnnouncementsStore.loadFromSupabase failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AnnouncementItem> adminItemsFor({
    String? categoryId,
    String query = '',
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    return _items.where((item) {
      if (categoryId != null && item.categoryId != categoryId) return false;
      if (normalizedQuery.isEmpty) return true;
      final categoryName = categoryNameFor(item.categoryId).toLowerCase();
      return item.title.toLowerCase().contains(normalizedQuery) ||
          item.message.toLowerCase().contains(normalizedQuery) ||
          item.author.toLowerCase().contains(normalizedQuery) ||
          categoryName.contains(normalizedQuery);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<AnnouncementCategoryItem> addCategory(String name) async {
    final trimmed = name.trim();
    final existing = _categories.where(
      (category) => category.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (existing.isNotEmpty) return existing.first;

    final category = await AnnouncementsSupabaseService.addCategory(trimmed);
    _categories.add(category);
    notifyListeners();
    return category;
  }

  Future<CategoryDeleteResult> deleteCategory(String id) async {
    if (_categories.length <= 1) {
      return CategoryDeleteResult.lastCategory;
    }
    if (_items.any((item) => item.categoryId == id)) {
      return CategoryDeleteResult.inUse;
    }

    try {
      await AnnouncementsSupabaseService.deleteCategory(id);
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
      return CategoryDeleteResult.success;
    } catch (error, stackTrace) {
      debugPrint('AnnouncementsStore.deleteCategory failed: $error\n$stackTrace');
      _error = _formatError(error);
      notifyListeners();
      return CategoryDeleteResult.failed;
    }
  }

  Future<bool> addAnnouncement({
    required String title,
    required String message,
    required String categoryId,
    required String author,
    String? localImagePath,
    XFile? pickedImage,
    PickedAnnouncementDocument? pickedDocument,
  }) async {
    final authorId = AuthSession.userId;
    if (authorId == null) {
      throw StateError('You must be signed in to publish an announcement');
    }

    try {
      _error = null;
      notifyListeners();

      final item = await AnnouncementsSupabaseService.addAnnouncement(
        title: title,
        message: message,
        categoryId: categoryId,
        authorId: authorId,
        authorName: author,
        localImagePath: localImagePath,
        pickedImage: pickedImage,
        pickedDocument: pickedDocument,
      );

      _items.insert(0, item);
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('AnnouncementsStore.addAnnouncement failed: $error\n$stackTrace');
      _error = _formatError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAnnouncement({
    required String id,
    required String title,
    required String message,
    required String categoryId,
    required String author,
    String? existingImagePath,
    String? localImagePath,
    XFile? pickedImage,
    bool removeImage = false,
    String? existingDocumentUrl,
    String? existingDocumentName,
    PickedAnnouncementDocument? pickedDocument,
    bool removeDocument = false,
  }) async {
    try {
      _error = null;
      notifyListeners();

      final item = await AnnouncementsSupabaseService.updateAnnouncement(
        id: id,
        title: title,
        message: message,
        categoryId: categoryId,
        authorName: author,
        existingImagePath: existingImagePath,
        localImagePath: localImagePath,
        pickedImage: pickedImage,
        removeImage: removeImage,
        existingDocumentUrl: existingDocumentUrl,
        existingDocumentName: existingDocumentName,
        pickedDocument: pickedDocument,
        removeDocument: removeDocument,
      );

      final index = _items.indexWhere((entry) => entry.id == id);
      if (index >= 0) {
        _items[index] = item;
      } else {
        _items.insert(0, item);
      }
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint(
        'AnnouncementsStore.updateAnnouncement failed: $error\n$stackTrace',
      );
      _error = _formatError(error);
      notifyListeners();
      return false;
    }
  }

  String _formatError(Object error) {
    if (error is PostgrestException) {
      return error.message;
    }
    if (error is StorageException) {
      return error.message;
    }
    if (error is AuthException) {
      return error.message;
    }
    return error.toString();
  }

  Future<void> deleteAnnouncement(String id) async {
    await AnnouncementsSupabaseService.deleteAnnouncement(id);
    _items.removeWhere((item) => item.id == id);
    _readIds.remove(id);
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final userId = AuthSession.userId;
    if (userId == null) return;

    if (_readIds.add(id)) {
      notifyListeners();
      try {
        await AnnouncementsSupabaseService.markAsRead(
          announcementId: id,
          userId: userId,
        );
      } catch (error, stackTrace) {
        debugPrint('AnnouncementsStore.markAsRead failed: $error\n$stackTrace');
        _readIds.remove(id);
        notifyListeners();
      }
    }
  }

  AnnouncementItem _withReadState(AnnouncementItem item) {
    return item.copyWith(isNew: !_readIds.contains(item.id));
  }
}
