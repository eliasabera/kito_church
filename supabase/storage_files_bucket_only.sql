-- Bucket only — run this if storage_files_bucket.sql policies fail with 42501.
-- Then add policies via Dashboard → Storage → files → Policies.

INSERT INTO storage.buckets (id, name, public)
VALUES ('files', 'files', true)
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public;
