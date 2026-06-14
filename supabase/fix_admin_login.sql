-- =============================================================================
-- FIX: Admin login + signup trigger
-- Run in Supabase Dashboard → SQL Editor
--
-- Problems fixed:
-- 1) Old handle_new_user trigger inserting removed columns on public.users
-- 2) SQL-seeded auth user with broken password / identity
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1) Correct signup trigger (users + student profiles only)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role public.user_role;
  v_status public.user_status;
BEGIN
  v_role := COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'student');
  v_status := COALESCE((NEW.raw_user_meta_data->>'status')::public.user_status, 'pending');

  INSERT INTO public.users (
    id,
    full_name,
    email,
    role,
    status,
    phone,
    department
  )
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    NEW.email,
    v_role,
    v_status,
    NULLIF(NEW.raw_user_meta_data->>'phone', ''),
    NULLIF(NEW.raw_user_meta_data->>'department', '')
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    status = EXCLUDED.status,
    phone = EXCLUDED.phone,
    department = EXCLUDED.department,
    updated_at = NOW();

  IF v_role = 'student' THEN
    IF NULLIF(NEW.raw_user_meta_data->>'compassion_id', '') IS NOT NULL THEN
      INSERT INTO public.compassion_ids (project_id, student_name, is_assigned)
      VALUES (
        NULLIF(NEW.raw_user_meta_data->>'compassion_id', ''),
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        TRUE
      )
      ON CONFLICT (project_id) DO UPDATE SET
        student_name = EXCLUDED.student_name,
        is_assigned = TRUE,
        updated_at = NOW();
    END IF;

    INSERT INTO public.profiles (user_id, compassion_id, university)
    VALUES (
      NEW.id,
      NULLIF(NEW.raw_user_meta_data->>'compassion_id', ''),
      NULLIF(NEW.raw_user_meta_data->>'university', '')
    )
    ON CONFLICT (user_id) DO UPDATE SET
      compassion_id = COALESCE(EXCLUDED.compassion_id, public.profiles.compassion_id),
      university = COALESCE(EXCLUDED.university, public.profiles.university),
      updated_at = NOW();
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- -----------------------------------------------------------------------------
-- 2) Recreate admin auth user (password: admin123)
-- -----------------------------------------------------------------------------
DO $$
DECLARE
  v_email TEXT := 'admin@gmail.com';
  v_password TEXT := 'admin123';
  v_user_id UUID;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = v_email;

  IF v_user_id IS NOT NULL THEN
    DELETE FROM auth.identities WHERE user_id = v_user_id;
    DELETE FROM public.profiles WHERE user_id = v_user_id;
    DELETE FROM public.users WHERE id = v_user_id;
    DELETE FROM auth.users WHERE id = v_user_id;
  END IF;

  v_user_id := gen_random_uuid();

  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    confirmation_sent_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token,
    is_sso_user
  )
  VALUES (
    '00000000-0000-0000-0000-000000000000',
    v_user_id,
    'authenticated',
    'authenticated',
    v_email,
    extensions.crypt(v_password, extensions.gen_salt('bf')),
    NOW(),
    NOW(),
    NOW(),
    NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object(
      'full_name', 'System Admin',
      'role', 'admin',
      'status', 'active',
      'department', 'Administration'
    ),
    NOW(),
    NOW(),
    '',
    '',
    '',
    '',
    FALSE
  );

  INSERT INTO auth.identities (
    provider_id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at,
    id
  )
  VALUES (
    v_user_id::text,
    v_user_id,
    jsonb_build_object('sub', v_user_id::text, 'email', v_email),
    'email',
    NOW(),
    NOW(),
    NOW(),
    gen_random_uuid()
  );

  -- Trigger should create public.users; ensure admin row is correct
  INSERT INTO public.users (id, full_name, email, role, status, department)
  VALUES (v_user_id, 'System Admin', v_email, 'admin', 'active', 'Administration')
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    role = 'admin',
    status = 'active',
    department = EXCLUDED.department,
    updated_at = NOW();
END $$;

-- -----------------------------------------------------------------------------
-- 3) Recreate teacher (password: teacher123) — optional
-- -----------------------------------------------------------------------------
DO $$
DECLARE
  v_email TEXT := 'teacher@gmail.com';
  v_password TEXT := 'teacher123';
  v_user_id UUID;
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = v_email;

  IF v_user_id IS NOT NULL THEN
    DELETE FROM auth.identities WHERE user_id = v_user_id;
    DELETE FROM public.profiles WHERE user_id = v_user_id;
    DELETE FROM public.users WHERE id = v_user_id;
    DELETE FROM auth.users WHERE id = v_user_id;
  END IF;

  v_user_id := gen_random_uuid();

  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, confirmation_sent_at, last_sign_in_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, email_change, email_change_token_new, recovery_token, is_sso_user
  )
  VALUES (
    '00000000-0000-0000-0000-000000000000',
    v_user_id, 'authenticated', 'authenticated', v_email,
    extensions.crypt(v_password, extensions.gen_salt('bf')),
    NOW(), NOW(), NOW(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('full_name', 'Demo Teacher', 'role', 'teacher', 'status', 'active', 'department', 'ET-221 Teaching'),
    NOW(), NOW(), '', '', '', '', FALSE
  );

  INSERT INTO auth.identities (
    provider_id, user_id, identity_data, provider,
    last_sign_in_at, created_at, updated_at, id
  )
  VALUES (
    v_user_id::text, v_user_id,
    jsonb_build_object('sub', v_user_id::text, 'email', v_email),
    'email', NOW(), NOW(), NOW(), gen_random_uuid()
  );

  INSERT INTO public.users (id, full_name, email, role, status, department)
  VALUES (v_user_id, 'Demo Teacher', v_email, 'teacher', 'active', 'ET-221 Teaching')
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    role = 'teacher',
    status = 'active',
    department = EXCLUDED.department,
    updated_at = NOW();
END $$;

ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
