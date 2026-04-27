-- Migration: Create invoices and invoice_items tables
-- Created: 2026-04-27 22:47:00

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create invoices table
CREATE TABLE IF NOT EXISTS invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number TEXT NOT NULL UNIQUE,
    invoice_date TIMESTAMPTZ NOT NULL,
    due_date DATE NOT NULL,
    customer_name TEXT NOT NULL,
    customer_address TEXT,
    sales_code TEXT,
    ppn_included BOOLEAN DEFAULT false,
    subtotal NUMERIC(15, 2) DEFAULT 0 CHECK (subtotal >= 0),
    discount_amount NUMERIC(15, 2) DEFAULT 0 CHECK (discount_amount >= 0),
    total NUMERIC(15, 2) DEFAULT 0 CHECK (total >= 0),
    dp_po NUMERIC(15, 2) DEFAULT 0 CHECK (dp_po >= 0),
    credit NUMERIC(15, 2) DEFAULT 0 CHECK (credit >= 0),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create invoice_items table
CREATE TABLE IF NOT EXISTS invoice_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    no_urut INTEGER NOT NULL CHECK (no_urut > 0),
    product_name TEXT NOT NULL,
    quantity NUMERIC(10, 2) NOT NULL CHECK (quantity > 0),
    unit TEXT NOT NULL,
    unit_price NUMERIC(15, 2) NOT NULL CHECK (unit_price >= 0),
    discount NUMERIC(15, 2) DEFAULT 0 CHECK (discount >= 0),
    total NUMERIC(15, 2) NOT NULL CHECK (total >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_invoices_user_id ON invoices(user_id);
CREATE INDEX IF NOT EXISTS idx_invoices_invoice_number ON invoices(invoice_number);
CREATE INDEX IF NOT EXISTS idx_invoices_created_at ON invoices(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice_id ON invoice_items(invoice_id);
CREATE INDEX IF NOT EXISTS idx_invoice_items_no_urut ON invoice_items(invoice_id, no_urut);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoice_items_updated_at BEFORE UPDATE ON invoice_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for invoices
CREATE POLICY "Users can view their own invoices"
    ON invoices FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own invoices"
    ON invoices FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own invoices"
    ON invoices FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own invoices"
    ON invoices FOR DELETE
    USING (auth.uid() = user_id);

-- Create RLS policies for invoice_items
CREATE POLICY "Users can view items from their invoices"
    ON invoice_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM invoices
            WHERE invoices.id = invoice_items.invoice_id
            AND invoices.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert items to their invoices"
    ON invoice_items FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM invoices
            WHERE invoices.id = invoice_items.invoice_id
            AND invoices.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update items from their invoices"
    ON invoice_items FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM invoices
            WHERE invoices.id = invoice_items.invoice_id
            AND invoices.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete items from their invoices"
    ON invoice_items FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM invoices
            WHERE invoices.id = invoice_items.invoice_id
            AND invoices.user_id = auth.uid()
        )
    );

-- Add comments for documentation
COMMENT ON TABLE invoices IS 'Table for storing invoice information';
COMMENT ON TABLE invoice_items IS 'Table for storing invoice line items';

COMMENT ON COLUMN invoices.invoice_number IS 'Unique invoice number (auto-generated)';
COMMENT ON COLUMN invoices.invoice_date IS 'Date and time when invoice was created';
COMMENT ON COLUMN invoices.due_date IS 'Payment due date';
COMMENT ON COLUMN invoices.customer_name IS 'Name of the customer';
COMMENT ON COLUMN invoices.customer_address IS 'Address of the customer';
COMMENT ON COLUMN invoices.sales_code IS 'Sales representative code';
COMMENT ON COLUMN invoices.ppn_included IS 'Whether PPN (VAT) is included in the price';
COMMENT ON COLUMN invoices.subtotal IS 'Sum of all item totals before discount';
COMMENT ON COLUMN invoices.discount_amount IS 'Total discount amount';
COMMENT ON COLUMN invoices.total IS 'Final total after discount (subtotal - discount_amount)';
COMMENT ON COLUMN invoices.dp_po IS 'Down payment / Purchase Order amount';
COMMENT ON COLUMN invoices.credit IS 'Credit amount remaining to be paid';

COMMENT ON COLUMN invoice_items.no_urut IS 'Sequence number of the item in the invoice';
COMMENT ON COLUMN invoice_items.product_name IS 'Name of the product/service';
COMMENT ON COLUMN invoice_items.quantity IS 'Quantity of the item';
COMMENT ON COLUMN invoice_items.unit IS 'Unit of measurement (DUS, PCS, CRT, etc.)';
COMMENT ON COLUMN invoice_items.unit_price IS 'Price per unit';
COMMENT ON COLUMN invoice_items.discount IS 'Discount amount for this item';
COMMENT ON COLUMN invoice_items.total IS 'Total for this item (quantity * unit_price - discount)';
