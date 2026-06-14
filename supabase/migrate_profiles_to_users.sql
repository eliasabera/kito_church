-- =============================================================================
-- Migrate profiles → users (run once if you already created profiles table)
-- Supabase Dashboard → SQL Editor → Run
-- =============================================================================

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'profiles'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'users'
  ) THEN
    ALTER TABLE public.profiles RENAME TO users;
    ALTER INDEX IF EXISTS idx_profiles_role RENAME TO idx_users_role;
    ALTER INDEX IF EXISTS idx_profiles_status RENAME TO idx_users_status;
    ALTER INDEX IF EXISTS idx_profiles_compassion_id RENAME TO idx_users_compassion_id;
    ALTER TABLE users RENAME CONSTRAINT profiles_student_compassion TO users_student_compassion;
  END IF;
END $$;

DROP TRIGGER IF EXISTS profiles_updated_at ON public.users;
DROP TRIGGER IF EXISTS users_updated_at ON public.users;

CREATE TRIGGER users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (
    id,
    full_name,
    email,
    role,
    status,
    compassion_id,
    university,
    phone,
    department
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    NEW.email,
    COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'student'),
    COALESCE((NEW.raw_user_meta_data->>'status')::user_status, 'pending'),
    NULLIF(NEW.raw_user_meta_data->>'compassion_id', ''),
    NULLIF(NEW.raw_user_meta_data->>'university', ''),
    NULLIF(NEW.raw_user_meta_data->>'phone', ''),
    NULLIF(NEW.raw_user_meta_data->>'department', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
