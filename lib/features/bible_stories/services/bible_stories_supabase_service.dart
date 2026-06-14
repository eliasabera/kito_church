import 'package:image_picker/image_picker.dart';
import 'package:kitoapp/core/config/cloudinary_config.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/bible_stories/models/bible_story.dart';
import 'package:kitoapp/features/bible_verse/services/cloudinary_image_service.dart';

class BibleStoriesSupabaseService {
  BibleStoriesSupabaseService._();

  static const _table = 'bible_stories';

  static BibleStory storyFromRow(Map<String, dynamic> row) {
    return BibleStory(
      id: row['id'] as String,
      title: row['title'] as String,
      summary: row['summary'] as String? ?? '',
      imageUrl: (row['image_url'] as String?) ?? BibleStory.defaultImageUrl,
      localImagePath: row['image_path'] as String?,
      published: row['published'] as bool? ?? true,
    );
  }

  static Future<List<BibleStory>> fetchAllStories() async {
    final rows = await SupabaseAuthService.client
        .from(_table)
        .select()
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => storyFromRow(Map<String, dynamic>.from(row as Map)))
        .toList();
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
      return CloudinaryImageService.uploadFromXFile(
        pickedImage,
        folder: CloudinaryConfig.bibleStoriesFolder,
      );
    }

    if (localImagePath != null && localImagePath.isNotEmpty) {
      return CloudinaryImageService.uploadFromPath(
        localImagePath,
        folder: CloudinaryConfig.bibleStoriesFolder,
      );
    }

    return imageUrl;
  }

  static Future<BibleStory> addStory({
    required String title,
    required String summary,
    String? localImagePath,
    XFile? pickedImage,
    String? imageUrl,
    bool published = true,
  }) async {
    final uploadedImageUrl = await _resolveImageUrl(
      localImagePath: localImagePath,
      pickedImage: pickedImage,
      imageUrl: imageUrl,
    );

    final row = await SupabaseAuthService.client
        .from(_table)
        .insert({
          'title': title.trim(),
          'summary': summary.trim(),
          'image_url': uploadedImageUrl ?? BibleStory.defaultImageUrl,
          'image_path': null,
          'published': published,
        })
        .select()
        .single();

    return storyFromRow(Map<String, dynamic>.from(row));
  }

  static Future<BibleStory> updateStory({
    required String id,
    required String title,
    required String summary,
    String? localImagePath,
    XFile? pickedImage,
    String? imageUrl,
    bool? published,
  }) async {
    final uploadedImageUrl = await _resolveImageUrl(
      localImagePath: localImagePath,
      pickedImage: pickedImage,
      imageUrl: imageUrl,
    );

    final updates = <String, dynamic>{
      'title': title.trim(),
      'summary': summary.trim(),
      if (uploadedImageUrl != null) 'image_url': uploadedImageUrl,
      if (published != null) 'published': published,
      'image_path': null,
    };

    final row = await SupabaseAuthService.client
        .from(_table)
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return storyFromRow(Map<String, dynamic>.from(row));
  }

  static Future<BibleStory> togglePublished(String id, bool published) async {
    final row = await SupabaseAuthService.client
        .from(_table)
        .update({'published': published})
        .eq('id', id)
        .select()
        .single();

    return storyFromRow(Map<String, dynamic>.from(row));
  }

  static Future<void> deleteStory(String id) async {
    await SupabaseAuthService.client.from(_table).delete().eq('id', id);
  }
}
