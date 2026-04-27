# Custom Auth System - Setup Complete

## ✅ Apa yang Sudah Dilakukan

Sistem autentikasi telah diubah dari **Supabase Auth** ke **Custom Users Table**.

## 📝 Langkah yang Dilakukan:

### 1. Created Custom Users Table
- ✅ File: `supabase/migrations/20260427232400_create_custom_users_table.sql`
- ✅ Table: `users` dengan kolom id, email, password_hash, full_name, role, dll.
- ✅ Default admin user di-insert

### 2. Updated Authentication Logic
- ✅ `src/stores/auth.ts` - Login menggunakan custom users table
- ✅ Password hashing dengan bcrypt
- ✅ Session disimpan di localStorage

### 3. Updated Invoice Operations
- ✅ `src/composables/useInvoices.ts` - Filter by custom user_id
- ✅ fetchInvoices hanya mengambil invoice milik user yang login

### 4. Disabled RLS
- ✅ File: `supabase/update_rls_for_custom_users.sql`
- ✅ Filtering dilakukan di application layer, bukan database level

### 5. Created User Management Tools
- ✅ `supabase/create-user.js` - Node.js script untuk create user
- ✅ `supabase/create_custom_user.sql` - SQL script untuk create user

### 6. Updated Types
- ✅ `src/types/index.ts` - Added `CustomUser` interface

### 7. Installed Dependencies
- ✅ `bcrypt` - Untuk password hashing

## 🚀 Cara Setup:

### Step 1: Create Custom Users Table

Di Supabase Dashboard > SQL Editor, jalankan:

```bash
# File: supabase/migrations/20260427232400_create_custom_users_table.sql
```

Atau copy-paste SQL dari file tersebut.

### Step 2: Disable RLS

Di SQL Editor, jalankan:

```bash
# File: supabase/update_rls_for_custom_users.sql
```

### Step 3: Create Admin User

**Option A: Node.js Script (Recommended)**
```bash
node supabase/create-user.js
```
Tekan Enter untuk semua defaults:
- Email: `admin@catering.test`
- Password: `admin123`

**Option B: SQL Script**
```bash
# File: supabase/create_custom_user.sql
```

### Step 4: Restart Dev Server

```bash
# Stop server (Ctrl+C) lalu:
npm run dev
```

### Step 5: Login

Buka: http://localhost:5173/login

Credentials:
```
Email: admin@catering.test
Password: admin123
```

## 📊 Perubahan Arsitektur:

### Sebelum (Supabase Auth):
```
Login → Supabase Auth API → JWT Cookie → Application
```

### Sesudah (Custom Auth):
```
Login → App → Check Custom Users Table → bcrypt → localStorage → Application
```

## 🔐 Security:

✅ Password di-hash dengan bcrypt (10 salt rounds)
✅ Filter invoice by user_id di application layer
✅ Session di localStorage
⚠️ Perlu tambahkan: rate limiting, session timeout, CSRF protection (untuk production)

## 📁 File yang Diubah/Baru:

### Updated Files:
- `src/stores/auth.ts`
- `src/composables/useInvoices.ts`
- `src/types/index.ts`
- `supabase/create-user.js`

### New Files:
- `supabase/migrations/20260427232400_create_custom_users_table.sql`
- `supabase/create_custom_user.sql`
- `supabase/update_rls_for_custom_users.sql`
- `CUSTOM_AUTH_SYSTEM.md`

## 🧪 Testing:

### Test 1: Login
1. Buka http://localhost:5173/login
2. Email: `admin@catering.test`
3. Password: `admin123`
4. Login berhasil → Redirect ke invoice list

### Test 2: Create Invoice
1. Klik "Buat Invoice Baru"
2. Isi form
3. Simpan → Invoice dibuat dengan user_id yang benar

### Test 3: Logout
1. Klik "Logout"
2. Redirect ke login page
3. localStorage kosong

### Test 4: Session Persistence
1. Login
2. Refresh page
3. Masih login (user di localStorage)

## 🎯 Default Credentials:

```
Email: admin@catering.test
Password: admin123
```

## 📚 Documentation:

- `CUSTOM_AUTH_SYSTEM.md` - Dokumentasi lengkap custom auth
- `README.md` - Main documentation

## ⚠️ Catatan Penting:

1. **Tidak lagi menggunakan Supabase Auth**
   - Tidak ada email confirmation otomatis
   - Tidak ada password reset otomatis
   - Tidak ada rate limiting otomatis

2. **Filtering di Application Layer**
   - RLS di-disabled
   - Filter berdasarkan user_id di kode aplikasi
   - Pastikan selalu filter by user_id di query

3. **Session di localStorage**
   - Mudah diimplementasikan
   - Butuh session timeout untuk production
   - Butuh CSRF protection

## 🚀 Next Steps:

1. ✅ Jalankan setup SQL di atas
2. ✅ Restart dev server
3. ✅ Test login
4. ✅ Test create invoice
5. ✅ Test logout

---

**Custom auth system siap digunakan!** 🎉
