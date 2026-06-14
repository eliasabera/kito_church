import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/bible_verse/services/cloudinary_image_service.dart';
import 'package:kitoapp/shared/models/bible_verse.dart';

class DailyVerseSupabaseService {
  DailyVerseSupabaseService._();

  static const _table = 'bible_verses';

  static const _selectColumns =
      'id, text, reference, scheduled_date, language, image_url, image_path';

  static BibleVerse verseFromRow(Map<String, dynamic> row) {
    return BibleVerse(
      id: row['id']?.toString() ?? '',
      text: row['text']?.toString() ?? '',
      reference: row['reference']?.toString() ?? '',
      scheduledDate: _parseScheduledDate(row['scheduled_date']),
      language: row['language']?.toString() ?? 'am',
      imageUrl: _optionalString(row['image_url']),
      localImagePath: _optionalString(row['image_path']),
    );
  }

  static Future<List<BibleVerse>> fetchAllVerses() async {
    final rows = await SupabaseAuthService.client
        .from(_table)
        .select(_selectColumns)
        .order('scheduled_date', ascending: false);

    final list = rows as List;
    debugPrint('DailyVerseSupabaseService: received ${list.length} raw rows');

    final verses = <BibleVerse>[];
    for (final row in list) {
      try {
        final map = Map<String, dynamic>.from(row as Map);
        final verse = verseFromRow(map);
        if (verse.text.isEmpty || verse.reference.isEmpty) {
          debugPrint('DailyVerseSupabaseService: skipped incomplete row: $map');
          continue;
        }
        verses.add(verse);
      } catch (error, stackTrace) {
        debugPrint(
          'DailyVerseSupabaseService: failed to parse row $row: $error\n$stackTrace',
        );
      }
    }

    debugPrint('DailyVerseSupabaseService: loaded ${verses.length} verses');
    return verses;
  }

  static Future<BibleVerse> addVerse({
    required String text,
    required String reference,
    required DateTime scheduledDate,
    String language = 'am',
    String? localImagePath,
    XFile? pickedImage,
    String? imageUrl,
  }) async {
    final uploadedImageUrl = await _resolveImageUrl(
      localImagePath: localImagePath,
      pickedImage: pickedImage,
      imageUrl: imageUrl,
    );

    final dateKey = _dateKey(scheduledDate);
    final payload = {
      'text': text.trim(),
      'reference': reference.trim(),
      'scheduled_date': dateKey,
      'language': language,
      'image_url': uploadedImageUrl,
      'image_path': null,
    };

    final row = await SupabaseAuthService.client
        .from(_table)
        .upsert(payload, onConflict: 'scheduled_date')
        .select(_selectColumns)
        .single();

    return verseFromRow(Map<String, dynamic>.from(row));
  }

  static Future<BibleVerse> updateVerse({
    required String id,
    required String text,
    required String reference,
    required DateTime scheduledDate,
    String language = 'am',
    String? localImagePath,
    XFile? pickedImage,
    String? imageUrl,
    bool removeImage = false,
  }) async {
    String? uploadedImageUrl;
    if (removeImage) {
      uploadedImageUrl = null;
    } else {
      uploadedImageUrl = await _resolveImageUrl(
        localImagePath: localImagePath,
        pickedImage: pickedImage,
        imageUrl: imageUrl,
      );
    }

    final updates = <String, dynamic>{
      'text': text.trim(),
      'reference': reference.trim(),
      'scheduled_date': _dateKey(scheduledDate),
      'language': language,
      'image_path': null,
      if (removeImage || uploadedImageUrl != null) 'image_url': uploadedImageUrl,
    };

    final row = await SupabaseAuthService.client
        .from(_table)
        .update(updates)
        .eq('id', id)
        .select(_selectColumns)
        .single();

    return verseFromRow(Map<String, dynamic>.from(row));
  }

  static Future<void> deleteVerse(String id) async {
    await SupabaseAuthService.client.from(_table).delete().eq('id', id);
  }

  static Future<String?> _resolveImageUrl({
    String? localImagePath,
    XFile? pickedImage,
    String? imageUrl,
  }) async {
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        pickedImage == null &&
        (localImagePath == null || localImagePath.isEmpty)) {
      return imageUrl;
    }

    if (pickedImage != null) {
      final uploaded = await CloudinaryImageService.uploadFromXFile(pickedImage);
      if (uploaded == null || uploaded.isEmpty) {
        throw StateError('Failed to upload verse image to Cloudinary');
      }
      return uploaded;
    }

    if (localImagePath != null && localImagePath.isNotEmpty) {
      final uploaded = await CloudinaryImageService.uploadFromPath(localImagePath);
      if (uploaded == null || uploaded.isEmpty) {
        throw StateError('Failed to upload verse image to Cloudinary');
      }
      return uploaded;
    }

    return null;
  }

  static String? _optionalString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime _parseScheduledDate(dynamic raw) {
    if (raw is DateTime) {
      return DateTime(raw.year, raw.month, raw.day);
    }

    final text = raw?.toString().trim() ?? '';
    if (text.isEmpty) {
      return DateTime.now();
    }

    final datePart = text.length >= 10 ? text.substring(0, 10) : text;
    final parts = datePart.split('-');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    final parsed = DateTime.parse(text);
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static String _dateKey(DateTime scheduledDate) =>
      '${scheduledDate.year.toString().padLeft(4, '0')}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}';
}
