import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/bible_stories/models/bible_story.dart';
import 'package:kitoapp/features/bible_stories/services/bible_story_image_storage.dart';
import 'package:kitoapp/features/bible_verse/services/cloudinary_image_service.dart';
import 'package:kitoapp/l10n/app_localizations.dart';

Future<void> showAddEditBibleStorySheet(
  BuildContext context, {
  BibleStory? existing,
  required Future<bool> Function({
    required String title,
    required String summary,
    String? localImagePath,
    XFile? pickedImage,
    String? imageUrl,
  }) onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _AddEditBibleStorySheet(
      existing: existing,
      onSave: onSave,
    ),
  );
}

class _AddEditBibleStorySheet extends StatefulWidget {
  const _AddEditBibleStorySheet({
    required this.existing,
    required this.onSave,
  });

  final BibleStory? existing;
  final Future<bool> Function({
    required String title,
    required String summary,
    String? localImagePath,
    XFile? pickedImage,
    String? imageUrl,
  }) onSave;

  @override
  State<_AddEditBibleStorySheet> createState() =>
      _AddEditBibleStorySheetState();
}

class _AddEditBibleStorySheetState extends State<_AddEditBibleStorySheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _imageUrlController;
  final _imageStorage = BibleStoryImageStorage();
  String? _localImagePath;
  String? _existingImageUrl;
  XFile? _pickedImage;
  bool _pickingImage = false;
  bool _submitting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _summaryController =
        TextEditingController(text: widget.existing?.summary ?? '');
    _imageUrlController = TextEditingController(
      text: widget.existing?.hasRemoteImage == true
          ? widget.existing!.imageUrl
          : '',
    );
    if (widget.existing?.hasRemoteImage == true) {
      _existingImageUrl = widget.existing!.imageUrl;
    } else {
      _localImagePath = widget.existing?.localImagePath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _pickingImage = true);
    try {
      final file = await _imageStorage.pickFromGallery();
      if (file == null || !mounted) return;
      final savedPath = await _imageStorage.persistImage(file);
      if (!mounted) return;
      setState(() {
        _pickedImage = file;
        _localImagePath = savedPath ?? file.path;
        _existingImageUrl = null;
      });
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final summary = _summaryController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    if (title.isEmpty || summary.isEmpty) return;

    setState(() => _submitting = true);
    final success = await widget.onSave(
      title: title,
      summary: summary,
      localImagePath: _localImagePath,
      pickedImage: _pickedImage,
      imageUrl: _existingImageUrl ??
          (imageUrl.isEmpty ? null : imageUrl),
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasPreview = (_localImagePath != null && _localImagePath!.isNotEmpty) ||
        (_existingImageUrl != null && _existingImageUrl!.isNotEmpty);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.text.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEditing ? l10n.editBibleStory : l10n.addBibleStory,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.bibleStoryFormHint,
                style: TextStyle(
                  color: AppColors.text.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.storyTitle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _summaryController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.storySummary,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: l10n.imageUrlOptional,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.attachStoryImage,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              if (hasPreview)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 140,
                    child: _localImagePath != null && _localImagePath!.isNotEmpty
                        ? (kIsWeb
                            ? Image.network(_localImagePath!, fit: BoxFit.cover)
                            : Image.file(
                                File(_localImagePath!),
                                fit: BoxFit.cover,
                              ))
                        : Image.network(
                            CloudinaryImageService.displayUrl(
                              _existingImageUrl!,
                            ),
                            fit: BoxFit.cover,
                          ),
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickingImage ? null : _pickImage,
                  icon: _pickingImage
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.image_outlined),
                  label: Text(l10n.attachStoryImage),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submitting ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
