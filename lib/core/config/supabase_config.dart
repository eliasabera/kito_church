/// Supabase project configuration.
/// The anon key is safe to embed in client apps.
class SupabaseConfig {
  SupabaseConfig._();

  static const url = 'https://dzmzhedivahklfficzpv.supabase.co';
  static const publishableKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6bXpoZWRpdmFoa2xmZmljenB2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEzNzE2NDYsImV4cCI6MjA5Njk0NzY0Nn0.z58FG2yAaY4OzAJdpRmRmEw1monnq5U539k15WE5DQk';

  @Deprecated('Use publishableKey')
  static const anonKey = publishableKey;
}
