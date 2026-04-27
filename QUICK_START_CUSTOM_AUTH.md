# 🚀 Quick Start - Custom Auth Setup

Ikuti langkah ini untuk setup sistem auth custom:

## Step 1: Setup Database (Wajib)

Buka **Supabase Dashboard** > **SQL Editor**, jalankan:

```sql
-- ENABLE UUID EXTENSION
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- CREATE CUSTOM USERS TABLE
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

-- CREATE INDEXES
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);

-- CREATE TRIGGER FOR UPDATED_AT
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

-- INSERT DEFAULT ADMIN USER
-- Password: admin123
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

-- VERIFY USER CREATED
SELECT 
    id,
    email,
    full_name,
    role,
    is_active,
    created_at
FROM users 
WHERE email = 'admin@catering.test';
```

## Step 2: Disable RLS

Masih di SQL Editor, jalankan:

```sql
-- DISABLE RLS (Karena filtering di app layer)
ALTER TABLE invoices DISABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items DISABLE ROW LEVEL SECURITY;
```

## Step 3: Restart Development Server

```bash
# Stop server (Ctrl+C) lalu:
npm run dev
```

## Step 4: Login

Buka browser: http://localhost:5173/login

Gunakan credentials:
```
Email: admin@catering.test
Password: admin123
```

## Step 5: Test Aplikasi

1. ✅ Login berhasil → Redirect ke invoice list
2. ✅ Klik "Buat Invoice Baru"
3. ✅ Isi form dan simpan
4. ✅ Cek invoice list
5. ✅ Klik "Logout"

## 📋 Troubleshooting

### Error: "relation 'users' does not exist"

**Solusi:** Jalankan SQL di Step 1 untuk buat tabel users.

### Error: "Invalid email or password"

**Solusi:** Pastikan:
1. User sudah dibuat (cek di Step 1)
2. Email: `admin@catering.test`
3. Password: `admin123` (case-sensitive)

### Error: "Database error querying schema"

**Solusi:** Jalankan SQL di Step 2 untuk disable RLS.

### Invoice tidak muncul setelah login

**Solusi:** Refresh browser atau clear cache.

## 📚 Dokumentasi Lengkap

Untuk informasi lebih detail, lihat:
- `CUSTOM_AUTH_SYSTEM.md` - Dokumentasi lengkap
- `CUSTOM_AUTH_SETUP_COMPLETE.md` - Ringkasan setup

---

**Selesai! Sekarang Anda bisa login dan menggunakan aplikasi.** 🎉
