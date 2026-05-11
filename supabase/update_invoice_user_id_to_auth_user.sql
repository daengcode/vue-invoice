-- Update existing invoices to belong to a Supabase Auth user.
-- Run this manually in Supabase SQL Editor after creating the auth user.

DO $$
DECLARE
    target_email TEXT := 'admin@catering.test';
    target_user_id UUID;
BEGIN
    SELECT id
    INTO target_user_id
    FROM auth.users
    WHERE email = target_email
    LIMIT 1;

    IF target_user_id IS NULL THEN
        RAISE EXCEPTION 'No Supabase Auth user found for email: %', target_email;
    END IF;

    UPDATE public.invoices
    SET user_id = target_user_id
    WHERE user_id IS DISTINCT FROM target_user_id;

    RAISE NOTICE 'Updated invoices.user_id to auth user % (%)', target_email, target_user_id;
END $$;

-- Verify all invoices now belong to the target auth user.
SELECT
    invoices.user_id,
    auth.users.email,
    COUNT(*) AS invoice_count
FROM public.invoices
LEFT JOIN auth.users ON auth.users.id = invoices.user_id
GROUP BY invoices.user_id, auth.users.email
ORDER BY invoice_count DESC;
