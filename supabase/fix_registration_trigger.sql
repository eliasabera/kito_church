-- Fix student registration: ensure compassion_id exists before profiles insert
-- Run in Supabase SQL Editor after fix_admin_login.sql

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role public.user_role;
  v_status public.user_status;
  v_compassion_id TEXT;
BEGIN
  v_role := COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'student');
  v_status := COALESCE((NEW.raw_user_meta_data->>'status')::public.user_status, 'pending');
  v_compassion_id := NULLIF(NEW.raw_user_meta_data->>'compassion_id', '');

  INSERT INTO public.users (
    id, full_name, email, role, status, phone, department
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
    IF v_compassion_id IS NOT NULL THEN
      INSERT INTO public.compassion_ids (project_id, student_name, is_assigned)
      VALUES (
        v_compassion_id,
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
      v_compassion_id,
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
