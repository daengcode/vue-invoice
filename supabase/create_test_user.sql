-- Create Test User for Invoice System
-- Run this in Supabase SQL Editor to create a test user

-- Check if user already exists, then create if not
DO $$
DECLARE
    user_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count
    FROM auth.users
    WHERE email = 'admin@catering.test';

    IF user_count = 0 THEN
        -- Insert a test user into auth.users
        -- Email: admin@catering.test
        -- Password: Password#
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_user_meta_data,
            created_at,
            updated_at,
            last_sign_in_at
        ) VALUES (
            '00000000-0000-0000-0000-000000000000', -- instance_id
            gen_random_uuid(), -- user id (auto-generated)
            'authenticated',
            'authenticated',
            'admin@catering.test',
            crypt('Password#', gen_salt('bf')), -- encrypted password
            NOW(), -- email confirmed
            '{"name": "Admin User", "role": "admin"}'::jsonb,
            NOW(),
            NOW(),
            NOW()
        );
        RAISE NOTICE 'User created successfully!';
    ELSE
        RAISE NOTICE 'User already exists. Skipping creation.';
    END IF;
END $$;

-- Verification: Show the created user
SELECT
    id,
    email,
    email_confirmed_at,
    created_at,
    last_sign_in_at
FROM auth.users
WHERE email = 'admin@catering.test';

-- Note: If you see "1 row" in the results, the user exists (was just created or already existed)
-- You can now login with:
-- Email: admin@catering.test
-- Password: Password#
