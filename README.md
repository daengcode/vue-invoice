# Sistem Invoice HomeDécor Makassar

Aplikasi web untuk membuat dan mengunduh invoice digital.

## Tech Stack

- **Frontend**: Vue 3 + Vite + TypeScript + Tailwind CSS
- **Backend**: Supabase (Database + Authentication)
- **PDF Generation**: jsPDF + html2canvas
- **Deployment**: Vercel

## Prerequisites

- Node.js (v20 or higher)
- Supabase account

## Setup

### 1. Clone the repository

```bash
git clone <repository-url>
cd vue-invoice
```

### 2. Install dependencies

```bash
npm install
```

### 3. Set up Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to SQL Editor in your Supabase dashboard
3. Run the SQL schema from `supabase/schema.sql`
4. Go to Settings > API to get your:
   - Project URL
   - anon/public key

### 4. Configure environment variables

Create a `.env` file in the root directory:

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 5. Create a test user

Choose one of the following methods to create a test user:

**Option 1: Quick SQL Script (Recommended)**

```bash
# In Supabase Dashboard, open SQL Editor and run:
cat supabase/create_test_user.sql
```

Default credentials:

- Email: `admin@catering.test`
- Password: `Password#`

**Option 2: Using Dashboard**

1. Go to Authentication > Users
2. Click "Add user" > "Create new user"
3. Enter email: `admin@catering.test` and password: `Password#`
4. Check "Auto Confirm Email"
5. Click "Create user"

**Option 3: Using Node.js Script**

```bash
node supabase/create-user.js
```

For detailed instructions, see [TEST_USER_CREDENTIALS.md](TEST_USER_CREDENTIALS.md) or [CREATE_TEST_USER.md](CREATE_TEST_USER.md)

## Development

Run the development server:

```bash
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) in your browser.

## Build for Production

```bash
npm run build
```

The built files will be in the `dist` directory.

## Deployment to Vercel

1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com) and import your repository
3. Add environment variables:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
4. Deploy!

## Features

- ✅ User authentication (login/logout)
- ✅ Create and manage invoices
- ✅ Dynamic item management (add/remove items)
- ✅ Auto-calculate totals
- ✅ Download invoices as PDF
- ✅ Row Level Security (users can only see their own invoices)

## Database Schema

### invoices table

- `id` (UUID, Primary Key)
- `invoice_number` (text)
- `invoice_date` (timestamptz)
- `due_date` (date)
- `customer_name` (text)
- `customer_address` (text)
- `sales_code` (text)
- `ppn_included` (boolean)
- `subtotal` (numeric)
- `discount_amount` (numeric)
- `total` (numeric)
- `dp_po` (numeric)
- `credit` (numeric)
- `user_id` (UUID, Foreign Key to users)
- `created_at` (timestamptz)

### invoice_items table

- `id` (UUID, Primary Key)
- `invoice_id` (UUID, Foreign Key to invoices)
- `no_urut` (integer)
- `product_name` (text)
- `quantity` (numeric)
- `unit` (text)
- `unit_price` (numeric)
- `discount` (numeric)
- `total` (numeric)

## License

MIT
# vue-invoice
