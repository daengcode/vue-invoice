-- Rollback Migration: Drop invoices and invoice_items tables
-- Created: 2026-04-27 22:47:00

-- Drop triggers
DROP TRIGGER IF EXISTS update_invoices_updated_at ON invoices;
DROP TRIGGER IF EXISTS update_invoice_items_updated_at ON invoice_items;

-- Drop function
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop RLS policies
DROP POLICY IF EXISTS "Users can view their own invoices" ON invoices;
DROP POLICY IF EXISTS "Users can insert their own invoices" ON invoices;
DROP POLICY IF EXISTS "Users can update their own invoices" ON invoices;
DROP POLICY IF EXISTS "Users can delete their own invoices" ON invoices;

DROP POLICY IF EXISTS "Users can view items from their invoices" ON invoice_items;
DROP POLICY IF EXISTS "Users can insert items to their invoices" ON invoice_items;
DROP POLICY IF EXISTS "Users can update items from their invoices" ON invoice_items;
DROP POLICY IF EXISTS "Users can delete items from their invoices" ON invoice_items;

-- Disable RLS
ALTER TABLE invoices DISABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items DISABLE ROW LEVEL SECURITY;

-- Drop indexes
DROP INDEX IF EXISTS idx_invoices_user_id;
DROP INDEX IF EXISTS idx_invoices_invoice_number;
DROP INDEX IF EXISTS idx_invoices_created_at;
DROP INDEX IF EXISTS idx_invoice_items_invoice_id;
DROP INDEX IF EXISTS idx_invoice_items_no_urut;

-- Drop tables (cascade will handle dependencies)
DROP TABLE IF EXISTS invoice_items CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;

-- Note: UUID extension is kept as it may be used by other tables
-- To remove it completely, run: DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;
