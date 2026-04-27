# Foreign Key Updated - Auth to Custom Users

## ✅ Perubahan yang Dilakukan

Foreign key constraint di tabel `invoices` telah diupdate dari `auth.users(id)` ke `users(id)` (custom users table).

## 📝 Files yang Diupdate:

### 1. Migration Files
- ✅ `supabase/migrations/20260427224700_create_invoice_tables.sql`
  - Line 22: `user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE`

### 2. Quick Setup File
- ✅ `supabase/quick_setup.sql`
  - Line 23: `user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE`

### 3. Schema File
- ✅ `supabase/schema.sql`
  - Line 19: `user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE`

### 4. New Migration
- ✅ `supabase/migrations/20260427233000_update_invoices_user_fk.sql`
  - Migration untuk update foreign key pada database yang sudah ada

## 🔄 Database Schema Changes

### Sebelum:
```sql
CREATE TABLE invoices (
    -- ... other columns ...
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
);
```

### Sesudah:
```sql
CREATE TABLE invoices (
    -- ... other columns ...
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE
);
```

## 🚀 Cara Update Database yang Sudah Ada

Jika database sudah ada (invoice dan users table sudah dibuat), jalankan migration ini:

**Di Supabase Dashboard > SQL Editor:**

```sql
-- Update Foreign Key Constraint
-- File: supabase/migrations/20260427233000_update_invoices_user_fk.sql

-- Drop existing foreign key
ALTER TABLE invoices DROP CONSTRAINT IF EXISTS invoices_user_id_fkey;

-- Add new foreign key to custom users table
ALTER TABLE invoices 
ADD CONSTRAINT invoices_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
```

## 📊 Impact

### Positive:
- ✅ **Data Integrity Terjaga**: Foreign key sekarang mengarah ke tabel yang benar
- ✅ **Cascade Delete**: Jika user dihapus, semua invoice milik user tersebut juga dihapus
- ✅ **Referential Integrity**: Mencegah invoice tanpa user yang valid
- ✅ **Consistent**: Foreign key sekarang konsisten dengan custom auth system

### What This Means:
- Setiap invoice HARUS memiliki user_id yang valid di tabel `users`
- Tidak bisa membuat invoice dengan user_id yang tidak ada
- Jika user dihapus, semua invoice milik user tersebut otomatis dihapus
- Relasi antara invoice dan user sekarang benar-benar terjaga

## 🧪 Testing

### Test 1: Cek Foreign Key Constraint

```sql
SELECT 
    conname AS constraint_name,
    pg_get_constraintdef(c.oid) AS constraint_definition
FROM pg_constraint c
JOIN pg_namespace n ON n.oid = c.connamespace
JOIN pg_class cl ON cl.oid = c.conrelid
WHERE cl.relname = 'invoices'
AND conname = 'invoices_user_id_fkey';
```

Hasil harus menampilkan:
```
constraint_name: invoices_user_id_fkey
constraint_definition: FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
```

### Test 2: Coba Create Invoice dengan Invalid User

```sql
-- Ini seharusnya GAGAL karena user_id tidak ada
INSERT INTO invoices (
    invoice_number,
    invoice_date,
    due_date,
    customer_name,
    user_id
) VALUES (
    'TEST001',
    NOW(),
    NOW(),
    'Test Customer',
    '00000000-0000-0000-0000-000000000000'  -- Invalid user_id
);
```

Hasil: `ERROR: insert or update on table "invoices" violates foreign key constraint`

### Test 3: Coba Delete User yang Punya Invoice

```sql
-- Ambil user_id yang punya invoice
SELECT user_id, COUNT(*) as invoice_count
FROM invoices
GROUP BY user_id;

-- Coba delete user tersebut
DELETE FROM users WHERE id = 'user_id_dari_query_di_atas';
```

Hasil: Semua invoice milik user tersebut juga dihapus (CASCADE DELETE)

## 📝 Perubahan Lain yang Perlu Dilakukan

### 1. Jika Ada Invoice dengan Invalid user_id

Cek apakah ada invoice yang user_id-nya tidak valid:

```sql
-- Cari invoice dengan user_id yang tidak ada di users table
SELECT i.*
FROM invoices i
LEFT JOIN users u ON i.user_id = u.id
WHERE u.id IS NULL;
```

Jika ada, hapus atau perbaiki:

```sql
-- Option A: Hapus invoice dengan invalid user_id
DELETE FROM invoices
WHERE user_id NOT IN (SELECT id FROM users);

-- Option B: Atau update ke user yang valid
-- UPDATE invoices
-- SET user_id = 'valid_user_id'
-- WHERE user_id = 'invalid_user_id';
```

### 2. Update RLS Policies (Jika di-enabled)

Jika RLS di-enable di masa depan, policies harus menggunakan tabel `users` bukan `auth.users`:

```sql
-- Example RLS policy untuk custom users
CREATE POLICY "Users can view their own invoices"
    ON invoices FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.id = invoices.user_id
            AND users.email = current_setting('app.current_user_email', true)
        )
    );
```

## 🎯 Diagram Relasi Baru

```
users (Custom Auth Table)
├── id (PK)
├── email
├── password_hash
└── ...

    │
    │ user_id (FK)
    │
    ▼
invoices
├── id (PK)
├── invoice_number
├── customer_name
├── user_id (FK → users.id)
└── ...

    │
    │ invoice_id (FK)
    │
    ▼
invoice_items
├── id (PK)
├── invoice_id (FK → invoices.id)
└── ...
```

## 📚 Summary

- ✅ Foreign key diupdate ke `users(id)`
- ✅ Semua migration files diupdate
- ✅ Cascade delete tetap aktif
- ✅ Data integrity terjaga
- ✅ Database schema konsisten dengan custom auth system

---

**Foreign key sekarang sudah mengarah ke custom users table!** 🎉
