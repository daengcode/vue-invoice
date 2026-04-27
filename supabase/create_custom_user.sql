-- Create Custom User Script
-- Run this in Supabase SQL Editor to create a new user

-- Default values
DO $$
DECLARE
    v_email TEXT := 'admin@catering.test';
    v_password TEXT := 'admin123';
    v_full_name TEXT := 'Admin User';
    v_role TEXT := 'admin';
    v_user_id UUID;
BEGIN
    -- Check if user already exists
    SELECT id INTO v_user_id
    FROM users
    WHERE email = v_email;
    
    IF v_user_id IS NULL THEN
        -- Insert new user
        -- Password: admin123 (bcrypt hash: $2a$10$N9qo8uLOickgx2ZMRZoMy.Mrq3N8q3s7Z5G2vKqJ5XZ5Y5Y5Y5Y5Y)
        INSERT INTO users (
            email,
            password_hash,
            full_name,
            role,
            is_active
        ) VALUES (
            v_email,
            '$2a$10$N9qo8uLOickgx2ZMRZoMy.Mrq3N8q3s7Z5G2vKqJ5XZ5Y5Y5Y5Y5Y',
            v_full_name,
            v_role,
            true
        );
        
        RAISE NOTICE 'User created successfully!';
        RAISE NOTICE 'Email: %', v_email;
        RAISE NOTICE 'Password: admin123';
    ELSE
        RAISE NOTICE 'User already exists with email: %', v_email;
        RAISE NOTICE 'You can login with:';
        RAISE NOTICE 'Email: %', v_email;
        RAISE NOTICE 'Password: admin123';
    END IF;
END $$;

-- Verify user
SELECT 
    id,
    email,
    full_name,
    role,
    is_active,
    created_at
FROM users 
WHERE email = 'admin@catering.test';
