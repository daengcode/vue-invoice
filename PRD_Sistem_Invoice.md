# PRD — Sistem Invoice HomeDécor Makassar
**Versi:** 1.0 | **Stack:** Vue 3 + Shadcn + Supabase + Vercel

---

## 1. Tujuan
Aplikasi web sederhana untuk membuat dan mengunduh invoice digital, menggantikan proses manual.

---

## 2. Pengguna
User (staff) yang sudah login dapat membuat invoice dan mengunduhnya sebagai PDF.

---

## 3. Fitur

### 3.1 Autentikasi
- Login dengan email & password (Supabase Auth)
- Logout
- Halaman terlindungi — tidak bisa diakses tanpa login

### 3.2 Daftar Invoice
- Tampilkan semua invoice milik user yang login
- Kolom: No. Invoice, Pelanggan, Tanggal, Total, Aksi
- Tombol **Buat Invoice Baru**

### 3.3 Form Buat Invoice

**Header Invoice:**

| Field | Keterangan |
|-------|-----------|
| No. Transaksi | Auto-generate |
| Tanggal | Date & time picker |
| Pelanggan | Input teks bebas |
| Alamat | Input teks |
| Kode Sales | Input teks |
| Tanggal Jatuh Tempo | Date picker |
| PPN | Include / Exclude (toggle) |

**Tabel Item (multiple rows, dinamis):**

| Field | Keterangan |
|-------|-----------|
| No. | Auto-increment |
| Nama Item | Input teks |
| Jumlah | Input angka |
| Satuan | Input teks (DUS, PCS, CRT, dll) |
| Harga | Input angka |
| Diskon | Input angka (default 0) |
| Total | Auto-calculate (Jumlah × Harga − Diskon) |

- Tombol **+ Tambah Item** untuk menambah baris baru
- Tombol **✕** di setiap baris untuk hapus item

**Ringkasan (auto-calculate):**
- Sub Total, Potongan, Total, DP PO, Kredit

### 3.4 Download PDF
- Setiap invoice memiliki tombol **Download PDF**
- Layout PDF mengikuti format invoice terlampir:
  - Header: logo, nama perusahaan, info transaksi
  - Tabel item lengkap
  - Ringkasan total
  - Terbilang (otomatis dari nominal)
  - Info rekening bank

---

## 4. Database (Supabase)

### Tabel `invoices`
```sql
id               uuid PRIMARY KEY
invoice_number   text
invoice_date     timestamptz
due_date         date
customer_name    text
customer_address text
sales_code       text
ppn_included     boolean
subtotal         numeric
discount_amount  numeric
total            numeric
dp_po            numeric
credit           numeric
user_id          uuid REFERENCES auth.users(id)
created_at       timestamptz
```

### Tabel `invoice_items`
```sql
id            uuid PRIMARY KEY
invoice_id    uuid REFERENCES invoices(id) ON DELETE CASCADE
no_urut       integer
product_name  text
quantity      numeric
unit          text
unit_price    numeric
discount      numeric
total         numeric
```

**RLS:** User hanya bisa akses invoice milik sendiri (`user_id = auth.uid()`).

---

## 5. Tech Stack

| | |
|---|---|
| Frontend | Vue 3 + Vite + Tailwind CSS | shadcn |
| Backend | Supabase (DB + Auth) |
| PDF | jsPDF + html2canvas |
| Deploy | Vercel |

---

## 6. Alur Penggunaan

```
Login
  └─> Daftar Invoice
        └─> Klik "Buat Invoice Baru"
              └─> Isi form header
                    └─> Isi item (tambah baris sesuai kebutuhan)
                          └─> Klik "Simpan"
                                └─> Redirect ke detail invoice
                                      └─> Klik "Download PDF"
```

---

## 7. Halaman

| Route | Halaman |
|-------|---------|
| `/login` | Form login |
| `/invoices` | Daftar invoice |
| `/invoices/create` | Form buat invoice baru |
| `/invoices/:id` | Detail + tombol download PDF |

---