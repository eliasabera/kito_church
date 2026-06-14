-- Supabase Storage: public "files" bucket for PDF/DOC attachments.
--
-- IMPORTANT: Do NOT run "ALTER TABLE storage.objects ..." — Supabase owns that
-- table and RLS is already enabled. Altering it causes:
--   ERROR 42501: must be owner of table objects
--
-- Option A — Run this SQL in Dashboard → SQL Editor (policies section only).
-- Option B — If policies still fail in SQL, use Dashboard → Storage → files → Policies
--            and create the rules listed at the bottom of this file.

-- 1) Ensure bucket exists and is public
INSERT INTO storage.buckets (id, name, public)
VALUES ('files', 'files', true)
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public;

-- 2) Storage policies (RLS is already on — only create policies)
DROP POLICY IF EXISTS "Public read files bucket" ON storage.objects;
CREATE POLICY "Public read files bucket"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'files');

DROP POLICY IF EXISTS "Authenticated upload files bucket" ON storage.objects;
CREATE POLICY "Authenticated upload files bucket"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'files');

DROP POLICY IF EXISTS "Authenticated update files bucket" ON storage.objects;
CREATE POLICY "Authenticated update files bucket"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'files')
  WITH CHECK (bucket_id = 'files');

-- ---------------------------------------------------------------------------
-- Option B — Dashboard UI (if SQL policies fail with 42501)
-- Storage → files → Policies → New policy
--
-- SELECT (read):  bucket_id = 'files'
-- INSERT (upload): bucket_id = 'files'  → Target roles: authenticated
-- UPDATE (upsert): bucket_id = 'files'  → Target roles: authenticated
-- ---------------------------------------------------------------------------
