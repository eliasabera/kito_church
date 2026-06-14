import 'dart:io';

import 'package:supabase/supabase.dart';

/// Uploads assets/emuti.pdf to the Supabase `files` bucket.
///
/// Requires storage policies from supabase/storage_files_bucket.sql.
/// Run: dart run bin/upload_emuti_to_storage.dart
Future<void> main() async {
  const url = 'https://dzmzhedivahklfficzpv.supabase.co';
  const anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6bXpoZWRpdmFoa2xmZmljenB2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNzE2NDYsImV4cCI6MjA5Njk0NzY0Nn0.z58FG2yAaY4OzAJdpRmRmEw1monnq5U539k15WE5DQk';

  final file = File('assets/emuti.pdf');
  if (!await file.exists()) {
    stderr.writeln('File not found: ${file.absolute.path}');
    stderr.writeln('Run this script from the project root.');
    exit(1);
  }

  final client = SupabaseClient(url, anonKey);
  stderr.writeln('Signing in as admin...');
  await client.auth.signInWithPassword(
    email: 'admin@gmail.com',
    password: 'admin123',
  );

  const storagePath = 'emuti.pdf';
  final bytes = await file.readAsBytes();
  stderr.writeln('Uploading ${bytes.length} bytes to files/$storagePath ...');

  try {
    await client.storage.from('files').uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true,
          ),
        );
  } on StorageException catch (error) {
    stderr.writeln('Upload failed: ${error.message}');
    stderr.writeln(
      'Run supabase/storage_files_bucket.sql in Supabase SQL Editor first.',
    );
    exit(1);
  }

  final publicUrl = client.storage.from('files').getPublicUrl(storagePath);
  stdout.writeln('Upload successful.');
  stdout.writeln('Public URL: $publicUrl');
}
