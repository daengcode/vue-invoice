-- Diagnose Supabase Auth login error:
-- code: unexpected_failure
-- message: Database error querying schema

-- 1. Check whether public.invoices still has a foreign key to auth.users.
SELECT
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    confrelid::regclass AS referenced_table,
    pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE conrelid = 'public.invoices'::regclass
  AND contype = 'f';

-- 2. Drop the invoice user FK if it exists. RLS only needs auth.uid() = user_id.
ALTER TABLE public.invoices DROP CONSTRAINT IF EXISTS invoices_user_id_fkey;

-- 3. Verify the auth user exists.
SELECT
    id,
    email,
    email_confirmed_at,
    created_at
FROM auth.users
WHERE email = 'admin@catering.test';

-- 4. Verify invoices are mapped to real auth user emails.
SELECT
    invoices.user_id,
    auth.users.email,
    COUNT(*) AS invoice_count
FROM public.invoices
LEFT JOIN auth.users ON auth.users.id = invoices.user_id
GROUP BY invoices.user_id, auth.users.email
ORDER BY invoice_count DESC;

-- 5. Verify RLS is enabled on exposed tables.
SELECT
    schemaname,
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('invoices', 'invoice_items');
