-- Add document attachment support to announcements (PDF, DOC, DOCX)
ALTER TABLE announcements
  ADD COLUMN IF NOT EXISTS document_url TEXT,
  ADD COLUMN IF NOT EXISTS document_name TEXT;
