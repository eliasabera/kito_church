import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kitoapp/core/config/cloudinary_config.dart';
import 'package:path/path.dart' as p;

class CloudinaryImageService {
  CloudinaryImageService._();

  static Uri get _uploadUri => Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
      );

  static Future<String?> uploadFromPath(
    String filePath, {
    String folder = CloudinaryConfig.versesFolder,
  }) async {
    if (filePath.isEmpty) return null;

    if (kIsWeb) {
      return uploadFromBytes(
        await _readBytesFromPath(filePath),
        p.basename(filePath),
        folder: folder,
      );
    }

    final file = File(filePath);
    if (!await file.exists()) return null;

    return uploadFromBytes(
      await file.readAsBytes(),
      p.basename(filePath),
      folder: folder,
    );
  }

  static Future<String?> uploadFromXFile(
    XFile file, {
    String folder = CloudinaryConfig.versesFolder,
  }) async {
    return uploadFromBytes(
      await file.readAsBytes(),
      file.name.isNotEmpty ? file.name : p.basename(file.path),
      folder: folder,
    );
  }

  static Future<String?> uploadFromBytes(
    Uint8List bytes,
    String fileName, {
    String folder = CloudinaryConfig.versesFolder,
  }) async {
    if (bytes.isEmpty) return null;

    try {
      final timestamp =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final signatureParams = <String, String>{
        'folder': folder,
        'timestamp': timestamp,
      };
      final signature = _sign(signatureParams);

      final request = http.MultipartRequest('POST', _uploadUri)
        ..fields['api_key'] = CloudinaryConfig.apiKey
        ..fields['timestamp'] = timestamp
        ..fields['folder'] = folder
        ..fields['signature'] = signature
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName,
          ),
        );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint(
          'Cloudinary upload failed (${response.statusCode}): $body',
        );
        return null;
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final secureUrl = json['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        debugPrint('Cloudinary upload missing secure_url: $body');
        return null;
      }

      return secureUrl;
    } catch (error, stackTrace) {
      debugPrint('CloudinaryImageService.upload failed: $error\n$stackTrace');
      return null;
    }
  }

  static String displayUrl(String url, {int width = 900}) {
    if (!url.contains('res.cloudinary.com') || !url.contains('/upload/')) {
      return url;
    }

    if (url.contains('/upload/w_')) return url;

    return url.replaceFirst(
      '/upload/',
      '/upload/w_$width,c_limit,q_auto,f_auto/',
    );
  }

  static String _sign(Map<String, String> params) {
    final sortedKeys = params.keys.toList()..sort();
    final signingString = sortedKeys.map((key) => '$key=${params[key]}').join('&');
    return sha1
        .convert(utf8.encode('$signingString${CloudinaryConfig.apiSecret}'))
        .toString();
  }

  static Future<Uint8List> _readBytesFromPath(String filePath) async {
    if (kIsWeb) {
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse(filePath));
        final response = await request.close();
        return Uint8List.fromList(await consolidateHttpClientResponseBytes(
          response,
        ));
      } finally {
        client.close();
      }
    }

    return File(filePath).readAsBytes();
  }
}
