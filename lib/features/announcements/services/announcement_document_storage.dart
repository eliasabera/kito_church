import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PickedAnnouncementDocument {
  const PickedAnnouncementDocument({
    required this.name,
    required this.path,
    this.bytes,
    this.sizeBytes = 0,
  });

  final String name;
  final String path;
  final Uint8List? bytes;
  final int sizeBytes;
}

enum AnnouncementDocumentPickError {
  invalidType,
  tooLarge,
}

class AnnouncementDocumentPickResult {
  const AnnouncementDocumentPickResult({
    this.document,
    this.error,
  });

  final PickedAnnouncementDocument? document;
  final AnnouncementDocumentPickError? error;
}

class AnnouncementDocumentStorage {
  static const _allowedExtensions = ['pdf', 'doc', 'docx'];
  static const maxFileSizeBytes = 10 * 1024 * 1024;

  static const allowedExtensions = _allowedExtensions;

  Future<AnnouncementDocumentPickResult> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return const AnnouncementDocumentPickResult();
    }

    final file = result.files.single;
    final name = file.name.trim();
    if (name.isEmpty) {
      return const AnnouncementDocumentPickResult();
    }

    if (!isAllowedExtension(name)) {
      return const AnnouncementDocumentPickResult(
        error: AnnouncementDocumentPickError.invalidType,
      );
    }

    if (!isWithinSizeLimit(file.size)) {
      return const AnnouncementDocumentPickResult(
        error: AnnouncementDocumentPickError.tooLarge,
      );
    }

    return AnnouncementDocumentPickResult(
      document: PickedAnnouncementDocument(
        name: name,
        path: file.path ?? name,
        bytes: file.bytes,
        sizeBytes: file.size,
      ),
    );
  }

  static IconData iconFor(String nameOrUrl) {
    if (isPdf(nameOrUrl)) return Icons.picture_as_pdf_outlined;
    if (isWordDocument(nameOrUrl)) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static bool isPdf(String nameOrUrl) {
    return nameOrUrl.toLowerCase().endsWith('.pdf');
  }

  static bool isWordDocument(String nameOrUrl) {
    final lower = nameOrUrl.toLowerCase();
    return lower.endsWith('.doc') || lower.endsWith('.docx');
  }

  static bool isAllowedExtension(String fileName) {
    final extension =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    return _allowedExtensions.contains(extension);
  }

  static bool isWithinSizeLimit(int bytes) => bytes <= maxFileSizeBytes;
}
