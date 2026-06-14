import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitoapp/features/bible_stories/models/bible_story.dart';
import 'package:kitoapp/features/bible_stories/services/bible_stories_supabase_service.dart';

class BibleStoriesStore extends ChangeNotifier {
  BibleStoriesStore();

  final List<BibleStory> _stories = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<BibleStory> get allStories => List.unmodifiable(_stories);

  List<BibleStory> get publishedStories {
    return _stories.where((story) => story.published).toList();
  }

  BibleStoriesSummary get summary {
    return BibleStoriesSummary(
      total: _stories.length,
      published: _stories.where((story) => story.published).length,
      withCustomImage: _stories
          .where(
            (story) => story.hasRemoteImage || story.hasLocalImage,
          )
          .length,
    );
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remoteStories = await BibleStoriesSupabaseService.fetchAllStories();
      _stories
        ..clear()
        ..addAll(remoteStories);
    } catch (error, stackTrace) {
      debugPrint('BibleStoriesStore.load failed: $error\n$stackTrace');
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<BibleStory> filteredStories({String query = ''}) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return allStories;
    return _stories
        .where(
          (story) =>
              story.title.toLowerCase().contains(normalizedQuery) ||
              story.summary.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  Future<bool> addStory({
    required String title,
    required String summary,
    String? localImagePath,
    XFile? pickedImage,
    String? imageUrl,
  }) async {
    try {
      final saved = await BibleStoriesSupabaseService.addStory(
        title: title,
        summary: summary,
        localImagePath: localImagePath,
        pickedImage: pickedImage,
        imageUrl: imageUrl,
      );
      _stories.insert(0, saved);
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('BibleStoriesStore.addStory failed: $error\n$stackTrace');
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStory({
    required String id,
    required String title,
    required String summary,
    String? localImagePath,
    XFile? pickedImage,
    String? imageUrl,
    bool? published,
  }) async {
    try {
      final saved = await BibleStoriesSupabaseService.updateStory(
        id: id,
        title: title,
        summary: summary,
        localImagePath: localImagePath,
        pickedImage: pickedImage,
        imageUrl: imageUrl,
        published: published,
      );
      final index = _stories.indexWhere((story) => story.id == id);
      if (index == -1) {
        _stories.insert(0, saved);
      } else {
        _stories[index] = saved;
      }
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('BibleStoriesStore.updateStory failed: $error\n$stackTrace');
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> togglePublished(String id) async {
    final index = _stories.indexWhere((story) => story.id == id);
    if (index == -1) return false;

    final nextPublished = !_stories[index].published;
    try {
      final saved = await BibleStoriesSupabaseService.togglePublished(
        id,
        nextPublished,
      );
      _stories[index] = saved;
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      debugPrint('BibleStoriesStore.togglePublished failed: $error\n$stackTrace');
      _error = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStory(String id) async {
    _stories.removeWhere((story) => story.id == id);
    notifyListeners();

    try {
      await BibleStoriesSupabaseService.deleteStory(id);
      return true;
    } catch (error, stackTrace) {
      debugPrint('BibleStoriesStore.deleteStory failed: $error\n$stackTrace');
      _error = error.toString();
      await load();
      return false;
    }
  }
}
