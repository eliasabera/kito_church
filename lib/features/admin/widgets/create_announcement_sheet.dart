import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitoapp/core/theme/app_colors.dart';
import 'package:kitoapp/features/announcements/services/announcement_image_storage.dart';
import 'package:kitoapp/features/announcements/services/announcement_document_storage.dart';
import 'package:kitoapp/features/announcements/models/announcement_item.dart';
import 'package:kitoapp/features/announcements/services/announcement_form_validation.dart';
import 'package:kitoapp/features/announcements/services/announcements_store.dart';
import 'package:kitoapp/features/auth/services/auth_session.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:kitoapp/features/profile/services/profile_store.dart';
import 'package:kitoapp/features/bible_verse/services/cloudinary_image_service.dart';
import 'package:kitoapp/l10n/app_localizations.dart';
import 'package:kitoapp/shared/widgets/announcements_store_provider.dart';
import 'package:kitoapp/shared/widgets/app_toast.dart';
import 'package:kitoapp/shared/widgets/profile_store_provider.dart';

Future<void> showCreateAnnouncementSheet(
  BuildContext context, {
  AnnouncementItem? existing,
}) {
  final messenger = ScaffoldMessenger.of(context);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _CreateAnnouncementSheet(
      messenger: messenger,
      existing: existing,
    ),
  );
}

Future<void> showEditAnnouncementSheet(
  BuildContext context, {
  required AnnouncementItem existing,
}) {
  return showCreateAnnouncementSheet(context, existing: existing);
}

class _CreateAnnouncementSheet extends StatefulWidget {
  const _CreateAnnouncementSheet({
    required this.messenger,
    this.existing,
  });

  final ScaffoldMessengerState messenger;
  final AnnouncementItem? existing;

  @override
  State<_CreateAnnouncementSheet> createState() =>
      _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends State<_CreateAnnouncementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _authorController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageStorage = AnnouncementImageStorage();
  final _documentStorage = AnnouncementDocumentStorage();
  String? _selectedCategoryId;
  String? _localImagePath;
  String? _existingImageUrl;
  XFile? _pickedImage;
  bool _imageRemoved = false;
  PickedAnnouncementDocument? _pickedDocument;
  String? _existingDocumentUrl;
  String? _existingDocumentName;
  bool _documentRemoved = false;
  bool _pickingImage = false;
  bool _pickingDocument = false;
  bool _publishing = false;
  bool _autovalidate = false;
  ProfileStore? _profileStore;

  bool get _isEditing => widget.existing != null;

  bool get _showImagePreview =>
      !_imageRemoved && (_localImagePath != null || _existingImageUrl != null);

