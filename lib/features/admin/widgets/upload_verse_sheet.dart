import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/bible_verse/services/verse_image_storage.dart';
import 'package:kitoapp/features/bible_verse/services/daily_verse_store.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/models/bible_verse.dart';
import 'package:kitoapp/shared/widgets/verse_image.dart';

void showUploadVerseSheet(
  BuildContext context, {
  required DailyVerseStore store,
}) {
  showAddEditVerseSheet(context, store: store);
}

void showAddEditVerseSheet(
  BuildContext context, {
  required DailyVerseStore store,
  BibleVerse? existing,
}) {
  final messenger = ScaffoldMessenger.of(context);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: false,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _UploadVerseSheet(
      store: store,
      existing: existing,
      onClose: () {
        if (Navigator.of(sheetContext).canPop()) {
          Navigator.of(sheetContext).pop();
        }
      },
      onSuccess: (message) async {
        if (Navigator.of(sheetContext).canPop()) {
          Navigator.of(sheetContext).pop();
        }
        await store.load();
        messenger.showSnackBar(SnackBar(content: Text(message)));
      },
    ),
  );
}

class _UploadVerseSheet extends StatefulWidget {
  const _UploadVerseSheet({
    required this.store,
    required this.onClose,
    required this.onSuccess,
    this.existing,
  });

  final DailyVerseStore store;
  final VoidCallback onClose;
  final void Function(String message) onSuccess;
  final BibleVerse? existing;

  @override
  State<_UploadVerseSheet> createState() => _UploadVerseSheetState();
}

class _UploadVerseSheetState extends State<_UploadVerseSheet> {
  final _textController = TextEditingController();
  final _referenceController = TextEditingController();
  final _imageStorage = VerseImageStorage();

  DateTime? _scheduledDate;
  String? _localImagePath;
  String? _existingImageUrl;
  XFile? _pickedImage;
  bool _pickingImage = false;
  bool _submitting = false;
  bool _imageRemoved = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final verse = widget.existing;
    if (verse != null) {
      _textController.text = verse.text;
      _referenceController.text = verse.reference;
      _scheduledDate = verse.scheduledDate;
      if (verse.hasRemoteImage) {
        _existingImageUrl = verse.imageUrl;
      }
    } else {
      final now = DateTime.now();
      _scheduledDate = DateTime(now.year, now.month, now.day);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDate: _scheduledDate ?? DateTime.now(),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              onSurface: AppColors.text,
            ),
          ),
          child: child,
        );
      },
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _pickImage() async {
    setState(() => _pickingImage = true);
    try {
      final picked = await _imageStorage.pickFromGallery();
      if (picked == null) return;
      final savedPath = await _imageStorage.persistImage(picked);
      if (!mounted) return;
      setState(() {
        _pickedImage = picked;
        _localImagePath = savedPath ?? picked.path;
        _existingImageUrl = null;
        _imageRemoved = false;
      });
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  void _removeImage() {
    setState(() {
      _pickedImage = null;
      _localImagePath = null;
      _existingImageUrl = null;
      _imageRemoved = true;
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final text = _textController.text.trim();
    final reference = _referenceController.text.trim();

    if (text.isEmpty || reference.isEmpty || _scheduledDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.verseFormRequired)),
      );
      return;
    }

    setState(() => _submitting = true);
    final store = widget.store;
    final success = _isEditing
        ? await store.updateVerse(
            id: widget.existing!.id,
            text: text,
            reference: reference,
            scheduledDate: _scheduledDate!,
            localImagePath: _localImagePath,
            pickedImage: _pickedImage,
            imageUrl: _existingImageUrl,
            removeImage: _imageRemoved &&
                _pickedImage == null &&
                _localImagePath == null,
          )
        : await store.addVerse(
            text: text,
            reference: reference,
            scheduledDate: _scheduledDate!,
            localImagePath: _localImagePath,
            pickedImage: _pickedImage,
          );

    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      widget.onSuccess(
        _isEditing ? 'Verse updated successfully' : l10n.verseUploaded,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reportGenerateFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final dateLabel = _scheduledDate == null
        ? l10n.scheduleDate
        : DateFormat.yMMMd(locale).format(_scheduledDate!);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit Verse' : l10n.uploadVerse,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ImagePickerSection(
                      localImagePath: _localImagePath,
                      remoteImageUrl: _existingImageUrl,
                      pickedImage: _pickedImage,
                      isLoading: _pickingImage,
                      onPick: _pickImage,
                      onRemove: _removeImage,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _textController,
                      maxLines: 5,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: l10n.verseText,
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 72),
                          child: Icon(
                            Icons.format_quote,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _referenceController,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: l10n.verseReference,
                        prefixIcon: const Icon(
                          Icons.bookmark_outline,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.scheduleDate,
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.primary,
                          ),
                          suffixIcon: const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.primary,
                          ),
                        ),
                        child: Text(
                          dateLabel,
                          style: TextStyle(
                            color: _scheduledDate == null
                                ? AppColors.text.withValues(alpha: 0.5)
                                : AppColors.text,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.background,
                              ),
                            )
                          : Text(_isEditing ? l10n.save : l10n.uploadVerse),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerSection extends StatelessWidget {
  const _ImagePickerSection({
    required this.localImagePath,
    required this.remoteImageUrl,
    required this.pickedImage,
    required this.isLoading,
    required this.onPick,
    required this.onRemove,
  });

  final String? localImagePath;
  final String? remoteImageUrl;
  final XFile? pickedImage;
  final bool isLoading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasLocalImage =
        localImagePath != null && localImagePath!.isNotEmpty;
    final hasRemoteImage =
        remoteImageUrl != null && remoteImageUrl!.isNotEmpty;
    final hasImage = hasLocalImage || hasRemoteImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.attachVerseImage,
          style: TextStyle(
            color: AppColors.text.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.attachVerseImageHint,
          style: TextStyle(
            color: AppColors.text.withValues(alpha: 0.45),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasLocalImage)
                      _PreviewImage(path: localImagePath!, picked: pickedImage)
                    else
                      Image.network(
                        remoteImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const VerseImageFallback(),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.85),
                          foregroundColor: AppColors.background,
                          minimumSize: const Size(36, 36),
                        ),
                        onPressed: onRemove,
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: isLoading ? null : onPick,
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.primary,
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 36,
                                color: AppColors.primary.withValues(alpha: 0.7),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.attachVerseImage,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
        ),
        if (hasImage) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: isLoading ? null : onPick,
            icon: const Icon(Icons.image_outlined, size: 18),
            label: Text(l10n.changeVerseImage),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage({required this.path, this.picked});

  final String path;
  final XFile? picked;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(path, fit: BoxFit.cover);
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const VerseImageFallback(),
    );
  }
}
