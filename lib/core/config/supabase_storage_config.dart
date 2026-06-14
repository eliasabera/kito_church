/// Supabase Storage bucket configuration.
class SupabaseStorageConfig {
  SupabaseStorageConfig._();

  /// Public bucket for PDF/DOC announcement attachments.
  /// Public URL pattern: .../storage/v1/object/public/files/announcements/file.pdf
  static const filesBucket = 'files';

  static const announcementDocumentsFolder = 'announcements';
}
