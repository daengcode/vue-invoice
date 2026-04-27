# Database Setup Guide

This guide will help you set up the database for the Invoice System using Supabase.

## Prerequisites

- A Supabase account ([sign up free](https://supabase.com))
- Your Supabase project URL and anon key

## Quick Setup (Recommended for Development)

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click **"Start your project"**
3. Sign in or create an account
4. Click **"New Project"**
5. Fill in:
   - **Name**: `homedecor-invoice` (or any name you prefer)
   - **Database Password**: Generate a strong password and **save it**
   - **Region**: Choose the region closest to your users
6. Click **"Create new project"**
7. Wait for the project to be provisioned (1-2 minutes)

### Step 2: Run the Database Schema

Once your project is ready:

1. In your Supabase dashboard, click on **SQL Editor** in the left sidebar
2. Click **"New Query"**
3. Open the file `supabase/quick_setup.sql` from your project
4. Copy all the SQL code
5. Paste it into the SQL Editor
6. Click **"Run"** (or press `Cmd/Ctrl + Enter`)

You should see a success message indicating the tables were created.

### Step 3: Verify Tables

1. Click on **Table Editor** in the left sidebar
2. You should see two tables:
   - `invoices`
   - `invoice_items`

### Step 4: Get Your Credentials

1. Click on **Settings** (gear icon) in the left sidebar
2. Click on **API**
3. Copy the following values:
   - **Project URL**
   - **anon / public** key

### Step 5: Configure Environment Variables

1. Create a `.env` file in your project root (copy from `.env.example`)
2. Add your Supabase credentials:

```env
VITE_SUPABASE_URL=your_project_url_here
VITE_SUPABASE_ANON_KEY=your_anon_key_here
```

Example:
```env
VITE_SUPABASE_URL=https://phrmcnndyvcdjlpmnjca.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Step 6: Create a Test User

 1. In Supabase dashboard, click on **Authentication** in the left sidebar
2. Click on **Users**
3. Click **"Add user"** > **"Create new user"**
4. Enter email and password:
   - **Email**: `admin@homedecor.test`
   - **Password**: `Password#`
5. Check **"Auto Confirm Email"** for testing
6. Click **"Create user"**
7. The user is now ready to login!

**Alternative**: Run the SQL script `supabase/create_test_user.sql` to create the user automatically.

### Step 7: Test Your Application

1. Start the development server:
   ```bash
   npm run dev
   ```

2. Open [http://localhost:5173](http://localhost:5173)

3. Try logging in with the test user credentials

4. Create your first invoice!

## Production Setup

For production, use the migration files in `supabase/migrations/`:

### Using Supabase CLI (Recommended)

1. **Install Supabase CLI**:

   ```bash
   npm install -g supabase
   ```

2. **Link your project**:

   ```bash
   supabase login
   supabase link --project-ref YOUR_PROJECT_REF
   ```

   You can find your project ref in your Supabase dashboard URL:
   `https://supabase.com/dashboard/project/YOUR_PROJECT_REF`

3. **Push migrations**:

   ```bash
   supabase db push
   ```

This will apply all migrations in `supabase/migrations/` to your database.

### Using Migration Files Directly

If you prefer not to use the CLI:

1. Go to **SQL Editor** in Supabase dashboard
2. Open and run `supabase/migrations/20260427224700_create_invoice_tables.sql`

This file includes:
- Detailed constraints and checks
- Performance indexes
- Automatic timestamp triggers
- Comprehensive RLS policies
- Documentation comments

## Database Schema Overview

### invoices Table

Stores invoice header information:

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Unique identifier (auto-generated) |
| invoice_number | TEXT | Auto-generated unique invoice number |
| invoice_date | TIMESTAMPTZ | When the invoice was created |
| due_date | DATE | When payment is due |
| customer_name | TEXT | Customer's name |
| customer_address | TEXT | Customer's address |
| sales_code | TEXT | Sales representative code |
| ppn_included | BOOLEAN | Whether VAT is included |
| subtotal | NUMERIC(15,2) | Sum of all items before discount |
| discount_amount | NUMERIC(15,2) | Total discount amount |
| total | NUMERIC(15,2) | Final total (subtotal - discount) |
| dp_po | NUMERIC(15,2) | Down payment amount |
| credit | NUMERIC(15,2) | Credit amount to be paid |
| user_id | UUID | Owner of the invoice |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |

### invoice_items Table

Stores individual line items for each invoice:

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Unique identifier (auto-generated) |
| invoice_id | UUID | Reference to parent invoice |
| no_urut | INTEGER | Item sequence number (1, 2, 3...) |
| product_name | TEXT | Product or service name |
| quantity | NUMERIC(10,2) | Quantity ordered |
| unit | TEXT | Unit of measurement |
| unit_price | NUMERIC(15,2) | Price per unit |
| discount | NUMERIC(15,2) | Discount for this item |
| total | NUMERIC(15,2) | Item total (quantity × price - discount) |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |

## Security Features

### Row Level Security (RLS)

The database uses RLS to ensure users can only access their own data:

- **invoices**: Users can only see, create, update, and delete their own invoices
- **invoice_items**: Users can only manage items that belong to their invoices

### Foreign Keys

- `invoice_items.invoice_id` references `invoices.id` with CASCADE delete
- `invoices.user_id` references `users(id)` (custom users table) with CASCADE delete

This means:
- Deleting an invoice automatically deletes all its items
- Deleting a user automatically deletes all their invoices

### Indexes

Performance-optimized indexes on:
- `invoices.user_id` - Fast lookup by user
- `invoices.invoice_number` - Fast lookup by invoice number
- `invoice_items.invoice_id` - Fast lookup of items for an invoice

## Troubleshooting

### Error: "relation 'invoices' does not exist"

**Solution**: Make sure you've run the database setup SQL in the SQL Editor.

### Error: "new row violates row-level security policy"

**Solution**: This means RLS is working correctly. Make sure:
- The user is logged in
- The user_id matches the authenticated user's ID

### Error: "duplicate key value violates unique constraint 'invoices_invoice_number_key'"

**Solution**: The invoice number is already in use. The app auto-generates unique numbers, but if you're testing manually, ensure each invoice has a unique number.

### Error: "null value in column 'user_id' violates not-null constraint"

**Solution**: Make sure the user is authenticated before creating an invoice. The app handles this automatically with route guards.

## Advanced: Customizing the Schema

### Adding New Columns

Example: Add a notes field to invoices:

```sql
ALTER TABLE invoices
ADD COLUMN notes TEXT;

-- Add RLS policy if needed
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
```

### Creating Views

Example: Create a view for invoice summaries:

```sql
CREATE VIEW invoice_summaries AS
SELECT
    i.id,
    i.invoice_number,
    i.customer_name,
    i.total,
    COUNT(ii.id) as item_count
FROM invoices i
LEFT JOIN invoice_items ii ON i.id = ii.invoice_id
GROUP BY i.id;
```

### Creating Functions

Example: Create a function to calculate invoice total:

```sql
CREATE OR REPLACE FUNCTION calculate_invoice_total(invoice_uuid UUID)
RETURNS NUMERIC AS $$
DECLARE
    total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(total), 0)
    INTO total
    FROM invoice_items
    WHERE invoice_id = invoice_uuid;
    RETURN total;
END;
$$ LANGUAGE plpgsql;
```

## Maintenance

### Backing Up Data

1. In Supabase dashboard, go to **Settings** > **Database**
2. Click **Backups**
3. Backups are created automatically daily

### Restoring from Backup

1. Go to **Settings** > **Database** > **Backups**
2. Find the backup you want to restore
3. Click **Restore**

### Monitoring Queries

1. Go to **Database** > **Logs** in Supabase dashboard
2. View recent queries and their performance

## Next Steps

After setting up the database:

1. ✅ Configure environment variables (`.env`)
2. ✅ Create a test user
3. ✅ Test the application locally (`npm run dev`)
4. ✅ Create some test invoices
5. ✅ Test PDF download functionality
6. ✅ Deploy to Vercel

For deployment instructions, see `README.md`.

## Support

If you encounter issues:

1. Check the [Supabase Documentation](https://supabase.com/docs)
2. Review the SQL Editor logs for error messages
3. Verify your environment variables are set correctly
4. Ensure RLS policies are properly configured
