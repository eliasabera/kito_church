-- =============================================================================
-- Seed Admin + Teacher accounts (auth.users only — trigger fills public.users)
--
-- Admin:   admin@gmail.com  / admin123  (active — can log in immediately)
-- Teacher: teacher@gmail.com / teacher123 (active — can log in immediately)
--
-- Run AFTER: schema.sql OR migrate_profiles_to_users.sql OR create_users_table.sql
-- Supabase Dashboard → SQL Editor → Run
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

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
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at
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
    id,
    user_id,
    identity_data,
    provider,
    provider_id,
    last_sign_in_at,
    created_at,
    updated_at
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

  -- Trigger creates public.users row; ensure role/status are correct
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
  'admin@gmail.com',
  'admin123',
  'System Admin',
  'admin'::user_role,
  'active'::user_status,
  'Administration'
);

SELECT seed_auth_user(
  'teacher@gmail.com',
  'teacher123',
  'Demo Teacher',
  'teacher'::user_role,
  'active'::user_status,
  'ET-221 Teaching'
);

DROP FUNCTION seed_auth_user(TEXT, TEXT, TEXT, user_role, user_status, TEXT);
