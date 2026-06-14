-- Run this on your EXISTING Supabase project to remove all RLS policies.
-- Supabase Dashboard → SQL Editor → New query → Run

-- Drop helper functions used only by RLS policies
DROP FUNCTION IF EXISTS is_teacher_or_admin() CASCADE;
DROP FUNCTION IF EXISTS is_admin() CASCADE;
DROP FUNCTION IF EXISTS auth_user_role() CASCADE;

-- Drop all policies on public tables
DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
  LOOP
    EXECUTE format(
      'DROP POLICY IF EXISTS %I ON %I.%I',
      pol.policyname,
      pol.schemaname,
      pol.tablename
    );
  END LOOP;
END $$;

-- Disable RLS on all app tables
ALTER TABLE IF EXISTS users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS compassion_ids DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS sponsors DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS student_sponsorship_links DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS sponsor_letters DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS sponsor_letter_reads DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS gifts DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS teacher_lessons DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS assignments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS quizzes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS quiz_questions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS lesson_progress DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS quiz_completions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS assignment_submissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS quiz_attempts DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS attendance_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS student_attendance_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS prayer_requests DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS prayer_comments DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS prayer_likes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS announcement_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS announcements DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS announcement_reads DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS bible_verses DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS user_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS bible_stories DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS scoring_config DISABLE ROW LEVEL SECURITY;

-- Keep signup trigger updated (users + student profiles)
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_role user_role;
BEGIN
  v_role := COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'student');

  INSERT INTO public.users (
    id, full_name, email, role, status, phone, department
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    NEW.email,
    v_role,
    COALESCE((NEW.raw_user_meta_data->>'status')::user_status, 'pending'),
    NULLIF(NEW.raw_user_meta_data->>'phone', ''),
    NULLIF(NEW.raw_user_meta_data->>'department', '')
  );

  IF v_role = 'student' THEN
    INSERT INTO public.profiles (user_id, compassion_id, university)
    VALUES (
      NEW.id,
      NULLIF(NEW.raw_user_meta_data->>'compassion_id', ''),
      NULLIF(NEW.raw_user_meta_data->>'university', '')
    )
    ON CONFLICT (user_id) DO UPDATE SET
      compassion_id = COALESCE(EXCLUDED.compassion_id, profiles.compassion_id),
      university = COALESCE(EXCLUDED.university, profiles.university),
      updated_at = NOW();
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
