import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class VerseImageStorage {
  VerseImageStorage({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickFromGallery() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
  }

  Future<String?> persistImage(XFile file) async {
    if (kIsWeb) return file.path;

    final dir = await getApplicationDocumentsDirectory();
    final versesDir = Directory(p.join(dir.path, 'verse_images'));
    if (!await versesDir.exists()) {
      await versesDir.create(recursive: true);
    }

    final extension = p.extension(file.path).isEmpty ? '.jpg' : p.extension(file.path);
    final destPath = p.join(
      versesDir.path,
      'verse_${DateTime.now().millisecondsSinceEpoch}$extension',
    );

    await File(file.path).copy(destPath);
    return destPath;
  }
}
