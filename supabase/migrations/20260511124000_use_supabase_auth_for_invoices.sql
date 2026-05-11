-- Migration: Use Supabase Auth ownership for invoices
-- Created: 2026-05-11 12:40:00

-- New invoice rows must belong to an auth.users row so auth.uid() RLS policies work.
-- NOT VALID avoids failing this migration if old invoices still reference legacy public.users ids.
ALTER TABLE public.invoices DROP CONSTRAINT IF EXISTS invoices_user_id_fkey;

ALTER TABLE public.invoices
ADD CONSTRAINT invoices_user_id_fkey
FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE NOT VALID;

ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoice_items ENABLE ROW LEVEL SECURITY;
