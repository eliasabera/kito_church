import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitoapp/core/config/cloudinary_config.dart';
import 'package:kitoapp/features/announcements/models/announcement_item.dart';
import 'package:kitoapp/features/announcements/services/announcement_document_storage.dart';
import 'package:kitoapp/features/announcements/services/supabase_file_storage_service.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/bible_verse/services/cloudinary_image_service.dart';

class AnnouncementsSupabaseService {
  AnnouncementsSupabaseService._();

  static const _selectColumns =
      'id, category_id, author_id, title, message, published, image_path, document_url, document_name, published_at, created_at, updated_at';

  static Future<List<AnnouncementCategoryItem>> fetchCategories() async {
    final rows = await SupabaseAuthService.client
        .from('announcement_categories')
        .select()
        .order('name');

    return (rows as List)
        .map(
          (row) => AnnouncementCategoryItem(
            id: row['id'] as String,
            name: row['name'] as String,
          ),
        )
        .toList();
  }

  static Future<List<AnnouncementItem>> fetchAnnouncements({
    String? userId,
    bool publishedOnly = true,
  }) async {
    var query =
        SupabaseAuthService.client.from('announcements').select(_selectColumns);

    if (publishedOnly) {
      query = query.eq('published', true);
    }

    final rows = await query.order('published_at', ascending: false);
    final readIds = userId == null
        ? <String>{}
        : await _fetchReadIds(userId);

    final authorNames = await _fetchAuthorNames(
      (rows as List).map((row) => row['author_id']?.toString()).whereType<String>(),
    );

    return (rows as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      return _itemFromRow(
        map,
        isNew: !readIds.contains(map['id'].toString()),
        authorNames: authorNames,
      );
    }).toList();
  }

  static Future<Set<String>> _fetchReadIds(String userId) async {
    final rows = await SupabaseAuthService.client
        .from('announcement_reads')
        .select('announcement_id')
        .eq('user_id', userId);

    return (rows as List)
        .map((row) => row['announcement_id'] as String)
        .toSet();
  }

  static Future<Map<String, String>> _fetchAuthorNames(
    Iterable<String> authorIds,
  ) async {
    final uniqueIds = authorIds.where((id) => id.isNotEmpty).toSet();
    if (uniqueIds.isEmpty) return {};

    final rows = await SupabaseAuthService.client
        .from('users')
        .select('id, full_name')
        .inFilter('id', uniqueIds.toList());

    final names = <String, String>{};
    for (final row in rows as List) {
      final map = Map<String, dynamic>.from(row as Map);
      final id = map['id']?.toString();
      final name = map['full_name']?.toString();
      if (id != null && name != null && name.isNotEmpty) {
        names[id] = name;
      }
    }
    return names;
  }

  static Future<void> markAsRead({
    required String announcementId,
    required String userId,
  }) async {
    await SupabaseAuthService.client.from('announcement_reads').upsert(
      {
        'announcement_id': announcementId,
        'user_id': userId,
        'read_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'announcement_id,user_id',
    );
  }

  static Future<AnnouncementCategoryItem> addCategory(String name) async {
    final row = await SupabaseAuthService.client
        .from('announcement_categories')
        .insert({'name': name.trim()})
        .select()
        .single();

    return AnnouncementCategoryItem(
      id: row['id'] as String,
      name: row['name'] as String,
    );
  }

  static Future<void> deleteCategory(String id) async {
    await SupabaseAuthService.client
        .from('announcement_categories')
        .delete()
        .eq('id', id);
  }

  static Future<AnnouncementItem> addAnnouncement({
    required String title,
    required String message,
    required String categoryId,
    required String authorId,
    String? authorName,
    String? localImagePath,
    XFile? pickedImage,
    PickedAnnouncementDocument? pickedDocument,
  }) async {
    final imagePath = await _resolveImagePath(
      localImagePath: localImagePath,
      pickedImage: pickedImage,
    );
    final document = await _resolveDocument(pickedDocument);

    final row = await SupabaseAuthService.client
        .from('announcements')
        .insert({
          'category_id': categoryId,
          'author_id': authorId,
          'title': title.trim(),
          'message': message.trim(),
          'published': true,
          'image_path': imagePath,
          if (document != null) ...{
            'document_url': document.url,
            'document_name': document.name,
          },
          'published_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select(_selectColumns)
        .single();

    final map = Map<String, dynamic>.from(row as Map);
    return _itemFromRow(
      map,
      isNew: true,
      authorOverride: authorName,
    );
  }

  static Future<AnnouncementItem> updateAnnouncement({
    required String id,
    required String title,
    required String message,
    required String categoryId,
    String? authorName,
    String? existingImagePath,
    String? localImagePath,
    XFile? pickedImage,
    bool removeImage = false,
    String? existingDocumentUrl,
    String? existingDocumentName,
    PickedAnnouncementDocument? pickedDocument,
    bool removeDocument = false,
  }) async {
    final imagePath = removeImage
        ? null
        : await _resolveImagePath(
            localImagePath: localImagePath,
            pickedImage: pickedImage,
            existingImagePath: existingImagePath,
          );

    String? documentUrl;
    String? documentName;
    if (removeDocument) {
      documentUrl = null;
      documentName = null;
    } else if (pickedDocument != null) {
      final document = await _resolveDocument(pickedDocument);
      documentUrl = document?.url;
      documentName = document?.name;
    } else {
      documentUrl = existingDocumentUrl;
      documentName = existingDocumentName;
    }

    final row = await SupabaseAuthService.client
        .from('announcements')
        .update({
          'category_id': categoryId,
          'title': title.trim(),
          'message': message.trim(),
          'image_path': imagePath,
          'document_url': documentUrl,
          'document_name': documentName,
        })
        .eq('id', id)
        .select(_selectColumns)
        .single();

    final map = Map<String, dynamic>.from(row as Map);
    return _itemFromRow(
      map,
      isNew: false,
      authorOverride: authorName,
    );
  }

  static Future<void> deleteAnnouncement(String id) async {
    await SupabaseAuthService.client.from('announcements').delete().eq('id', id);
  }

  static Future<String?> _resolveImagePath({
    String? localImagePath,
    XFile? pickedImage,
    String? existingImagePath,
  }) async {
    if (pickedImage != null) {
      final uploaded = await CloudinaryImageService.uploadFromXFile(
        pickedImage,
        folder: CloudinaryConfig.announcementsFolder,
      );
      if (uploaded == null || uploaded.isEmpty) {
        throw StateError('Failed to upload announcement image to Cloudinary');
      }
      return uploaded;
    }

    if (localImagePath != null &&
        localImagePath.isNotEmpty &&
        localImagePath.startsWith('http')) {
      return localImagePath;
    }

    if (localImagePath != null && localImagePath.isNotEmpty) {
      final uploaded = await CloudinaryImageService.uploadFromPath(
        localImagePath,
        folder: CloudinaryConfig.announcementsFolder,
      );
      if (uploaded == null || uploaded.isEmpty) {
        throw StateError('Failed to upload announcement image to Cloudinary');
      }
      return uploaded;
    }

    if (existingImagePath != null && existingImagePath.isNotEmpty) {
      return existingImagePath;
    }

    return null;
  }

  static Future<({String url, String name})?> _resolveDocument(
    PickedAnnouncementDocument? pickedDocument,
  ) async {
    if (pickedDocument == null) return null;

    final bytes = await _readDocumentBytes(pickedDocument);
    final uploaded = await SupabaseFileStorageService.uploadFromBytes(
      bytes,
      pickedDocument.name,
    );

    return (url: uploaded, name: pickedDocument.name);
  }

  static Future<Uint8List> _readDocumentBytes(
    PickedAnnouncementDocument document,
  ) async {
    if (document.bytes != null && document.bytes!.isNotEmpty) {
      return document.bytes!;
    }

    if (!kIsWeb && document.path.isNotEmpty) {
      final file = File(document.path);
      if (await file.exists()) {
        return file.readAsBytes();
      }
    }

    throw StateError('Could not read the selected document');
  }

  static AnnouncementItem _itemFromRow(
    Map<String, dynamic> map, {
    required bool isNew,
    String? authorOverride,
    Map<String, String>? authorNames,
  }) {
    final authorId = map['author_id']?.toString();
    String? authorFromMap;
    if (authorId != null && authorNames != null) {
      authorFromMap = authorNames[authorId];
    }
    final resolvedAuthor = authorOverride ?? authorFromMap ?? 'Admin';

    return AnnouncementItem(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      date: DateTime.parse(map['published_at'].toString()).toLocal(),
      author: resolvedAuthor,
      categoryId: map['category_id']?.toString() ?? '',
      published: map['published'] as bool? ?? true,
      isNew: isNew,
      localImagePath: map['image_path']?.toString(),
      documentUrl: map['document_url']?.toString(),
      documentName: map['document_name']?.toString(),
    );
  }
}
