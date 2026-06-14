-- Fix PostgREST embed: announcements.author_id -> users.id
-- Run in Supabase Dashboard → SQL Editor if author join fails.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'announcements_author_id_fkey'
  ) THEN
    ALTER TABLE public.announcements
      ADD CONSTRAINT announcements_author_id_fkey
      FOREIGN KEY (author_id) REFERENCES public.users(id) ON DELETE SET NULL;
  END IF;
END $$;
