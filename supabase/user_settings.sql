-- User notification preferences (admin settings screen)
CREATE TABLE IF NOT EXISTS user_settings (
  user_id                   UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  push_notifications        BOOLEAN NOT NULL DEFAULT TRUE,
  email_alerts              BOOLEAN NOT NULL DEFAULT TRUE,
  pending_approval_alerts   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS user_settings_updated_at ON user_settings;
CREATE TRIGGER user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE user_settings DISABLE ROW LEVEL SECURITY;
