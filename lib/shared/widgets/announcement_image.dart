import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/announcements/models/announcement_item.dart';
import 'package:kitoapp/features/bible_verse/services/cloudinary_image_service.dart';

class AnnouncementImage extends StatelessWidget {
  const AnnouncementImage({
    super.key,
    required this.item,
    this.height = 160,
    this.borderRadius = 12,
  });

  final AnnouncementItem item;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (!item.hasImage) return const SizedBox.shrink();

    final path = item.localImagePath!;
    final isRemote = path.startsWith('http');

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: isRemote
            ? Image.network(
                CloudinaryImageService.displayUrl(path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _Fallback(),
              )
            : kIsWeb
                ? Image.network(path, fit: BoxFit.cover)
                : Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _Fallback(),
                  ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.primary.withValues(alpha: 0.35),
          size: 40,
        ),
      ),
    );
  }
}
