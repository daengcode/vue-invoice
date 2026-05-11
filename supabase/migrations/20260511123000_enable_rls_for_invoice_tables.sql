-- Migration: Enable RLS for invoice tables
-- Created: 2026-05-11 12:30:00

-- Security advisor fix:
-- Tables exposed through PostgREST must have Row Level Security enabled.
-- This resolves warnings for existing policies such as "Users can manage their invoice_items".
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoice_items ENABLE ROW LEVEL SECURITY;

-- Recreate ownership policies in case they were removed by a manual SQL script.
DROP POLICY IF EXISTS "Users can view their own invoices" ON public.invoices;
DROP POLICY IF EXISTS "Users can insert their own invoices" ON public.invoices;
DROP POLICY IF EXISTS "Users can update their own invoices" ON public.invoices;
DROP POLICY IF EXISTS "Users can delete their own invoices" ON public.invoices;

CREATE POLICY "Users can view their own invoices"
    ON public.invoices FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own invoices"
    ON public.invoices FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own invoices"
    ON public.invoices FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own invoices"
    ON public.invoices FOR DELETE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view items from their invoices" ON public.invoice_items;
DROP POLICY IF EXISTS "Users can insert items to their invoices" ON public.invoice_items;
DROP POLICY IF EXISTS "Users can update items from their invoices" ON public.invoice_items;
DROP POLICY IF EXISTS "Users can delete items from their invoices" ON public.invoice_items;

CREATE POLICY "Users can view items from their invoices"
    ON public.invoice_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.invoices
            WHERE invoices.id = invoice_items.invoice_id
              AND invoices.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert items to their invoices"
    ON public.invoice_items FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.invoices
            WHERE invoices.id = invoice_items.invoice_id
              AND invoices.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update items from their invoices"
    ON public.invoice_items FOR UPDATE
    USING (
        EXISTS (
            SELECT 1
            FROM public.invoices
            WHERE invoices.id = invoice_items.invoice_id
              AND invoices.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.invoices
            WHERE invoices.id = invoice_items.invoice_id
              AND invoices.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete items from their invoices"
    ON public.invoice_items FOR DELETE
    USING (
        EXISTS (
            SELECT 1
            FROM public.invoices
            WHERE invoices.id = invoice_items.invoice_id
              AND invoices.user_id = auth.uid()
        )
    );
