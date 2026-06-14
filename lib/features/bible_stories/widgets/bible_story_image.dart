import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/bible_stories/models/bible_story.dart';
import 'package:kitoapp/features/bible_verse/services/cloudinary_image_service.dart';

class BibleStoryImage extends StatelessWidget {
  const BibleStoryImage({
    super.key,
    required this.story,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  final BibleStory story;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (story.hasRemoteImage) {
      return Image.network(
        CloudinaryImageService.displayUrl(story.imageUrl),
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            fallback ?? const _Fallback(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallback ?? const _Fallback();
        },
      );
    }

    if (story.hasLocalImage && !kIsWeb) {
      return Image.file(
        File(story.localImagePath!),
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildNetwork(),
      );
    }

    return _buildNetwork();
  }

  Widget _buildNetwork() {
    return Image.network(
      story.imageUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          fallback ?? const _Fallback(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return fallback ?? const _Fallback();
      },
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: Center(
        child: Icon(
          Icons.menu_book_outlined,
          color: AppColors.primary.withValues(alpha: 0.35),
          size: 48,
        ),
      ),
    );
  }
}
