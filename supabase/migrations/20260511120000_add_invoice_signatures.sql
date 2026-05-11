-- Migration: Add seller and buyer signature names to invoices
-- Created: 2026-05-11 12:00:00

ALTER TABLE invoices
ADD COLUMN IF NOT EXISTS seller_name TEXT DEFAULT '',
ADD COLUMN IF NOT EXISTS buyer_name TEXT DEFAULT '';

COMMENT ON COLUMN invoices.seller_name IS 'Seller name shown in invoice signature section';
COMMENT ON COLUMN invoices.buyer_name IS 'Buyer name shown in invoice signature section';
