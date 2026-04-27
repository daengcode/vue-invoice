-- Update Foreign Key Constraint in Invoices Table
-- Change user_id from auth.users(id) to public.users(id)

-- Step 1: Drop the existing foreign key constraint
ALTER TABLE invoices DROP CONSTRAINT IF EXISTS invoices_user_id_fkey;

-- Step 2: Add new foreign key constraint to custom users table
ALTER TABLE invoices 
ADD CONSTRAINT invoices_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Step 3: Verify the constraint
SELECT 
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(c.oid) AS constraint_definition
FROM pg_constraint c
JOIN pg_namespace n ON n.oid = c.connamespace
JOIN pg_class cl ON cl.oid = c.conrelid
WHERE cl.relname = 'invoices'
AND conname = 'invoices_user_id_fkey';

-- Note: ON DELETE CASCADE means if a user is deleted, all their invoices will also be deleted
