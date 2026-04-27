# User Credentials Updated - Using .test Domain

## ✅ Changes Made

All test user credentials have been updated to use a `.test` domain for better compatibility:
- **Email**: `admin@homedecor.test`
- **Password**: `Password#`

## 📝 Why .test Domain?

The `.test` domain is used because:
- ✅ It's a reserved top-level domain for testing purposes
- ✅ Supabase accepts it without requiring real email verification
- ✅ No risk of accidentally sending emails to real addresses
- ✅ Avoids "Email address is invalid" errors
- ✅ Perfect for development and testing environments

## 📝 Files Updated

### 1. SQL Script
**File**: `supabase/create_test_user.sql`
- ✅ Updated email to `admin@homedecor.test`
- ✅ Updated password to `Password#`
- ✅ Fixed ON CONFLICT error by using DO block with conditional check
- ✅ Script now checks if user exists before attempting insertion
- ✅ Bypasses email validation (works directly in database)

### 2. Node.js Script
**File**: `supabase/create-user.js`
- ✅ Updated default email to `admin@homedecor.test`
- ✅ Updated default password to `Password#`
- ✅ Updated default full name to `Admin User`

### 3. Documentation Files

**README.md**
- ✅ Updated default credentials in setup instructions

**IMPLEMENTATION_SUMMARY.md**
- ✅ Updated test user creation instructions with new credentials

**DATABASE_SETUP.md**
- ✅ Updated Step 6 with new credentials

**CREATE_TEST_USER.md**
- ✅ Updated Method 1 credentials
- ✅ Updated Method 2 prompts
- ✅ Updated Method 3 user details
- ✅ Updated default credentials section
- ✅ Updated best practices examples

**TEST_USER_CREDENTIALS.md**
- ✅ Complete rewrite with new credentials
- ✅ Added troubleshooting for email validation errors
- ✅ Added explanation of .test domain benefits

## 🔐 Login Credentials

```
Email: admin@homedecor.test
Password: Password#
```

## 🚀 Quick Start

### Option 1: Run SQL Script (Recommended - Bypasses Email Validation)

1. Open Supabase Dashboard
2. Go to **SQL Editor**
3. Run `supabase/create_test_user.sql`
4. Login at: http://localhost:5173/login

**Note**: This method creates the user directly in the database and bypasses email validation checks.

### Option 2: Run Node.js Script

```bash
node supabase/create-user.js
```

Press Enter for all defaults.

**Note**: May require email confirmation to be disabled in Supabase settings.

### Option 3: Create via Dashboard

1. Go to **Authentication** > **Users**
2. Click **"Add user"** > **"Create new user"**
3. Email: `admin@homedecor.test`
4. Password: `Password#`
5. Check **"Auto Confirm Email"**
6. Click **"Create user"**

**Note**: Requires "Auto Confirm Email" to be enabled.

## 📋 Verification

To verify the user was created successfully:

```sql
SELECT
    id,
    email,
    email_confirmed_at,
    created_at
FROM auth.users
WHERE email = 'admin@homedecor.test';
```

You should see 1 row with `email_confirmed_at` populated.

## 🔧 Fixing Email Validation Issues

If you encounter "Email address is invalid" errors:

### Solution 1: Use SQL Script (Recommended)
The SQL script bypasses email validation by inserting directly into the database.

### Solution 2: Disable Email Confirmation
1. Go to Supabase Dashboard
2. **Authentication** > **Providers** > **Email**
3. Toggle **"Confirm email"** to OFF
4. Now the Node.js script will work

### Solution 3: Use Dashboard with Auto-Confirm
When creating via Dashboard, always check "Auto Confirm Email" box.

## ⚠️ Important Notes

1. **Password Case Sensitivity**: Password is case-sensitive
   - Correct: `Password#` (capital P)
   - Wrong: `password#` (lowercase p)

2. **Email Domain**: Using `.test` domain
   - This is a reserved domain for testing
   - No real emails will be sent
   - Perfect for development

3. **Email Confirmation**: The SQL script auto-confirms the email
   - If creating via Dashboard, check "Auto Confirm Email"
   - If using Node.js script, disable email confirmation in settings

4. **Error Handling**: The SQL script now handles duplicate users gracefully
   - If user exists, it skips creation
   - No more ON CONFLICT errors

## 🐛 Bugs Fixed

### Bug 1: ON CONFLICT Error
**Issue**: `ERROR: 42P10: there is no unique or exclusion constraint matching the ON CONFLICT specification`

**Solution**: Replaced `ON CONFLICT (email) DO NOTHING` with a DO block that checks if user exists before insertion.

### Bug 2: Email Validation Error
**Issue**: `Email address "admin@gmail.com" is invalid`

**Solution**: Changed to `.test` domain (`admin@homedecor.test`) which:
- Is accepted by Supabase for testing
- Doesn't require real email verification
- Bypasses email validation when using SQL script

## 📚 Documentation

For more details, see:
- [TEST_USER_CREDENTIALS.md](TEST_USER_CREDENTIALS.md) - Quick reference
- [CREATE_TEST_USER.md](CREATE_TEST_USER.md) - Complete guide

## ✨ Next Steps

1. ✅ Run the SQL script to create the user (recommended)
2. ✅ Start the development server: `npm run dev`
3. ✅ Login at: http://localhost:5173/login
4. ✅ Test the application with the new credentials

## 🎯 Best Practice

For development and testing, always use the SQL script method (`supabase/create_test_user.sql`) because:
- ✅ Bypasses email validation
- ✅ Auto-confirms email
- ✅ Handles duplicate users gracefully
- ✅ No need to modify Supabase settings
- ✅ Works consistently across all environments

---

**All credentials have been successfully updated to use .test domain!** 🎉
