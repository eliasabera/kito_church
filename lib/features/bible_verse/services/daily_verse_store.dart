import 'package:flutter/foundation.dart';
import 'package:kitoapp/features/bible_verse/data/daily_verse_data.dart';
import 'package:kitoapp/shared/models/bible_verse.dart';

class DailyVerseSummary {
  const DailyVerseSummary({
    required this.totalPosted,
    required this.daysWithVerses,
  });

  final int totalPosted;
  final int daysWithVerses;
}

class DailyVerseStore extends ChangeNotifier {
  DailyVerseStore() : _verses = List.of(DailyVerseData.verses);

  final List<BibleVerse> _verses;

  List<BibleVerse> get allVerses {
    final copy = List<BibleVerse>.from(_verses);
    copy.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    return List.unmodifiable(copy);
  }

  BibleVerse? get todayVerse {
    final now = DateTime.now();
    for (final verse in allVerses) {
      if (_isSameDay(verse.scheduledDate, now)) return verse;
    }
    for (final verse in allVerses) {
      if (!verse.scheduledDate.isAfter(now)) return verse;
    }
    return allVerses.isEmpty ? null : allVerses.last;
  }

  List<BibleVerse> get previousVerses {
    final today = todayVerse;
    if (today == null) return allVerses;
    return allVerses.where((verse) => verse.id != today.id).toList();
  }

  DailyVerseSummary get summary {
    final dates = allVerses.map((v) => _dateKey(v.scheduledDate)).toSet();
    return DailyVerseSummary(
      totalPosted: allVerses.length,
      daysWithVerses: dates.length,
    );
  }

  BibleVerse? verseById(String id) {
    for (final verse in _verses) {
      if (verse.id == id) return verse;
    }
    return null;
  }

  bool isToday(BibleVerse verse) {
    final today = todayVerse;
    return today != null && today.id == verse.id;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';
}
