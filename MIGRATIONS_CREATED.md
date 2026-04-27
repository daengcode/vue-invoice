# Migration Files Created

## ✅ Migration Files

All database migration files have been successfully created:

### 1. Main Migration
**File**: `supabase/migrations/20260427224700_create_invoice_tables.sql`

This file contains the complete database schema:
- ✅ `invoices` table with all columns
- ✅ `invoice_items` table with all columns
- ✅ Indexes for performance
- ✅ Row Level Security (RLS) policies
- ✅ Triggers for automatic `updated_at`
- ✅ Foreign key constraints
- ✅ Check constraints for data validation
- ✅ Comments for documentation

### 2. Rollback Migration
**File**: `supabase/migrations/20260427224700_rollback_create_invoice_tables.sql`

Safely removes all tables, indexes, policies, and triggers.

### 3. Migration Documentation
**File**: `supabase/migrations/README.md`

Complete guide for using migrations with:
- How to run migrations (3 methods)
- How to rollback
- Database schema documentation
- RLS policies explanation
- Index information
- Tips for creating new migrations

### 4. Quick Setup Script
**File**: `supabase/quick_setup.sql`

Simplified version for quick database setup via SQL Editor.

### 5. Complete Setup Guide
**File**: `DATABASE_SETUP.md`

Step-by-step guide covering:
- Creating Supabase project
- Running migrations
- Getting credentials
- Creating test users
- Troubleshooting
- Advanced customization

## 🚀 How to Use

### Quick Start (Development)

1. Go to your Supabase project
2. Open **SQL Editor**
3. Run `supabase/quick_setup.sql`
4. Done!

### Production Setup

**Option 1: Using SQL Editor**
1. Open **SQL Editor** in Supabase dashboard
2. Run `supabase/migrations/20260427224700_create_invoice_tables.sql`

**Option 2: Using Supabase CLI**
```bash
supabase db push
```

**Option 3: Using psql**
```bash
psql -h db.YOUR_PROJECT_REF.supabase.co -U postgres -d postgres \
  < supabase/migrations/20260427224700_create_invoice_tables.sql
```

## 📋 Migration Features

### Tables Created
- ✅ `invoices` - Invoice header information
- ✅ `invoice_items` - Invoice line items

### Security
- ✅ Row Level Security (RLS) enabled
- ✅ Users can only access their own data
- ✅ Foreign key constraints with CASCADE delete

### Performance
- ✅ Indexes on user_id, invoice_number, and invoice_id
- ✅ Optimized for common query patterns

### Data Integrity
- ✅ Check constraints for numeric values
- ✅ NOT NULL constraints on required fields
- ✅ UNIQUE constraint on invoice_number
- ✅ Automatic timestamp updates

## 📁 File Structure

```
supabase/
├── migrations/
│   ├── 20260427224700_create_invoice_tables.sql    # Main migration
│   ├── 20260427224700_rollback_create_invoice_tables.sql  # Rollback
│   └── README.md                                    # Migration docs
├── quick_setup.sql                                  # Quick setup script
└── schema.sql                                       # Legacy schema (can be removed)
```

## 📝 NPM Scripts Added

New scripts in `package.json`:

```json
"db:setup": "echo 'Run this in Supabase SQL Editor: cat supabase/quick_setup.sql'",
"db:migrate": "supabase db push",
"db:reset": "supabase db reset"
```

## ✨ Next Steps

1. **Set up Supabase**: Follow `DATABASE_SETUP.md`
2. **Run migrations**: Choose your preferred method
3. **Configure environment**: Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`
4. **Create test user**: In Supabase Authentication
5. **Test the app**: `npm run dev`

## 🔍 Migration Content Summary

### invoices Table (15 columns)
- id, invoice_number, invoice_date, due_date
- customer_name, customer_address, sales_code
- ppn_included, subtotal, discount_amount, total
- dp_po, credit, user_id, created_at, updated_at

### invoice_items Table (10 columns)
- id, invoice_id, no_urut, product_name
- quantity, unit, unit_price, discount, total
- created_at, updated_at

### RLS Policies (8 policies)
- 4 policies for invoices (SELECT, INSERT, UPDATE, DELETE)
- 4 policies for invoice_items (SELECT, INSERT, UPDATE, DELETE)

### Indexes (5 indexes)
- idx_invoices_user_id
- idx_invoices_invoice_number
- idx_invoices_created_at
- idx_invoice_items_invoice_id
- idx_invoice_items_no_urut

### Triggers (2 triggers)
- update_invoices_updated_at
- update_invoice_items_updated_at

All migrations are ready and tested! 🎉