  bool get _showExistingDocument =>
      _pickedDocument == null &&
      !_documentRemoved &&
      _existingDocumentUrl != null &&
      _existingDocumentUrl!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final item = widget.existing;
    if (item != null) {
      _titleController.text = item.title;
      _messageController.text = item.message;
      _authorController.text = item.author;
      _selectedCategoryId = item.categoryId;
      if (item.hasImage) {
        _existingImageUrl = item.localImagePath;
      }
      if (item.hasDocument) {
        _existingDocumentUrl = item.documentUrl;
        _existingDocumentName = item.documentName;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _profileStore = ProfileStoreProvider.of(context);
      _profileStore!.addListener(_onProfileChanged);
      if (!_isEditing) {
        _ensureDefaultAuthor();
      }
    });
  }

  void _onProfileChanged() {
    if (!mounted || _authorController.text.trim().isNotEmpty) return;
    final name = _profileStore?.profile?.fullName;
    if (name != null && name.trim().isNotEmpty) {
      setState(() => _authorController.text = name.trim());
    }
  }

  Future<void> _ensureDefaultAuthor() async {
    if (_authorController.text.trim().isNotEmpty) return;

    final profileStore = _profileStore ?? ProfileStoreProvider.of(context);
    final profileName = profileStore.profile?.fullName ?? '';
    if (profileName.trim().isNotEmpty) {
      setState(() => _authorController.text = profileName.trim());
      return;
    }

    await profileStore.load();
    if (!mounted) return;
    final loadedName = profileStore.profile?.fullName ?? '';
    if (loadedName.trim().isNotEmpty) {
      setState(() => _authorController.text = loadedName.trim());
      return;
    }

    final userId = AuthSession.userId;
    if (userId == null) return;

    final user = await SupabaseAuthService.fetchUser(userId);
    if (!mounted || user == null) return;
    setState(() => _authorController.text = user.fullName.trim());
  }

  @override
  void dispose() {
    _profileStore?.removeListener(_onProfileChanged);
    _titleController.dispose();
    _messageController.dispose();
    _authorController.dispose();
    _categoryController.dispose();
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
        _imageRemoved = false;
      });
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  Future<void> _pickDocument() async {
    setState(() => _pickingDocument = true);
    try {
      final result = await _documentStorage.pickDocument();
      if (!mounted) return;

      if (result.error != null) {
        final l10n = AppLocalizations.of(context);
        final message = switch (result.error!) {
          AnnouncementDocumentPickError.invalidType =>
            l10n.announcementDocumentInvalidType,
          AnnouncementDocumentPickError.tooLarge =>
            l10n.announcementDocumentTooLarge,
        };
        AppToast.show(
          widget.messenger,
          message: message,
          type: AppToastType.error,
        );
        return;
      }

      if (result.document != null) {
        setState(() {
          _pickedDocument = result.document;
          _documentRemoved = false;
        });
        AppToast.show(
          widget.messenger,
          message: AppLocalizations.of(context).documentAttachedReady,
          type: AppToastType.success,
        );
      }
    } finally {
      if (mounted) setState(() => _pickingDocument = false);
    }
  }

  void _removeDocument() {
    setState(() {
      _pickedDocument = null;
      if (_existingDocumentUrl != null) {
        _documentRemoved = true;
      }
    });
  }

  void _removeExistingImage() {
    setState(() {
      _localImagePath = null;
      _pickedImage = null;
      _existingImageUrl = null;
      _imageRemoved = true;
    });
  }

  void _removeExistingDocument() {
    setState(() {
      _existingDocumentUrl = null;
      _existingDocumentName = null;
      _documentRemoved = true;
    });
  }

  Future<void> _addCategory() async {
    final l10n = AppLocalizations.of(context);
    final name = _categoryController.text.trim();
    final validationError = _validateCategoryName(name);
    if (validationError != null) {
      AppToast.show(
        widget.messenger,
        message: validationError,
        type: AppToastType.error,
      );
      return;
    }

    final store = AnnouncementsStoreProvider.of(context);
    try {
      final category = await store.addCategory(name);
      if (!mounted) return;
      setState(() {
        _selectedCategoryId = category.id;
        _categoryController.clear();
      });
      AppToast.show(
        widget.messenger,
        message: l10n.categoryAdded,
        type: AppToastType.success,
      );
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        widget.messenger,
        message: l10n.categoryAddFailed,
        type: AppToastType.error,
      );
    }
  }

  Future<void> _confirmDeleteCategory(AnnouncementCategoryItem category) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryConfirm(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final store = AnnouncementsStoreProvider.of(context);
    final result = await store.deleteCategory(category.id);
    if (!mounted) return;

    AppToast.show(
      widget.messenger,
      message: _categoryDeleteMessage(l10n, result),
      type: result == CategoryDeleteResult.success
          ? AppToastType.success
          : AppToastType.error,
    );

    if (result == CategoryDeleteResult.success) {
      setState(() {
        if (_selectedCategoryId == category.id) {
          _selectedCategoryId =
              store.categories.isNotEmpty ? store.categories.first.id : null;
        }
      });
    }
  }

  String _categoryDeleteMessage(
    AppLocalizations l10n,
    CategoryDeleteResult result,
  ) {
    return switch (result) {
      CategoryDeleteResult.success => l10n.categoryDeleted,
      CategoryDeleteResult.lastCategory => l10n.categoryDeleteLastOne,
      CategoryDeleteResult.inUse => l10n.categoryDeleteInUse,
      CategoryDeleteResult.failed => l10n.categoryDeleteFailed,
    };
  }

  Future<void> _submit() async {
    final store = AnnouncementsStoreProvider.of(context);
    final l10n = AppLocalizations.of(context);

    setState(() => _autovalidate = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (store.categories.isEmpty) {
      AppToast.show(
        widget.messenger,
        message: l10n.addCategoryFirst,
        type: AppToastType.error,
      );
      return;
    }

    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    var author = _authorController.text.trim();
    if (author.isEmpty) {
      author = _profileStore?.profile?.fullName.trim() ?? '';
    }
    final categoryId = _selectedCategoryId;

    if (categoryId == null) {
      AppToast.show(
        widget.messenger,
        message: l10n.pleaseSelectAnnouncementCategory,
        type: AppToastType.error,
      );
      return;
    }

    setState(() => _publishing = true);
    try {
      final bool success;
      if (_isEditing) {
        success = await store.updateAnnouncement(
          id: widget.existing!.id,
          title: title,
          message: message,
          categoryId: categoryId,
          author: author,
          existingImagePath: _existingImageUrl,
          localImagePath: _localImagePath,
          pickedImage: _pickedImage,
          removeImage: _imageRemoved,
          existingDocumentUrl: _existingDocumentUrl,
          existingDocumentName: _existingDocumentName,
          pickedDocument: _pickedDocument,
          removeDocument: _documentRemoved,
        );
      } else {
        success = await store.addAnnouncement(
          title: title,
          message: message,
          categoryId: categoryId,
          author: author,
          localImagePath: _localImagePath,
          pickedImage: _pickedImage,
          pickedDocument: _pickedDocument,
        );
      }
      if (!mounted) return;

      if (success) {
        Navigator.of(context, rootNavigator: true).pop();
        AppToast.show(
          widget.messenger,
          message: _isEditing
              ? l10n.announcementUpdated
              : l10n.announcementPublished,
          type: AppToastType.success,
        );
      } else {
        AppToast.show(
          widget.messenger,
          message: _publishErrorMessage(l10n, store.error),
          type: AppToastType.error,
        );
      }
    } catch (error) {
      if (!mounted) return;
      AppToast.show(
        widget.messenger,
        message: _publishErrorMessage(l10n, error.toString()),
        type: AppToastType.error,
      );
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  String _publishErrorMessage(AppLocalizations l10n, String? rawError) {
    if (rawError == null || rawError.trim().isEmpty) {
      return _isEditing
          ? l10n.announcementUpdateFailed
          : l10n.announcementPublishFailed;
    }

    final cleaned = rawError
        .replaceFirst(RegExp(r'^StateError:\s*'), '')
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .trim();
    final lower = cleaned.toLowerCase();

    if (lower.contains('storage') ||
        lower.contains('upload') ||
        lower.contains('bucket') ||
        lower.contains('row-level security') ||
        lower.contains('could not read the selected document')) {
      return l10n.announcementDocumentUploadFailed;
    }

    if (lower.contains('document_url') || lower.contains('column')) {
      return l10n.announcementPublishFailed;
    }

    if (lower.contains('could not find a relationship') ||
        lower.contains('pgrst200')) {
      return l10n.announcementPublishFailed;
    }

    return cleaned.length <= 140
        ? cleaned
        : (_isEditing
            ? l10n.announcementUpdateFailed
            : l10n.announcementPublishFailed);
  }

  String? _validateTitle(String? value) {
    final l10n = AppLocalizations.of(context);
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.pleaseEnterAnnouncementTitle;
    if (trimmed.length < AnnouncementFormValidation.titleMinLength) {
      return l10n.announcementTitleTooShort;
    }
    if (trimmed.length > AnnouncementFormValidation.titleMaxLength) {
      return l10n.announcementTitleTooLong;
    }
    return null;
  }

  String? _validateMessage(String? value) {
    final l10n = AppLocalizations.of(context);
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.pleaseEnterAnnouncementMessage;
    if (trimmed.length < AnnouncementFormValidation.messageMinLength) {
      return l10n.announcementMessageTooShort;
    }
    if (trimmed.length > AnnouncementFormValidation.messageMaxLength) {
      return l10n.announcementMessageTooLong;
    }
    return null;
  }

  String? _validateAuthor(String? value) {
    final l10n = AppLocalizations.of(context);
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.pleaseEnterAuthorName;
    if (trimmed.length < AnnouncementFormValidation.authorMinLength) {
      return l10n.authorNameTooShort;
    }
    if (trimmed.length > AnnouncementFormValidation.authorMaxLength) {
      return l10n.authorNameTooLong;
    }
    return null;
  }

  String? _validateCategorySelection(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return l10n.pleaseSelectAnnouncementCategory;
    }
    return null;
  }

  String? _validateCategoryName(String value) {
    final l10n = AppLocalizations.of(context);
    final trimmed = value.trim();
    if (trimmed.isEmpty) return l10n.pleaseEnterCategoryName;
    if (trimmed.length < AnnouncementFormValidation.categoryNameMinLength) {
      return l10n.categoryNameTooShort;
    }
    if (trimmed.length > AnnouncementFormValidation.categoryNameMaxLength) {
      return l10n.categoryNameTooLong;
    }
    return null;
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      errorMaxLines: 2,
    );
  }

  String _publishButtonLabel(AppLocalizations l10n) {
    if (!_publishing) {
      return _isEditing ? l10n.saveAnnouncementChanges : l10n.publishAnnouncement;
    }
    if (_isEditing) return l10n.savingAnnouncementChanges;
    if (_pickedDocument != null) return l10n.uploadingAnnouncementDocument;
    return l10n.publishingAnnouncement;
  }

  Widget _buildImagePreview() {
    final path = _localImagePath ?? _existingImageUrl;
    if (path == null) return const SizedBox.shrink();

    final isRemote = path.startsWith('http');
    final imageUrl = isRemote ? CloudinaryImageService.displayUrl(path) : path;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 140,
        child: isRemote
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : kIsWeb
                ? Image.network(path, fit: BoxFit.cover)
                : Image.file(File(path), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildExistingDocumentCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AnnouncementDocumentStorage.iconFor(
              _existingDocumentName ?? _existingDocumentUrl ?? '',
            ),
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _existingDocumentName ?? l10n.readDocument,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _publishing ? null : _removeExistingDocument,
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.text.withValues(alpha: 0.5),
            tooltip: l10n.removeAnnouncementDocument,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentAttachmentCard(AppLocalizations l10n) {
    final document = _pickedDocument!;
    final sizeLabel = AnnouncementDocumentStorage.formatFileSize(
      document.sizeBytes,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              AnnouncementDocumentStorage.iconFor(document.name),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (sizeLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sizeLabel,
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  l10n.documentAttachedReady,
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _publishing ? null : _removeDocument,
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.text.withValues(alpha: 0.5),
            tooltip: l10n.delete,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = AnnouncementsStoreProvider.of(context);

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final categories = store.categories;
        _selectedCategoryId ??=
            categories.isNotEmpty ? categories.first.id : null;

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
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
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
                    _isEditing ? l10n.editAnnouncement : l10n.createAnnouncement,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEditing
                        ? l10n.editAnnouncementHint
                        : l10n.createAnnouncementHint,
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    enabled: !_publishing,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: AnnouncementFormValidation.titleMaxLength,
                    validator: _validateTitle,
                    decoration: _fieldDecoration(l10n.announcementTitle),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _messageController,
                    enabled: !_publishing,
                    maxLines: 4,
                    maxLength: AnnouncementFormValidation.messageMaxLength,
                    validator: _validateMessage,
                    decoration: _fieldDecoration(l10n.announcementMessage)
                        .copyWith(alignLabelWithHint: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _authorController,
                    enabled: !_publishing,
                    readOnly: true,
                    textCapitalization: TextCapitalization.words,
                    maxLength: AnnouncementFormValidation.authorMaxLength,
                    validator: _validateAuthor,
                    decoration: _fieldDecoration(l10n.postedBy).copyWith(
                      hintText: l10n.postedByDefaultHint,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.announcementCategory,
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (categories.isEmpty)
                    Text(
                      l10n.addCategoryFirst,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      decoration: _fieldDecoration(l10n.announcementCategory),
                      validator: _validateCategorySelection,
                      items: categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          )
                          .toList(),
                      onChanged: _publishing
                          ? null
                          : (value) =>
                              setState(() => _selectedCategoryId = value),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _categoryController,
                          enabled: !_publishing,
                          maxLength:
                              AnnouncementFormValidation.categoryNameMaxLength,
                          decoration: _fieldDecoration(l10n.newCategoryName),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _publishing ? null : _addCategory,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          minimumSize: const Size(48, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  if (categories.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      l10n.customCategories,
                      style: TextStyle(
                        color: AppColors.text.withValues(alpha: 0.55),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final category in categories)
                          InputChip(
                            label: Text(category.name),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: _publishing
                                ? null
                                : () => _confirmDeleteCategory(category),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.08),
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            deleteIconColor:
                                AppColors.primary.withValues(alpha: 0.7),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    l10n.attachAnnouncementImage,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.attachAnnouncementImageHint,
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_showImagePreview) ...[
                    _buildImagePreview(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _publishing || _pickingImage ? null : _pickImage,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.changeVerseImage),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _publishing ? null : _removeExistingImage,
                          icon: const Icon(Icons.delete_outline),
                          label: Text(l10n.removeAnnouncementImage),
                        ),
                      ],
                    ),
                  ] else
                    OutlinedButton.icon(
                      onPressed: _publishing || _pickingImage ? null : _pickImage,
                      icon: _pickingImage
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.image_outlined),
                      label: Text(l10n.attachAnnouncementImage),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.attachAnnouncementDocument,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.attachAnnouncementDocumentHint,
                    style: TextStyle(
                      color: AppColors.text.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_pickedDocument != null)
                    _buildDocumentAttachmentCard(l10n)
                  else if (_showExistingDocument)
                    _buildExistingDocumentCard(l10n)
                  else
                    OutlinedButton.icon(
                      onPressed:
                          _publishing || _pickingDocument ? null : _pickDocument,
                      icon: _pickingDocument
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file_outlined),
                      label: Text(l10n.attachAnnouncementDocument),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  if (_publishing) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        minHeight: 4,
                        color: AppColors.primary,
                        backgroundColor: Color(0xFFE3F2FD),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _publishing ? null : _submit,
                    icon: _publishing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(_publishButtonLabel(l10n)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}
