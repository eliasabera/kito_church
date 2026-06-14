-- =============================================================================
-- KGC Connect (ET-221) — Full Supabase Schema
-- Paste into: Supabase Dashboard → SQL Editor → New query → Run
-- Maps to Flutter models under lib/features/ and lib/shared/
-- =============================================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- ENUM TYPES (match lib/core/enums/app_enums.dart + feature enums)
-- =============================================================================

CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');

CREATE TYPE user_status AS ENUM ('active', 'pending', 'suspended', 'rejected');

CREATE TYPE gift_status AS ENUM ('pending', 'received', 'delivered');

CREATE TYPE gift_type AS ENUM ('digital', 'physical');

CREATE TYPE teacher_lesson_status AS ENUM ('draft', 'published', 'active', 'closed');

CREATE TYPE prayer_request_status AS ENUM ('praying', 'answered');

CREATE TYPE submission_status AS ENUM ('not_submitted', 'submitted', 'graded');

CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'late');

CREATE TYPE attendance_type AS ENUM ('physical', 'online');

CREATE TYPE scoring_category AS ENUM ('attendance', 'quiz', 'assignment');

CREATE TYPE notification_audience AS ENUM ('student', 'admin');

CREATE TYPE app_notification_type AS ENUM (
  'weekly_lesson',
  'gift_arrived',
  'daily_verse',
  'account_approved',
  'registration_pending'
);

-- =============================================================================
-- HELPER: auto-update updated_at
-- =============================================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- COMPASSION IDS  ←  CompassionId / app_database.dart (SQLite today)
-- =============================================================================

