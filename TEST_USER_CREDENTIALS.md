# Test User Credentials

## Default Test User

The following test user has been configured for the Invoice System:

```
Email: admin@catering.test
Password: Password#
```

## How to Create This User

### Method 1: Using SQL Script (Recommended)

1. Open your Supabase project
2. Go to **SQL Editor**
3. Open and run `supabase/create_test_user.sql`
4. The script will create the user if it doesn't exist

### Method 2: Using Node.js Script

```bash
node supabase/create-user.js
```

Press Enter for all defaults to create the user with the credentials above.

### Method 3: Using Supabase Dashboard

1. Go to **Authentication** > **Users**
2. Click **"Add user"** > **"Create new user"**
3. Enter:
   - Email: `admin@catering.test`
   - Password: `Password#`
4. Check **"Auto Confirm Email"**
5. Click **"Create user"**

## Login

Once the user is created, you can login at:

```
http://localhost:5173/login
```

Use the credentials:

- Email: `admin@catering.test`
- Password: `Password#`

## Troubleshooting

### Email not confirmed

If you get an "Email not confirmed" error:

1. Go to Supabase Dashboard
2. Navigate to **Authentication** > **Users**
3. Find the user with email `admin@catering.test`
4. Click on the user's email
5. Click **"Confirm email"**

### User already exists

The SQL script automatically checks if the user exists and skips creation if it does. You can simply login with the existing credentials.

### Invalid login credentials

- Double-check the email and password
- Make sure you're using `admin@catering.test`
- Password is case-sensitive: `Password#` (with capital P)

### Email validation error

If you get an "Email address is invalid" error:

1. The SQL script method bypasses email validation
2. Use the SQL script instead of the Node.js script
3. Or use the Supabase Dashboard method with "Auto Confirm Email" enabled

## Security Note

⚠️ **Important**: These are default test credentials for development only.

**For production:**

- Change the password immediately
- Use a strong, unique password
- Enable email confirmation
- Consider implementing 2FA
- Regularly audit and rotate credentials

## Creating Additional Users

See [CREATE_TEST_USER.md](CREATE_TEST_USER.md) for detailed instructions on creating additional test users.

## Quick Reference

| Field           | Value                |
| --------------- | -------------------- |
| Email           | admin@catering.test  |
| Password        | Password#            |
| Full Name       | Admin User           |
| Role            | Admin                |
| Email Confirmed | Yes (auto-confirmed) |

## Why .test domain?

The `.test` domain is used because:

- ✅ It's a reserved TLD for testing purposes
- ✅ Supabase accepts it without requiring real email verification
- ✅ No risk of accidentally sending emails to real addresses
- ✅ Perfect for development and testing environments

---

**Ready to test!** 🚀

Start the development server:

```bash
npm run dev
```

Then visit: http://localhost:5173/login
