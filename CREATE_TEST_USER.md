# How to Create a Test User

This guide shows you 4 different ways to create a test user for the Invoice System.

## Method 1: Using SQL Script (Recommended - Fastest)

This is the quickest method to create a test user.

### Steps:

1. **Open Supabase Dashboard**
   - Go to your Supabase project
   - Click on **SQL Editor** in the left sidebar

2. **Run the Test User Script**
   - Click **New Query**
   - Open the file `supabase/create_test_user.sql` from your project
   - Copy all the SQL code
   - Paste it into the SQL Editor
   - Click **Run** (or press `Cmd/Ctrl + Enter`)

3. **Verify the User**
   - You should see the user details in the results
   - Check that email is confirmed

 4. **Login Credentials**
    ```
    Email: admin@homedecor.test
    Password: Password#
    ```

5. **Test Login**
   - Start the dev server: `npm run dev`
   - Go to http://localhost:5173/login
   - Enter the credentials above
   - Click **Login**

---

## Method 2: Using Node.js Script

This method gives you more control over user creation.

### Prerequisites:
- Make sure your `.env` file is configured with Supabase credentials

### Steps:

1. **Run the Script**
   ```bash
   node supabase/create-user.js
   ```

 2. **Follow the Prompts**
    - Enter email (or press Enter for default: admin@homedecor.test)
    - Enter password (or press Enter for default: Password#)
    - Enter full name (or press Enter for default: Admin User)

3. **Check Email Confirmation**
   - If email is not confirmed, go to Supabase Dashboard
   - Authentication > Users > Find user > Click "Confirm email"

4. **Login**
   - Use the credentials shown in the script output

---

## Method 3: Using Supabase Dashboard UI

The manual way through the Supabase interface.

### Steps:

1. **Go to Authentication**
   - In Supabase Dashboard, click **Authentication** in the left sidebar

2. **Click on Users**
   - Select **Users** tab

3. **Add New User**
   - Click **"Add user"** button
   - Select **"Create new user"**

 4. **Fill in User Details**
    - **Email**: `admin@homedecor.test`
    - **Password**: `Password#`
    - **Auto Confirm Email**: ✅ Check this box for testing

5. **Create User**
   - Click **"Create user"**

6. **Login**
   - Use the credentials you just created

---

## Method 4: Using Signup Form

Let users register themselves through the app (requires signup page).

### Steps:

1. **Create a Signup Page** (if not already created)
   - Similar to the login page
   - Use `supabase.auth.signUp()` instead of `signInWithPassword()`

2. **Users Can Register**
   - Users visit the signup page
   - Enter their email and password
   - System sends confirmation email (optional)

3. **Login**
   - After email confirmation, users can login

---

## Default Test User Credentials

If you use the SQL script or Node.js script with defaults:

```
Email: admin@homedecor.test
Password: Password#
```

**Security Note**: These are default test credentials. Change them in production!

---

## Troubleshooting

### Problem: "Email not confirmed" error

**Solution 1**: Confirm email in Supabase Dashboard
1. Go to Authentication > Users
2. Find the user
3. Click on their email
4. Click **"Confirm email"**

**Solution 2**: Disable email confirmation (for testing only)
1. Go to Authentication > Providers > Email
2. Toggle **"Confirm email"** to OFF
3. Now all new users are auto-confirmed

### Problem: "Invalid login credentials"

**Solutions**:
- Double-check email and password
- Make sure email is confirmed
- Check for typos in credentials
- Try creating a new user

### Problem: "User already exists"

**Solutions**:
- Use a different email address
- Or login with the existing user
- Or delete the existing user first

### Problem: SQL script fails with permission error

**Solution**: Make sure you're running the SQL as a database admin:
1. In SQL Editor, you should have admin privileges
2. If not, use Method 3 (Dashboard UI) instead

---

## Creating Multiple Test Users

### Using SQL Script:

Modify `supabase/create_test_user.sql` and add more INSERT statements:

```sql
-- First user
INSERT INTO auth.users (...) VALUES (...);

-- Second user
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
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'admin@homedecor.com',  -- Different email
    crypt('Admin123!', gen_salt('bf')),
    NOW(),
    '{"name": "Admin User", "role": "admin"}'::jsonb,
    NOW(),
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;
```

### Using Node.js Script:

Run the script multiple times with different emails:
```bash
node supabase/create-user.js
# Enter: admin@homedecor.com
# Enter: Admin123!
```

### Using Dashboard:

Simply repeat Method 3 for each user.

---

## Best Practices for Test Users

### 1. Use Distinct Emails
```
✅ admin@homedecor.test
✅ admin@homedecor.test (use different usernames)
✅ sales@homedecor.test
✅ finance@homedecor.test

❌ test@test.com (too generic)
```

### 2. Use Strong Passwords
```
✅ Password#
✅ Admin@2024!
✅ SecurePass123

❌ password (too weak)
❌ 123456 (too weak)
```

### 3. Organize by Role
```
- admin@homedecor.test (Default admin user)
- manager@homedecor.test (Manager)
- sales@homedecor.test (Sales staff)
- finance@homedecor.test (Finance staff)
```

### 4. Document Your Test Users

Create a `TEST_USERS.md` file:

```markdown
# Test Users

## Admin
- Email: admin@homedecor.com
- Password: Admin@2024!
- Role: Administrator
- Purpose: Testing admin features

## Sales
- Email: sales@homedecor.com
- Password: Sales@2024!
- Role: Sales Staff
- Purpose: Testing invoice creation

## Finance
- Email: finance@homedecor.com
- Password: Finance@2024!
- Role: Finance Staff
- Purpose: Testing invoice approval

## General Test
- Email: admin@homedecor.test
- Password: Password#
- Role: Admin User
- Purpose: General testing
```

---

## Next Steps After Creating Users

1. ✅ **Login with Test User**
   ```bash
   npm run dev
   # Go to http://localhost:5173/login
   ```

2. ✅ **Create Test Data**
   - Create a few test invoices
   - Add items to invoices
   - Test PDF download

3. ✅ **Test All Features**
   - Login/Logout
   - Create invoice
   - View invoice list
   - Download PDF
   - Delete invoice

4. ✅ **Test Edge Cases**
   - Empty fields
   - Invalid data
   - Large invoices
   - Multiple items

5. ✅ **Clean Up Test Data** (optional)
   ```sql
   -- Delete all invoices for a user
   DELETE FROM invoices WHERE user_id = 'user-uuid';
   ```

---

## Security Reminders

⚠️ **Important**: These are test credentials. Never use them in production!

### For Production:
- Require email confirmation
- Use strong passwords
- Enable 2FA (if available)
- Regularly audit users
- Remove unused test accounts
- Use proper password policies

### For Development:
- Disable email confirmation (optional)
- Use simple test passwords
- Create as many test users as needed
- Keep test users separate from production

---

## Quick Reference

| Method | Speed | Difficulty | Best For |
|--------|-------|------------|----------|
| SQL Script | ⚡⚡⚡ | Easy | Quick testing |
| Node.js Script | ⚡⚡ | Medium | Multiple users, custom data |
| Dashboard UI | ⚡ | Easy | One-off users |
| Signup Form | ⚡ | Medium | User registration |

---

## Need Help?

If you encounter issues:

1. Check the [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
2. Review SQL Editor logs for errors
3. Verify your `.env` configuration
4. Try a different method
5. Check the [Troubleshooting](#troubleshooting) section above

---

**Happy Testing! 🎉**
