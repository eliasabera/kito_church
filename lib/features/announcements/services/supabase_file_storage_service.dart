import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kitoapp/core/config/supabase_storage_config.dart';
import 'package:kitoapp/features/auth/services/supabase_auth_service.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFileStorageService {
  SupabaseFileStorageService._();

  static SupabaseStorageClient get _storage =>
      SupabaseAuthService.client.storage;

  static Future<String> uploadFromPath(
    String filePath, {
    String bucket = SupabaseStorageConfig.filesBucket,
    String folder = SupabaseStorageConfig.announcementDocumentsFolder,
  }) async {
    if (filePath.isEmpty) {
      throw StateError('Document file path is empty');
    }

    if (kIsWeb) {
      return uploadFromBytes(
        await _readBytesFromPath(filePath),
        p.basename(filePath),
        bucket: bucket,
        folder: folder,
      );
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw StateError('Could not read the selected document file');
    }

    return uploadFromBytes(
      await file.readAsBytes(),
      p.basename(filePath),
      bucket: bucket,
      folder: folder,
    );
  }

  static Future<String> uploadFromBytes(
    Uint8List bytes,
    String fileName, {
    String bucket = SupabaseStorageConfig.filesBucket,
    String folder = SupabaseStorageConfig.announcementDocumentsFolder,
  }) async {
    if (bytes.isEmpty) {
      throw StateError('Document file is empty');
    }

    final storagePath = _buildStoragePath(folder, fileName);
    final contentType = _contentTypeFor(fileName);

    try {
      await _storage.from(bucket).uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      return _storage.from(bucket).getPublicUrl(storagePath);
    } on StorageException catch (error, stackTrace) {
      debugPrint(
        'SupabaseFileStorageService.upload failed: ${error.message}\n$stackTrace',
      );
      throw StateError(
        error.message.isNotEmpty
            ? error.message
            : 'Document upload to storage failed',
      );
    } catch (error, stackTrace) {
      debugPrint('SupabaseFileStorageService.upload failed: $error\n$stackTrace');
      rethrow;
    }
  }

  static String _buildStoragePath(String folder, String fileName) {
    final trimmed = fileName.trim();
    final baseName = trimmed.isEmpty ? 'document' : p.basename(trimmed);
    final safeName = baseName.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    return '$folder/${timestamp}_$safeName';
  }

  static String? _contentTypeFor(String fileName) {
    final extension = p.extension(fileName).toLowerCase();
    return switch (extension) {
      '.pdf' => 'application/pdf',
      '.doc' => 'application/msword',
      '.docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      _ => 'application/octet-stream',
    };
  }

  static Future<Uint8List> _readBytesFromPath(String filePath) async {
    if (kIsWeb) {
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse(filePath));
        final response = await request.close();
        return Uint8List.fromList(
          await consolidateHttpClientResponseBytes(response),
        );
      } finally {
        client.close();
      }
    }

    return File(filePath).readAsBytes();
  }
}
