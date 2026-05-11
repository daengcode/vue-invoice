-- Repair Supabase Auth login error:
-- {"code":"unexpected_failure","message":"Database error querying schema"}
--
-- Run this in Supabase SQL Editor.

-- 1. Hosted Supabase does not allow modifying the reserved supabase_auth_admin role.
-- If Auth still fails after this repair, check Auth Logs for the exact internal query error.

-- 2. Fix malformed auth.users rows created manually by SQL/imports.
-- GoTrue can fail login if these text token columns are NULL.
DO $$
DECLARE
    token_column TEXT;
BEGIN
    FOREACH token_column IN ARRAY ARRAY[
        'confirmation_token',
        'email_change',
        'email_change_token_new',
        'recovery_token',
        'reauthentication_token'
    ]
    LOOP
        IF EXISTS (
            SELECT 1
            FROM information_schema.columns
            WHERE table_schema = 'auth'
              AND table_name = 'users'
              AND columns.column_name = token_column
        ) THEN
            EXECUTE format(
                'UPDATE auth.users SET %I = '''' WHERE %I IS NULL',
                token_column,
                token_column
            );
        END IF;
    END LOOP;
END $$;

-- 3. Diagnose RLS on Auth internal tables.
-- Hosted Supabase SQL Editor may not own these tables, so do not try to alter them here.
-- If any auth table shows rls_enabled = true and login still fails, restart the project
-- from the dashboard or contact Supabase support with this diagnostic output.
SELECT
    tablename AS auth_table,
    rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'auth'
ORDER BY tablename;

-- 4. Keep app tables secured.
ALTER TABLE public.invoices DROP CONSTRAINT IF EXISTS invoices_user_id_fkey;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoice_items ENABLE ROW LEVEL SECURITY;

-- 5. Diagnostics to confirm the state after repair.
SELECT
    relname AS auth_table,
    relrowsecurity AS rls_enabled,
    relforcerowsecurity AS force_rls
FROM pg_class
JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
WHERE pg_namespace.nspname = 'auth'
  AND pg_class.relkind = 'r'
ORDER BY relname;

SELECT
    id,
    email,
    email_confirmed_at,
    confirmation_token IS NULL AS confirmation_token_is_null,
    email_change IS NULL AS email_change_is_null,
    email_change_token_new IS NULL AS email_change_token_new_is_null,
    recovery_token IS NULL AS recovery_token_is_null
FROM auth.users
WHERE email = 'admin@catering.test';
