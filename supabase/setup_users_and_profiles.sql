-- =============================================================================
-- KGC Connect — users + profiles split
-- Run in Supabase Dashboard → SQL Editor
--
-- users    = all roles (student, teacher, admin)
-- profiles = student-only (compassion_id, university)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1) public.users (common fields only)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.users (
  id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name       TEXT NOT NULL,
  email           TEXT NOT NULL UNIQUE,
  role            user_role NOT NULL DEFAULT 'student',
  status          user_status NOT NULL DEFAULT 'pending',
  joined_date     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  phone           TEXT,
  department      TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_users_status ON public.users(status);

DROP TRIGGER IF EXISTS users_updated_at ON public.users;
CREATE TRIGGER users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Move compassion_id / university off users → profiles (if old columns exist)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'compassion_id'
  ) THEN
    CREATE TABLE IF NOT EXISTS public.profiles (
      user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
      compassion_id TEXT REFERENCES compassion_ids(project_id) ON DELETE SET NULL,
      university TEXT,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    INSERT INTO public.profiles (user_id, compassion_id, university)
    SELECT id, compassion_id, university
    FROM public.users
    WHERE role = 'student'
      AND (compassion_id IS NOT NULL OR university IS NOT NULL)
    ON CONFLICT (user_id) DO UPDATE SET
      compassion_id = COALESCE(EXCLUDED.compassion_id, profiles.compassion_id),
      university = COALESCE(EXCLUDED.university, profiles.university),
      updated_at = NOW();

    ALTER TABLE public.users DROP COLUMN IF EXISTS compassion_id;
    ALTER TABLE public.users DROP COLUMN IF EXISTS university;
    ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_student_compassion;
    DROP INDEX IF EXISTS idx_users_compassion_id;
  END IF;
END $$;

-- -----------------------------------------------------------------------------
-- 2) public.profiles (student details)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  user_id         UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  compassion_id   TEXT REFERENCES compassion_ids(project_id) ON DELETE SET NULL,
  university      TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_compassion_id ON public.profiles(compassion_id);
CREATE INDEX IF NOT EXISTS idx_profiles_university ON public.profiles(university);

DROP TRIGGER IF EXISTS profiles_updated_at ON public.profiles;
CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- If an old full-user profiles table exists (id PK), migrate student rows
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'id'
  ) AND EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'profiles' AND column_name = 'email'
  ) THEN
    INSERT INTO public.users (
      id, full_name, email, role, status, joined_date, phone, department, created_at, updated_at
    )
    SELECT
      id, full_name, email, role, status, joined_date, phone, department, created_at, updated_at
    FROM public.profiles
    ON CONFLICT (id) DO UPDATE SET
      full_name = EXCLUDED.full_name,
      email = EXCLUDED.email,
      role = EXCLUDED.role,
      status = EXCLUDED.status,
      updated_at = NOW();

    CREATE TABLE IF NOT EXISTS public.profiles_new (
      user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
      compassion_id TEXT REFERENCES compassion_ids(project_id) ON DELETE SET NULL,
      university TEXT,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    INSERT INTO public.profiles_new (user_id, compassion_id, university, created_at, updated_at)
    SELECT id, compassion_id, university, created_at, updated_at
    FROM public.profiles
    WHERE role = 'student'
    ON CONFLICT (user_id) DO NOTHING;

    DROP TABLE public.profiles CASCADE;
    ALTER TABLE public.profiles_new RENAME TO profiles;

    CREATE INDEX IF NOT EXISTS idx_profiles_compassion_id ON public.profiles(compassion_id);
    CREATE INDEX IF NOT EXISTS idx_profiles_university ON public.profiles(university);
  END IF;
END $$;

ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- 3) Signup trigger: users + profiles (students only)
-- -----------------------------------------------------------------------------
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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- -----------------------------------------------------------------------------
-- 4) Seed admin + teacher (users only — no profiles row)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION seed_auth_user(
  p_email TEXT,
  p_password TEXT,
  p_full_name TEXT,
  p_role user_role,
  p_status user_status,
  p_department TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_user_id UUID := gen_random_uuid();
  v_encrypted_pw TEXT := crypt(p_password, gen_salt('bf'));
BEGIN
  DELETE FROM auth.identities
  WHERE user_id IN (SELECT id FROM auth.users WHERE email = p_email);

  DELETE FROM public.profiles
  WHERE user_id IN (SELECT id FROM public.users WHERE email = p_email);

  DELETE FROM public.users WHERE email = p_email;
  DELETE FROM auth.users WHERE email = p_email;

  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at
  )
  VALUES (
    v_user_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    p_email,
    v_encrypted_pw,
    NOW(),
    '{"provider":"email","providers":["email"]}',
    jsonb_build_object(
      'full_name', p_full_name,
      'role', p_role::text,
      'status', p_status::text,
      'department', COALESCE(p_department, '')
    ),
    NOW(),
    NOW()
  );

  INSERT INTO auth.identities (
    id, user_id, identity_data, provider, provider_id,
    last_sign_in_at, created_at, updated_at
  )
  VALUES (
    v_user_id,
    v_user_id,
    jsonb_build_object('sub', v_user_id::text, 'email', p_email),
    'email',
    v_user_id::text,
    NOW(),
    NOW(),
    NOW()
  );

  UPDATE public.users
  SET
    full_name = p_full_name,
    role = p_role,
    status = p_status,
    department = p_department,
    updated_at = NOW()
  WHERE id = v_user_id;

  RETURN v_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

SELECT seed_auth_user(
  'admin@gmail.com', 'admin123', 'System Admin',
  'admin'::user_role, 'active'::user_status, 'Administration'
);

SELECT seed_auth_user(
  'teacher@gmail.com', 'teacher123', 'Demo Teacher',
  'teacher'::user_role, 'active'::user_status, 'ET-221 Teaching'
);

DROP FUNCTION seed_auth_user(TEXT, TEXT, TEXT, user_role, user_status, TEXT);
