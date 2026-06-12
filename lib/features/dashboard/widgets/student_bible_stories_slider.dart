import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/dashboard/data/bible_stories_data.dart';
import 'package:kitoapp/features/dashboard/models/bible_story.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

class StudentBibleStoriesSlider extends StatefulWidget {
  const StudentBibleStoriesSlider({super.key});

  @override
  State<StudentBibleStoriesSlider> createState() =>
      _StudentBibleStoriesSliderState();
}

class _StudentBibleStoriesSliderState extends State<StudentBibleStoriesSlider> {
  final _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stories = BibleStoriesData.stories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_stories_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bibleStories,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.swipeBibleStories,
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: stories.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final story = stories[index];
              final isActive = index == _currentPage;
              return AnimatedScale(
                scale: isActive ? 1.0 : 0.94,
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _StorySlide(
                    story: story,
                    title: _storyTitle(story.id, l10n),
                    summary: _storySummary(story.id, l10n),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(stories.length, (index) {
            final active = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _storyTitle(String id, AppLocalizations l10n) {
    return switch (id) {
      'david_goliath' => l10n.storyDavidTitle,
      'moses_red_sea' => l10n.storyMosesTitle,
      'jonah' => l10n.storyJonahTitle,
      'daniel' => l10n.storyDanielTitle,
      'good_samaritan' => l10n.storySamaritanTitle,
      'jesus_calms_storm' => l10n.storyJesusStormTitle,
      _ => '',
    };
  }

  String _storySummary(String id, AppLocalizations l10n) {
    return switch (id) {
      'david_goliath' => l10n.storyDavidSummary,
      'moses_red_sea' => l10n.storyMosesSummary,
      'jonah' => l10n.storyJonahSummary,
      'daniel' => l10n.storyDanielSummary,
      'good_samaritan' => l10n.storySamaritanSummary,
      'jesus_calms_storm' => l10n.storyJesusStormSummary,
      _ => '',
    };
  }
}

class _StorySlide extends StatelessWidget {
  const _StorySlide({
    required this.story,
    required this.title,
    required this.summary,
  });

  final BibleStory story;
  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            story.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.primary.withValues(alpha: 0.15),
              child: const Icon(
                Icons.menu_book_outlined,
                color: AppColors.primary,
                size: 48,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context).bibleStory,
                    style: TextStyle(
                      color: AppColors.background.withValues(alpha: 0.95),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.background.withValues(alpha: 0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
