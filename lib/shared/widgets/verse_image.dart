import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/bible_verse/services/cloudinary_image_service.dart';
import 'package:kitoapp/shared/models/bible_verse.dart';

class VerseImage extends StatelessWidget {
  const VerseImage({
    super.key,
    required this.verse,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  final BibleVerse verse;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (verse.hasRemoteImage && verse.imageUrl != null) {
      return _buildNetwork(verse.imageUrl);
    }

    if (verse.hasUploadedImage && verse.localImagePath != null) {
      final localPath = verse.localImagePath!;
      if (kIsWeb) {
        return Image.network(
          localPath,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildNetwork(null),
        );
      }

      final file = File(localPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildNetwork(null),
        );
      }
    }

    return _buildNetwork(null);
  }

  Widget _buildNetwork(String? url) {
    final resolvedUrl = url != null && url.isNotEmpty
        ? CloudinaryImageService.displayUrl(url)
        : verse.networkImageUrl;

    return Image.network(
      resolvedUrl,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          fallback ?? const VerseImageFallback(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return fallback ?? const VerseImageFallback();
      },
    );
  }
}

class VerseImageFallback extends StatelessWidget {
  const VerseImageFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF003D6B)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_outlined,
          size: 56,
          color: AppColors.background.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