CREATE TABLE compassion_ids (
  id            BIGSERIAL PRIMARY KEY,
  project_id    TEXT NOT NULL UNIQUE,
  student_name  TEXT,
  is_assigned   BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER compassion_ids_updated_at
  BEFORE UPDATE ON compassion_ids
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- USERS  ←  All roles: student, teacher, admin (linked to Supabase Auth)
-- =============================================================================

CREATE TABLE users (
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

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);

CREATE TRIGGER users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- PROFILES  ←  Student-only extra details (compassion_id, university)
-- =============================================================================

CREATE TABLE profiles (
  user_id         UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  compassion_id   TEXT REFERENCES compassion_ids(project_id) ON DELETE SET NULL,
  university      TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_profiles_compassion_id ON profiles(compassion_id);
CREATE INDEX idx_profiles_university ON profiles(university);

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Auto-create users row (+ student profile when applicable) on auth signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_role user_role;
  v_status user_status;
BEGIN
  v_role := COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'student');
  v_status := COALESCE((NEW.raw_user_meta_data->>'status')::user_status, 'pending');

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
      compassion_id = COALESCE(EXCLUDED.compassion_id, profiles.compassion_id),
      university = COALESCE(EXCLUDED.university, profiles.university),
      updated_at = NOW();
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- =============================================================================
-- SPONSORS & SPONSORSHIP  ←  Sponsor, StudentSponsorshipLink
-- =============================================================================

CREATE TABLE sponsors (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  country     TEXT NOT NULL,
  email       TEXT,
  message     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER sponsors_updated_at
  BEFORE UPDATE ON sponsors
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE student_sponsorship_links (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id    UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  sponsor_id    UUID NOT NULL UNIQUE REFERENCES sponsors(id) ON DELETE CASCADE,
  linked_date   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sponsorship_sponsor ON student_sponsorship_links(sponsor_id);

-- =============================================================================
-- SPONSOR LETTERS  ←  SponsorLetter
-- =============================================================================

CREATE TABLE sponsor_letters (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id  UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  sponsor_id  UUID NOT NULL REFERENCES sponsors(id) ON DELETE CASCADE,
  body        TEXT NOT NULL,
  sent_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sponsor_letters_student ON sponsor_letters(student_id);
CREATE INDEX idx_sponsor_letters_sponsor ON sponsor_letters(sponsor_id);

CREATE TABLE sponsor_letter_reads (
  letter_id   UUID NOT NULL REFERENCES sponsor_letters(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  read_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (letter_id, user_id)
);

-- =============================================================================
-- GIFTS  ←  ManagedGift / GiftItem
-- =============================================================================

CREATE TABLE gifts (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  sponsor_id    UUID NOT NULL REFERENCES sponsors(id) ON DELETE RESTRICT,
  title         TEXT NOT NULL,
  description   TEXT NOT NULL DEFAULT '',
  gift_date     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  type          gift_type NOT NULL DEFAULT 'physical',
  status        gift_status NOT NULL DEFAULT 'pending',
  announced     BOOLEAN NOT NULL DEFAULT FALSE,
  announced_at  TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_gifts_student ON gifts(student_id);
CREATE INDEX idx_gifts_sponsor ON gifts(sponsor_id);
CREATE INDEX idx_gifts_status ON gifts(status);
CREATE INDEX idx_gifts_announced ON gifts(announced);

CREATE TRIGGER gifts_updated_at
  BEFORE UPDATE ON gifts
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- TEACHING & LEARNING  ←  TeacherLesson, AssignmentContent, QuizContent
-- =============================================================================

CREATE TABLE teacher_lessons (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id      UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  week_number     INTEGER NOT NULL,
  title           TEXT NOT NULL,
  description     TEXT,
  min_age         INTEGER NOT NULL DEFAULT 0,
  max_age         INTEGER NOT NULL DEFAULT 99,
  posted_date     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deadline        TIMESTAMPTZ NOT NULL,
  status          teacher_lesson_status NOT NULL DEFAULT 'draft',
  has_quiz        BOOLEAN NOT NULL DEFAULT FALSE,
  has_assignment  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (teacher_id, week_number)
);

CREATE INDEX idx_teacher_lessons_teacher ON teacher_lessons(teacher_id);
CREATE INDEX idx_teacher_lessons_status ON teacher_lessons(status);
CREATE INDEX idx_teacher_lessons_week ON teacher_lessons(week_number);

CREATE TRIGGER teacher_lessons_updated_at
  BEFORE UPDATE ON teacher_lessons
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE assignments (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id        UUID NOT NULL UNIQUE REFERENCES teacher_lessons(id) ON DELETE CASCADE,
  title            TEXT NOT NULL,
  instructions     TEXT NOT NULL DEFAULT '',
  attachment_path  TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER assignments_updated_at
  BEFORE UPDATE ON assignments
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE quizzes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id   UUID NOT NULL UNIQUE REFERENCES teacher_lessons(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER quizzes_updated_at
  BEFORE UPDATE ON quizzes
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE quiz_questions (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id        UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  question       TEXT NOT NULL,
  options        JSONB NOT NULL DEFAULT '[]'::jsonb,
  correct_index  INTEGER NOT NULL DEFAULT 0,
  sort_order     INTEGER NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT quiz_questions_options_array CHECK (jsonb_typeof(options) = 'array'),
  CONSTRAINT quiz_questions_correct_index CHECK (correct_index >= 0)
);

CREATE INDEX idx_quiz_questions_quiz ON quiz_questions(quiz_id, sort_order);

-- =============================================================================
-- STUDENT PROGRESS  ←  LearningProgressStore, LessonProgress
-- =============================================================================

CREATE TABLE lesson_progress (
  student_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lesson_id           UUID NOT NULL REFERENCES teacher_lessons(id) ON DELETE CASCADE,
  time_spent_seconds  INTEGER NOT NULL DEFAULT 0,
  scroll_progress     NUMERIC(4, 3) NOT NULL DEFAULT 0 CHECK (scroll_progress >= 0 AND scroll_progress <= 1),
  is_completed        BOOLEAN NOT NULL DEFAULT FALSE,
  completed_at        TIMESTAMPTZ,
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (student_id, lesson_id)
);

CREATE TABLE quiz_completions (
  student_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  quiz_id       UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  score         INTEGER,
  passed        BOOLEAN NOT NULL DEFAULT FALSE,
  completed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (student_id, quiz_id)
);

CREATE TABLE assignment_submissions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id   UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
  student_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status          submission_status NOT NULL DEFAULT 'not_submitted',
  score           INTEGER CHECK (score IS NULL OR (score >= 0 AND score <= 100)),
  answer_text     TEXT,
  attachment_path TEXT,
  submitted_at    TIMESTAMPTZ,
  graded_at       TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (assignment_id, student_id)
);

CREATE INDEX idx_assignment_submissions_student ON assignment_submissions(student_id);
CREATE INDEX idx_assignment_submissions_status ON assignment_submissions(status);

CREATE TRIGGER assignment_submissions_updated_at
  BEFORE UPDATE ON assignment_submissions
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE quiz_attempts (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id       UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  student_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  score         INTEGER NOT NULL DEFAULT 0 CHECK (score >= 0 AND score <= 100),
  passed        BOOLEAN NOT NULL DEFAULT FALSE,
  answers       JSONB,
  attempted_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_quiz_attempts_student ON quiz_attempts(student_id, attempted_at DESC);
CREATE INDEX idx_quiz_attempts_quiz ON quiz_attempts(quiz_id);

-- =============================================================================
-- ATTENDANCE  ←  AttendanceSession, TeacherAttendanceSession
-- =============================================================================

CREATE TABLE attendance_sessions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  week_number     INTEGER,
  session_date    DATE NOT NULL,
  session_label   TEXT NOT NULL,
  posted_date     TIMESTAMPTZ,
  deadline        TIMESTAMPTZ,
  lesson_id       UUID REFERENCES teacher_lessons(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_attendance_sessions_date ON attendance_sessions(session_date DESC);
CREATE INDEX idx_attendance_sessions_lesson ON attendance_sessions(lesson_id);

CREATE TRIGGER attendance_sessions_updated_at
  BEFORE UPDATE ON attendance_sessions
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE student_attendance_records (
  session_id        UUID NOT NULL REFERENCES attendance_sessions(id) ON DELETE CASCADE,
  student_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  physical_status   attendance_status,
  online_marked     BOOLEAN NOT NULL DEFAULT FALSE,
  lesson_completed  BOOLEAN NOT NULL DEFAULT FALSE,
  marked_at         TIMESTAMPTZ,
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (session_id, student_id)
);

CREATE INDEX idx_student_attendance_student ON student_attendance_records(student_id);

CREATE TRIGGER student_attendance_records_updated_at
  BEFORE UPDATE ON student_attendance_records
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- PRAYER REQUESTS  ←  PrayerRequest, PrayerComment
-- =============================================================================

CREATE TABLE prayer_requests (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id   UUID REFERENCES users(id) ON DELETE SET NULL,
  message     TEXT NOT NULL,
  status      prayer_request_status NOT NULL DEFAULT 'praying',
  is_private  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_prayer_requests_author ON prayer_requests(author_id);
CREATE INDEX idx_prayer_requests_status ON prayer_requests(status);

CREATE TRIGGER prayer_requests_updated_at
  BEFORE UPDATE ON prayer_requests
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE prayer_comments (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prayer_request_id  UUID NOT NULL REFERENCES prayer_requests(id) ON DELETE CASCADE,
  author_id          UUID REFERENCES users(id) ON DELETE SET NULL,
  author_role        user_role NOT NULL,
  message            TEXT NOT NULL,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_prayer_comments_request ON prayer_comments(prayer_request_id);

CREATE TABLE prayer_likes (
  prayer_request_id  UUID NOT NULL REFERENCES prayer_requests(id) ON DELETE CASCADE,
  user_id            UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (prayer_request_id, user_id)
);

-- =============================================================================
-- ANNOUNCEMENTS  ←  AnnouncementCategoryItem, AnnouncementItem
-- =============================================================================

CREATE TABLE announcement_categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL UNIQUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE announcements (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id   UUID NOT NULL REFERENCES announcement_categories(id) ON DELETE RESTRICT,
  author_id     UUID REFERENCES users(id) ON DELETE SET NULL,
  title         TEXT NOT NULL,
  message       TEXT NOT NULL,
  published     BOOLEAN NOT NULL DEFAULT TRUE,
  image_path    TEXT,
  document_url  TEXT,
  document_name TEXT,
  published_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_announcements_category ON announcements(category_id);
CREATE INDEX idx_announcements_published ON announcements(published, published_at DESC);

CREATE TRIGGER announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE announcement_reads (
  announcement_id  UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
  user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  read_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (announcement_id, user_id)
);

-- =============================================================================
-- BIBLE CONTENT  ←  BibleVerse, BibleStory
-- =============================================================================

CREATE TABLE bible_verses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text            TEXT NOT NULL,
  reference       TEXT NOT NULL,
  scheduled_date  DATE NOT NULL UNIQUE,
  language        TEXT NOT NULL DEFAULT 'am',
  image_url       TEXT,
  image_path      TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER bible_verses_updated_at
  BEFORE UPDATE ON bible_verses
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE user_settings (
  user_id                   UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  push_notifications        BOOLEAN NOT NULL DEFAULT TRUE,
  email_alerts              BOOLEAN NOT NULL DEFAULT TRUE,
  pending_approval_alerts   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE bible_stories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL,
  summary     TEXT NOT NULL DEFAULT '',
  image_url   TEXT,
  image_path  TEXT,
  published   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bible_stories_published ON bible_stories(published);

CREATE TRIGGER bible_stories_updated_at
  BEFORE UPDATE ON bible_stories
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- NOTIFICATIONS  ←  AppNotification / NotificationsStore
-- =============================================================================

CREATE TABLE notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
  type        app_notification_type NOT NULL,
  audience    notification_audience NOT NULL,
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  route       TEXT,
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_audience ON notifications(audience, is_read);

-- =============================================================================
-- SCORING CONFIG  ←  ScoringConfig / ScoringStore
-- =============================================================================

CREATE TABLE scoring_config (
  category        scoring_category PRIMARY KEY,
  weight_percent  NUMERIC(5, 2) NOT NULL CHECK (weight_percent >= 0 AND weight_percent <= 100),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER scoring_config_updated_at
  BEFORE UPDATE ON scoring_config
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- =============================================================================
-- USEFUL VIEWS (UI aggregates — not stored in Flutter today)
-- =============================================================================

CREATE OR REPLACE VIEW v_student_rankings AS
SELECT
  u.id AS student_id,
  u.full_name,
  pr.university,
  COALESCE(att.attendance_percent, 0) AS attendance_percent,
  COALESCE(lp.lessons_completed, 0) AS lessons_completed,
  COALESCE(lp.lessons_total, 0) AS lessons_total,
  COALESCE(asub.assignments_submitted, 0) AS assignments_submitted,
  COALESCE(asub.assignments_total, 0) AS assignments_total,
  COALESCE(qz.quiz_avg_score, 0) AS quiz_avg_score,
  ROUND(
    COALESCE(att.attendance_percent, 0) * (SELECT weight_percent FROM scoring_config WHERE category = 'attendance') / 100
    + COALESCE(qz.quiz_avg_score, 0) * (SELECT weight_percent FROM scoring_config WHERE category = 'quiz') / 100
    + COALESCE(asub.assignment_percent, 0) * (SELECT weight_percent FROM scoring_config WHERE category = 'assignment') / 100
  )::INTEGER AS overall_score
FROM users u
LEFT JOIN profiles pr ON pr.user_id = u.id
LEFT JOIN LATERAL (
  SELECT
    ROUND(100.0 * COUNT(*) FILTER (WHERE sar.physical_status = 'present' OR sar.online_marked) / NULLIF(COUNT(*), 0))::INTEGER AS attendance_percent
  FROM student_attendance_records sar
  WHERE sar.student_id = u.id
) att ON TRUE
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) FILTER (WHERE lpr.is_completed) AS lessons_completed,
    COUNT(*) AS lessons_total
  FROM lesson_progress lpr
  WHERE lpr.student_id = u.id
) lp ON TRUE
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) FILTER (WHERE s.status IN ('submitted', 'graded')) AS assignments_submitted,
    COUNT(*) AS assignments_total,
    ROUND(AVG(s.score) FILTER (WHERE s.score IS NOT NULL))::INTEGER AS assignment_percent
  FROM assignment_submissions s
  WHERE s.student_id = u.id
) asub ON TRUE
LEFT JOIN LATERAL (
  SELECT ROUND(AVG(qc.score))::INTEGER AS quiz_avg_score
  FROM quiz_completions qc
  WHERE qc.student_id = u.id
) qz ON TRUE
WHERE u.role = 'student' AND u.status = 'active';

-- =============================================================================
-- ROW LEVEL SECURITY — disabled (auth uses Supabase Auth only, no table RLS)
-- =============================================================================

ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE compassion_ids DISABLE ROW LEVEL SECURITY;
ALTER TABLE sponsors DISABLE ROW LEVEL SECURITY;
ALTER TABLE student_sponsorship_links DISABLE ROW LEVEL SECURITY;
ALTER TABLE sponsor_letters DISABLE ROW LEVEL SECURITY;
ALTER TABLE sponsor_letter_reads DISABLE ROW LEVEL SECURITY;
ALTER TABLE gifts DISABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_lessons DISABLE ROW LEVEL SECURITY;
ALTER TABLE assignments DISABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes DISABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions DISABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress DISABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_completions DISABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_submissions DISABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts DISABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE student_attendance_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE prayer_requests DISABLE ROW LEVEL SECURITY;
ALTER TABLE prayer_comments DISABLE ROW LEVEL SECURITY;
ALTER TABLE prayer_likes DISABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE announcements DISABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_reads DISABLE ROW LEVEL SECURITY;
ALTER TABLE bible_verses DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE bible_stories DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE scoring_config DISABLE ROW LEVEL SECURITY;

-- =============================================================================
-- SEED DATA (defaults matching Flutter mock data)
-- =============================================================================

INSERT INTO compassion_ids (project_id) VALUES
  ('KGC-COMP-001'),
  ('KGC-COMP-002'),
  ('KGC-COMP-003'),
  ('KGC-COMP-004'),
  ('KGC-COMP-005'),
  ('KGC-COMP-006'),
  ('KGC-COMP-007'),
  ('KGC-COMP-008')
ON CONFLICT (project_id) DO NOTHING;

INSERT INTO scoring_config (category, weight_percent) VALUES
  ('attendance', 40),
  ('quiz', 35),
  ('assignment', 25)
ON CONFLICT (category) DO UPDATE SET weight_percent = EXCLUDED.weight_percent;

INSERT INTO announcement_categories (id, name) VALUES
  ('00000000-0000-4000-8000-000000000001', 'General'),
  ('00000000-0000-4000-8000-000000000002', 'Events'),
  ('00000000-0000-4000-8000-000000000003', 'ET-221')
ON CONFLICT (name) DO NOTHING;

-- =============================================================================
-- STORAGE BUCKETS (run separately in Storage UI or uncomment below)
-- =============================================================================
-- INSERT INTO storage.buckets (id, name, public) VALUES
--   ('files', 'files', true),
--   ('announcements', 'announcements', true),
--   ('bible-content', 'bible-content', true),
--   ('assignments', 'assignments', false),
--   ('avatars', 'avatars', true)
-- ON CONFLICT (id) DO NOTHING;
