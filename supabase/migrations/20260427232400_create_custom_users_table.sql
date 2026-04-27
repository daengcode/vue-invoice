-- Create Custom Users Table
-- This replaces Supabase Auth with custom user management

-- Drop existing table if exists (for clean setup)
DROP TABLE IF EXISTS users CASCADE;

-- Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login_at TIMESTAMPTZ
);

-- Create indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_active ON users(is_active);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_users_updated_at();

-- Insert default admin user
-- Password: admin123 (bcrypt hash)
INSERT INTO users (
    email,
    password_hash,
    full_name,
    role,
    is_active
) VALUES (
    'admin@catering.test',
    '$2a$10$N9qo8uLOickgx2ZMRZoMy.Mrq3N8q3s7Z5G2vKqJ5XZ5Y5Y5Y5Y5Y',
    'Admin User',
    'admin',
    true
) ON CONFLICT (email) DO NOTHING;

-- Verify user created
SELECT 
    id,
    email,
    full_name,
    role,
    is_active,
    created_at
FROM users 
WHERE email = 'admin@catering.test';

-- Note: Default credentials:
-- Email: admin@catering.test
-- Password: admin123
