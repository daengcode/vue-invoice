# ⚠️ Email Domain Changed to Fix Validation Error

## Problem

When using the Node.js script to create a user with `admin@gmail.com`, Supabase returned:
```
❌ Error creating user: Email address "admin@gmail.com" is invalid
```

This happens because:
- Gmail and other major email providers have strict validation
- Supabase may block certain domains for security reasons
- Some domains require real email verification

## Solution ✅

Changed to `.test` domain:
```
Old: admin@gmail.com
New: admin@homedecor.test
```

## Why .test Domain?

✅ **Reserved for testing** - It's an official reserved TLD for testing
✅ **No email validation** - Supabase accepts it without validation
✅ **No real emails** - No risk of sending emails to real addresses
✅ **Works everywhere** - Consistent across all environments
✅ **Bypasses validation** - SQL script creates user directly in database

## Updated Files

All files have been updated with the new credentials:

### Core Files
- ✅ `supabase/create_test_user.sql` - SQL script
- ✅ `supabase/create-user.js` - Node.js script

### Documentation
- ✅ `README.md`
- ✅ `TEST_USER_CREDENTIALS.md`
- ✅ `CREDENTIALS_UPDATED.md`
- ✅ `IMPLEMENTATION_SUMMARY.md`
- ✅ `DATABASE_SETUP.md`
- ✅ `CREATE_TEST_USER.md`

## New Credentials

```
Email: admin@homedecor.test
Password: Password#
```

## How to Create User (Recommended)

### Method 1: SQL Script (Best Option)
```bash
# In Supabase Dashboard, open SQL Editor and run:
cat supabase/create_test_user.sql
```

**Advantages:**
- ✅ Bypasses email validation
- ✅ Auto-confirms email
- ✅ No Supabase settings changes needed
- ✅ Works consistently

### Method 2: Node.js Script
```bash
node supabase/create-user.js
```

**Note:** May require disabling email confirmation in Supabase settings.

### Method 3: Dashboard UI
1. Go to Authentication > Users
2. Add user > Create new user
3. Email: `admin@homedecor.test`
4. Password: `Password#`
5. Check "Auto Confirm Email"
6. Click "Create user"

## Verification

Run this SQL to verify user exists:

```sql
SELECT
    id,
    email,
    email_confirmed_at,
    created_at
FROM auth.users
WHERE email = 'admin@homedecor.test';
```

Expected result: 1 row with email_confirmed_at populated

## Next Steps

1. ✅ **Run SQL script** (recommended method)
   ```bash
   # Open Supabase Dashboard > SQL Editor
   # Run: supabase/create_test_user.sql
   ```

2. ✅ **Start development server**
   ```bash
   npm run dev
   ```

3. ✅ **Login**
   - Go to: http://localhost:5173/login
   - Email: `admin@homedecor.test`
   - Password: `Password#`

4. ✅ **Test the application**
   - Create an invoice
   - Add items
   - Download PDF

## Troubleshooting

### Still getting "Email address is invalid"?

**Solution:** Use the SQL script method (Method 1 above). It bypasses all email validation.

### User already exists?

**Solution:** That's fine! The SQL script handles this gracefully. Just login with the credentials.

### Can't login?

**Check:**
1. Email: `admin@homedecor.test` (not .com)
2. Password: `Password#` (capital P)
3. Email is confirmed (SQL script auto-confirms)

## Summary

| Aspect | Old | New |
|--------|-----|-----|
| Email | admin@gmail.com | admin@homedecor.test |
| Password | Password# | Password# |
| Domain Type | Real email provider | Reserved test domain |
| Validation | Required | Bypassed (SQL method) |
| Email Confirmation | May be required | Auto-confirmed |
| Reliability | May fail | Always works |

## Quick Command

Create user immediately:

```sql
-- Copy and paste into Supabase SQL Editor
DO $$
DECLARE
    user_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count
    FROM auth.users
    WHERE email = 'admin@homedecor.test';

    IF user_count = 0 THEN
        INSERT INTO auth.users (
            instance_id, id, aud, role, email,
            encrypted_password, email_confirmed_at,
            raw_user_meta_data, created_at, updated_at, last_sign_in_at
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            gen_random_uuid(),
            'authenticated', 'authenticated',
            'admin@homedecor.test',
            crypt('Password#', gen_salt('bf')),
            NOW(),
            '{"name": "Admin User", "role": "admin"}'::jsonb,
            NOW(), NOW(), NOW()
        );
        RAISE NOTICE 'User created successfully!';
    ELSE
        RAISE NOTICE 'User already exists.';
    END IF;
END $$;
```

---

**Ready to go! Use admin@homedecor.test / Password#** 🚀
