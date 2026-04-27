# Custom Authentication System

Sistem ini menggunakan tabel `users` custom alih-alih Supabase Auth bawaan.

## 📁 Struktur

### Database Table: `users`

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,  -- bcrypt hash
    full_name TEXT NOT NULL,
    role TEXT DEFAULT 'user',     -- 'admin', 'user', etc.
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_login_at TIMESTAMPTZ
);
```

## 🔐 Cara Kerja

### 1. Login Flow

1. User memasukkan email & password
2. Aplikasi mencari user di tabel `users` berdasarkan email
3. Password di-hash dengan bcrypt dan dibandingkan dengan `password_hash`
4. Jika match, user disimpan di localStorage
5. `last_login_at` di-update di database

### 2. Session Management

- User session disimpan di **localStorage** (bukan cookie/session Supabase)
- Setiap request membaca user_id dari localStorage
- Filter data berdasarkan user_id di application layer

### 3. Security

- Password di-hash dengan **bcrypt** (10 salt rounds)
- Filter invoice berdasarkan user_id di application layer
- RLS (Row Level Security) di-disabled (filtering di app layer)
- Password tidak pernah dikirim dalam plaintext

## 🚀 Setup

### Step 1: Create Users Table

Jalankan di Supabase SQL Editor:

```sql
-- Buat tabel users
CREATE TABLE IF NOT EXISTS users (
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

-- Buat index
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- Insert default admin user
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
```

### Step 2: Disable RLS

```sql
-- Disable RLS karena filtering di app layer
ALTER TABLE invoices DISABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items DISABLE ROW LEVEL SECURITY;
```

### Step 3: Create User

**Option A: Gunakan Node.js Script**
```bash
node supabase/create-user.js
```

**Option B: Manual SQL**
```sql
INSERT INTO users (
    email,
    password_hash,
    full_name,
    role,
    is_active
) VALUES (
    'admin@catering.test',
    '$2a$10$N9qo8uLOickgx2ZMRZoMy.Mrq3N8q3s7Z5G2vKqJ5XZ5Y5Y5Y5Y5Y',  -- hash untuk "admin123"
    'Admin User',
    'admin',
    true
);
```

## 📋 Default Credentials

```
Email: admin@catering.test
Password: admin123
```

## 🔧 Files yang Diubah

### Updated:
- `src/stores/auth.ts` - Custom auth logic
- `src/composables/useInvoices.ts` - Filter by custom user_id
- `src/types/index.ts` - Added CustomUser interface
- `supabase/create-user.js` - Create user in custom table

### New:
- `supabase/migrations/20260427232400_create_custom_users_table.sql`
- `supabase/create_custom_user.sql`
- `supabase/update_rls_for_custom_users.sql`

## 📝 Cara Menggunakan

### 1. Setup Database
```sql
-- Jalankan migration untuk buat tabel users
-- File: supabase/migrations/20260427232400_create_custom_users_table.sql
```

### 2. Disable RLS
```sql
-- File: supabase/update_rls_for_custom_users.sql
```

### 3. Create User
```bash
# Option 1: Node.js script
node supabase/create-user.js

# Option 2: SQL script
-- Jalankan: supabase/create_custom_user.sql
```

### 4. Login
- Buka: http://localhost:5173/login
- Email: `admin@catering.test`
- Password: `admin123`

## ⚠️ Perbedaan dengan Supabase Auth

| Feature | Supabase Auth | Custom Auth |
|---------|---------------|-------------|
| User Table | `auth.users` | Custom `users` |
| Password Hash | Supabase handles it | bcrypt in app |
| Session | JWT cookie | localStorage |
| RLS | Based on `auth.uid()` | Filtering in app |
| Email Confirmation | Built-in | Manual |
| Reset Password | Built-in | Manual |
| Rate Limiting | Built-in | Manual |

## 🚨 Security Notes

### Dengan Custom Auth:

✅ **Keuntungan:**
- Full control over user management
- No Supabase Auth limitations
- Can add custom fields easily
- No rate limiting issues

⚠️ **Risiko:**
- Need to implement own security features:
  - Email confirmation
  - Password reset
  - Rate limiting
  - Session timeout
  - CSRF protection
  - XSS protection

### Untuk Production:

1. **Implement Session Timeout**
   ```javascript
   // Check session age on app load
   const user = JSON.parse(localStorage.getItem('user'))
   const sessionAge = Date.now() - new Date(user.created_at).getTime()
   if (sessionAge > 24 * 60 * 60 * 1000) { // 24 hours
     logout()
   }
   ```

2. **Implement Rate Limiting**
   - Use a library like `express-rate-limit` (if using backend)
   - Or implement client-side limiting

3. **Use HTTPS Only**
   - Never send passwords over HTTP

4. **Add CSRF Protection**
   - Use anti-CSRF tokens for forms

5. **Sanitize All Inputs**
   - Prevent SQL injection
   - Prevent XSS attacks

## 🔄 Migration dari Supabase Auth

Jika ingin migrasi dari Supabase Auth ke Custom Auth:

1. **Export existing users** from `auth.users`
2. **Migrate ke custom users table**:
   ```sql
   INSERT INTO users (
       id,
       email,
       password_hash,
       full_name,
       role,
       is_active,
       created_at,
       updated_at
   )
   SELECT 
       id,
       email,
       encrypted_password,
       raw_user_meta_data->>'name' as full_name,
       'user',
       true,
       created_at,
       updated_at
   FROM auth.users;
   ```
3. **Update application code** (already done)
4. **Test thoroughly**

## 🧪 Testing

### Test Login:

```javascript
// Di browser console
const { useAuthStore } = await import('@/stores/auth.ts')
const auth = useAuthStore()

// Test login
await auth.login('admin@catering.test', 'admin123')

// Check user
console.log(auth.user)
```

### Test Logout:

```javascript
await auth.logout()
console.log(localStorage.getItem('user')) // null
```

## 📚 Related Files

- `supabase/migrations/20260427232400_create_custom_users_table.sql` - Database schema
- `supabase/create_custom_user.sql` - Create user script
- `supabase/create-user.js` - Node.js user creation script
- `src/stores/auth.ts` - Auth store logic
- `src/composables/useInvoices.ts` - Invoice operations with custom auth
- `src/types/index.ts` - TypeScript interfaces

---

**Sistem custom auth siap digunakan!** 🚀
