# Database Migrations

This directory contains database migrations for the Invoice System using Supabase.

## Migration Files

### 20260427224700_create_invoice_tables.sql
Creates the `invoices` and `invoice_items` tables with:
- Proper column types and constraints
- Indexes for performance
- Row Level Security (RLS) policies
- Triggers for automatic `updated_at` timestamps
- Foreign key relationships
- Comments for documentation

### 20260427224700_rollback_create_invoice_tables.sql
Rollback script to safely remove all tables, indexes, policies, and triggers.

## How to Run Migrations

### Option 1: Using Supabase SQL Editor (Recommended for quick setup)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy the content of `20260427224700_create_invoice_tables.sql`
5. Paste it into the editor
6. Click **Run** to execute

### Option 2: Using Supabase CLI (Recommended for production)

First, install the Supabase CLI if you haven't:

```bash
npm install -g supabase
```

Then, link your local project to Supabase:

```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REF
```

Push migrations to your Supabase project:

```bash
supabase db push
```

### Option 3: Using psql (PostgreSQL client)

```bash
psql -h db.YOUR_PROJECT_REF.supabase.co -U postgres -d postgres < supabase/migrations/20260427224700_create_invoice_tables.sql
```

You'll be prompted for your database password.

## How to Rollback

### Using Supabase SQL Editor

1. Go to **SQL Editor** in your Supabase dashboard
2. Copy the content of `20260427224700_rollback_create_invoice_tables.sql`
3. Paste and run

### Using Supabase CLI

```bash
supabase db reset
```

This will reset your database to the initial state (removes all data and recreates schema).

### Using psql

```bash
psql -h db.YOUR_PROJECT_REF.supabase.co -U postgres -d postgres < supabase/migrations/20260427224700_rollback_create_invoice_tables.sql
```

## Database Schema

### invoices

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unique identifier |
| invoice_number | TEXT | NOT NULL, UNIQUE | Auto-generated invoice number |
| invoice_date | TIMESTAMPTZ | NOT NULL | Invoice creation date & time |
| due_date | DATE | NOT NULL | Payment due date |
| customer_name | TEXT | NOT NULL | Customer name |
| customer_address | TEXT | | Customer address |
| sales_code | TEXT | | Sales representative code |
| ppn_included | BOOLEAN | DEFAULT false | PPN (VAT) included flag |
| subtotal | NUMERIC(15,2) | DEFAULT 0, CHECK >= 0 | Sum before discount |
| discount_amount | NUMERIC(15,2) | DEFAULT 0, CHECK >= 0 | Total discount |
| total | NUMERIC(15,2) | DEFAULT 0, CHECK >= 0 | Final total |
| dp_po | NUMERIC(15,2) | DEFAULT 0, CHECK >= 0 | Down payment amount |
| credit | NUMERIC(15,2) | DEFAULT 0, CHECK >= 0 | Credit amount |
| user_id | UUID | NOT NULL, FK to users | Owner of the invoice |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() | Last update timestamp |

### invoice_items

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unique identifier |
| invoice_id | UUID | NOT NULL, FK to invoices(id) | Parent invoice |
| no_urut | INTEGER | NOT NULL, CHECK > 0 | Item sequence number |
| product_name | TEXT | NOT NULL | Product/service name |
| quantity | NUMERIC(10,2) | NOT NULL, CHECK > 0 | Quantity |
| unit | TEXT | NOT NULL | Unit (DUS, PCS, CRT, etc.) |
| unit_price | NUMERIC(15,2) | NOT NULL, CHECK >= 0 | Price per unit |
| discount | NUMERIC(15,2) | DEFAULT 0, CHECK >= 0 | Discount per item |
| total | NUMERIC(15,2) | NOT NULL, CHECK >= 0 | Item total |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() | Last update timestamp |

## Row Level Security (RLS)

All tables have RLS enabled to ensure users can only access their own data:

### invoices
- **SELECT**: Users can view their own invoices
- **INSERT**: Users can create their own invoices
- **UPDATE**: Users can update their own invoices
- **DELETE**: Users can delete their own invoices

### invoice_items
- **SELECT**: Users can view items from their invoices
- **INSERT**: Users can add items to their invoices
- **UPDATE**: Users can update items from their invoices
- **DELETE**: Users can delete items from their invoices

## Indexes

For better query performance, the following indexes are created:

- `idx_invoices_user_id`: Fast lookup by user
- `idx_invoices_invoice_number`: Fast lookup by invoice number
- `idx_invoices_created_at`: Fast sorting by creation date
- `idx_invoice_items_invoice_id`: Fast lookup of items for an invoice
- `idx_invoice_items_no_urut`: Fast sorting of items within an invoice

## Triggers

An automatic trigger updates the `updated_at` column whenever a row is modified in either table.

## Notes

- All monetary values use `NUMERIC(15,2)` for precise decimal calculations
- `NUMERIC` type is used instead of `FLOAT` to avoid rounding errors
- Cascade delete is enabled: deleting an invoice automatically deletes all its items
- The `uuid-ossp` extension is required for UUID generation
- All timestamps use `TIMESTAMPTZ` to store timezone information

## Creating New Migrations

When you need to modify the schema:

1. Create a new migration file with timestamp: `YYYYMMDDHHMMSS_description.sql`
2. Write your SQL changes
3. Run the migration using one of the methods above
4. Optionally create a rollback migration: `YYYYMMDDHHMMSS_rollback_description.sql`

Example:
```bash
# Create migration
20260428100000_add_invoice_notes.sql

# Create rollback
20260428100000_rollback_add_invoice_notes.sql
```
