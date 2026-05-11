-- Migration: Drop direct auth.users FK from invoices
-- Created: 2026-05-11 12:50:00

-- Keep invoices.user_id as the Supabase Auth user UUID, but do not keep a direct
-- foreign key to auth.users. RLS only needs auth.uid() to match this UUID, and
-- avoiding the cross-schema FK prevents PostgREST schema introspection issues.
ALTER TABLE public.invoices DROP CONSTRAINT IF EXISTS invoices_user_id_fkey;

ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoice_items ENABLE ROW LEVEL SECURITY;
